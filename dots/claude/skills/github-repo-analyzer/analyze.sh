#!/usr/bin/env bash
# github-repo-analyzer.sh <owner/name | github-url>
# Emits a markdown health report. Agent only needs to add the TL;DR verdict.

set -euo pipefail

REPO="${1:?Usage: $0 <owner/name | github-url>}"
REPO="${REPO#https://github.com/}"
REPO="${REPO#http://github.com/}"
REPO="${REPO%.git}"
REPO="${REPO%/}"

command -v gh >/dev/null || { echo "gh CLI not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found" >&2; exit 1; }

# --- Cross-platform "N days ago" → ISO8601 ---
days_ago_iso() {
  local d="$1"
  if date -u -v-"${d}"d +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
    date -u -v-"${d}"d +%Y-%m-%dT%H:%M:%SZ
  else
    date -u -d "${d} days ago" +%Y-%m-%dT%H:%M:%SZ
  fi
}

SINCE_30D=$(days_ago_iso 30)
SINCE_90D=$(days_ago_iso 90)
SINCE_365D=$(days_ago_iso 365)

# ============================================================
# 1. Basics
# ============================================================
basics=$(gh repo view "$REPO" --json \
  name,description,stargazerCount,forkCount,isArchived,isFork,licenseInfo,createdAt,pushedAt,primaryLanguage,homepageUrl)

stars=$(jq -r .stargazerCount       <<<"$basics")
forks=$(jq -r .forkCount            <<<"$basics")
archived=$(jq -r .isArchived        <<<"$basics")
isfork=$(jq -r .isFork              <<<"$basics")
license=$(jq -r '.licenseInfo.spdxId // "none"'         <<<"$basics")
createdAt=$(jq -r .createdAt        <<<"$basics")
pushedAt=$(jq -r .pushedAt          <<<"$basics")
lang=$(jq -r '.primaryLanguage.name // "n/a"'           <<<"$basics")
homepage=$(jq -r '.homepageUrl // ""'                   <<<"$basics")
desc=$(jq -r '.description // ""'                       <<<"$basics")

echo "# $REPO — health data"
echo
echo "## Basics"
echo "- Stars: **$stars** · Forks: $forks"
echo "- Created: ${createdAt%T*} · Last push: ${pushedAt%T*}"
echo "- Language: $lang · License: $license · Archived: $archived · Fork: $isfork"
[[ -n "$desc"     ]] && echo "- Description: $desc"
[[ -n "$homepage" ]] && echo "- Homepage: $homepage"

if [[ "$archived" == "true" ]]; then
  echo
  echo "**Repo is ARCHIVED — skipping deep analysis.**"
  exit 0
fi

# ============================================================
# 2. Star trend
# ============================================================
echo
echo "## Star trend"

months_since=$(jq -n --arg c "$createdAt" \
  '((now - ($c|fromdateiso8601)) / (30*86400)) | floor | if . < 1 then 1 else . end')
lifetime_per_month=$(( stars / months_since ))
echo "- Lifetime: $stars stars over ~${months_since}mo → ~${lifetime_per_month} stars/mo avg"

# GitHub paginates stargazers up to page 400 (40,000 stars). Skip bucketing
# for huge repos; report only the lifetime average.
if (( stars > 40000 )); then
  echo "- >40k stars: per-month bucketing skipped (GitHub pagination cap)."
  echo "- Trend (qualitative): assume **decaying** unless commit/issue activity says otherwise."
