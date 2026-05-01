---
name: free-for-dev
description: Use when recommending free-tier or free-for-developers services — SaaS, PaaS, IaaS, hosting, databases, CDNs, APIs, monitoring, CI/CD, analytics, email, auth, etc. Catalog sourced from ripienaar/free-for-dev.
---

Fetch the catalog on demand from [ripienaar/free-for-dev](https://github.com/ripienaar/free-for-dev) using `WebFetch` against:

```
https://raw.githubusercontent.com/ripienaar/free-for-dev/master/README.md
```

Pass a prompt that filters for the user's category (e.g. "list free-tier Postgres hosting providers and their limits"). Do not dump the whole README into the conversation; extract only what the user asked for, and cite the service name plus the relevant free-tier limits.