else
  last_page=$(( (stars + 99) / 100 ))
  start_page=$(( last_page > 9 ? last_page - 9 : 1 ))

  star_dates=$(
    for ((p=start_page; p<=last_page; p++)); do
      gh api -H "Accept: application/vnd.github.star+json" \
        "repos/$REPO/stargazers?per_page=100&page=$p" \
        -q '.[].starred_at' 2>/dev/null || true
    done
  )

  if [[ -n "$star_dates" ]]; then
    sample_size=$(wc -l <<<"$star_dates" | tr -d ' ')
    counts=$(awk -v d30="$SINCE_30D" -v d90="$SINCE_90D" -v d365="$SINCE_365D" '
      $0 >= d30  { c30++ }
      $0 >= d90  { c90++ }
      $0 >= d365 { c365++ }
      END { printf "%d %d %d", c30+0, c90+0, c365+0 }' <<<"$star_dates")
    read c30 c90 c365 <<<"$counts"

    rate30_per_month=$(( c30 ))  # already 30d
    if (( lifetime_per_month > 0 )); then
      ratio=$(jq -n --argjson r "$rate30_per_month" --argjson l "$lifetime_per_month" \
        '$r/$l')
      verdict=$(jq -rn --argjson x "$ratio" '
        if $x >= 1.5 then "accelerating"
        elif $x >= 0.7 then "steady"
        else "decaying" end')
      printf -v ratio_fmt "%.2f" "$ratio"
    else
      ratio_fmt="n/a"; verdict="unknown"
    fi

    echo "- Last 30d: +$c30 · 90d: +$c90 · 365d: +$c365 (sample of $sample_size most recent)"
    echo "- 30d rate vs lifetime avg: ${ratio_fmt}× → **$verdict**"
    echo
    echo "  Stars by month (recent sample):"
    awk '{ print substr($0,1,7) }' <<<"$star_dates" \
      | sort | uniq -c | sort -k2 | tail -12 \
      | awk '{ printf "  - %s: %d\n", $2, $1 }'
  else
    echo "- Could not fetch star timestamps."
  fi
fi

# ============================================================
# 3. Commit cadence (last 90d)
# ============================================================
echo
echo "## Commit cadence (last 90d)"

commit_dates=$(gh api "repos/$REPO/commits?since=$SINCE_90D&per_page=100" \
  --paginate -q '.[].commit.author.date' 2>/dev/null || true)

if [[ -z "$commit_dates" ]]; then
  echo "- No commits in last 90 days."
else
  total_commits=$(wc -l <<<"$commit_dates" | tr -d ' ')

  # Active ISO weeks + max gap (in days) — both via jq.
  stats=$(jq -Rs '
    split("\n") | map(select(length > 0)) | map(fromdateiso8601) | sort as $ts |
    {
      active_weeks: ($ts | map(strftime("%G-W%V")) | unique | length),
      max_gap_days: (
        if ($ts|length) < 2 then 0
        else ([range(1; $ts|length) as $i | ($ts[$i] - $ts[$i-1])] | max) / 86400 | floor
        end
      )
    }' <<<"$commit_dates")

  active_weeks=$(jq -r .active_weeks <<<"$stats")
  max_gap=$(jq -r .max_gap_days     <<<"$stats")

  echo "- $total_commits commits across $active_weeks active weeks (of ~13). Max gap: ${max_gap}d."
  echo
  echo "  Commits by ISO week:"
  jq -Rs 'split("\n") | map(select(length > 0)) | map(fromdateiso8601 | strftime("%G-W%V")) |
    group_by(.) | map({w: .[0], n: length}) | sort_by(.w) | .[] | "  - \(.w): \(.n)"' \
    -r <<<"$commit_dates"
fi

# ============================================================
# 4. Contributors
# ============================================================
echo
echo "## Contributors"

# Lifetime (top contributors only — GitHub caps the response)
lifetime=$(gh api "repos/$REPO/contributors?per_page=100" --paginate 2>/dev/null \
  | jq -s 'add // [] | map({login, contributions}) | sort_by(-.contributions)' \
  || echo '[]')

total_lifetime=$(jq 'length' <<<"$lifetime")

if (( total_lifetime > 0 )); then
  total_c=$(jq '[.[].contributions] | add' <<<"$lifetime")
  echo "- Lifetime: $total_lifetime contributors listed (GitHub may cap), $total_c commits attributed"
  jq -r --argjson t "$total_c" '
    .[0:5] | to_entries[] |
    "  - #\(.key+1) \(.value.login): \(.value.contributions) (\((.value.contributions/$t*100)|floor)%)"' \
    <<<"$lifetime"
  top1_share=$(jq --argjson t "$total_c" '.[0].contributions/$t*100|floor' <<<"$lifetime")
  top3_share=$(jq --argjson t "$total_c" '[.[0:3][].contributions]|add/$t*100|floor' <<<"$lifetime")
  echo "  - Top-1 share: ${top1_share}% · Top-3 share: ${top3_share}%"
fi

# Recent (last 12mo)
recent_authors=$(gh api "repos/$REPO/commits?since=$SINCE_365D&per_page=100" \
  --paginate -q '.[].author.login // .[].commit.author.name // "unknown"' 2>/dev/null || true)

echo
if [[ -z "$recent_authors" ]]; then
  echo "- Last 12mo: no commits."
else
  unique_recent=$(sort -u <<<"$recent_authors" | wc -l | tr -d ' ')
  total_recent=$(wc -l <<<"$recent_authors" | tr -d ' ')
  echo "- Last 12mo: **$unique_recent unique authors**, $total_recent commits"
  echo "  Top recent authors:"
  sort <<<"$recent_authors" | uniq -c | sort -rn | head -5 \
    | awk '{ printf "  - %s: %d commits\n", $2, $1 }'

  top1_n=$(sort <<<"$recent_authors" | uniq -c | sort -rn | head -1 | awk '{print $1}')
  top3_n=$(sort <<<"$recent_authors" | uniq -c | sort -rn | head -3 | awk '{s+=$1} END{print s}')
  top1_pct=$(( top1_n * 100 / total_recent ))
  top3_pct=$(( top3_n * 100 / total_recent ))

  if   (( top1_pct >= 70 )); then profile="owner-driven (top-1 ≥70%)"
  elif (( top3_pct >= 80 )); then profile="small-team (top-3 ≥80%)"
  else                            profile="long-tail community"
  fi
  echo "  - Top-1: ${top1_pct}% · Top-3: ${top3_pct}% → **$profile**"

  # Bus factor: # of authors covering >=50% of commits
  bus_factor=$(sort <<<"$recent_authors" | uniq -c | sort -rn | awk -v tot="$total_recent" '
    { cum += $1; n++; if (cum*2 >= tot) { print n; exit } }')
  echo "  - Bus factor (≥50% coverage): $bus_factor"
fi

# ============================================================
# 5. Open issues + PR backlog
# ============================================================
echo
echo "## Open issues & PR backlog"

total_open_prs=$(gh api "search/issues?q=repo:$REPO+is:pr+is:open&per_page=1" \
  -q '.total_count' 2>/dev/null || echo "?")
total_open_issues=$(gh api "search/issues?q=repo:$REPO+is:issue+is:open&per_page=1" \
  -q '.total_count' 2>/dev/null || echo "?")
echo "- Open PRs: **$total_open_prs** · Open issues: **$total_open_issues**"

echo
echo "  Sample of 5 most-recently-updated open issues:"
gh issue list -R "$REPO" --state open --limit 5 \
  --json number,title,createdAt,updatedAt,comments,labels,author 2>/dev/null \
  | jq -r '.[] |
      "  - #\(.number) \"\(.title[0:80])\" — opened \(.createdAt[0:10]), updated \(.updatedAt[0:10]), \(.comments|length) comments, labels: \([.labels[].name]|join(",")|if .=="" then "none" else . end), author: \(.author.login)"' \
  || echo "  - (no open issues, or issues disabled)"

echo
echo "## Notes for synthesis"
echo "- Add a TL;DR (one of: Healthy / Maintained but slowing / Single-maintainer risk / Stalled / Archived) and a 2-4 bullet verdict."
echo "- Do not editorialize beyond the data above."
