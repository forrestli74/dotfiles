# Movies Organization

This folder is dedicated to finding and organizing interesting movies to watch.

## Folder Structure

- **sources/**: Contains files for different types of movie sources, such as awards, box office hits, and personal recommendations.

- **Movie List/**: Contains individual movie files, each named after the movie title.

- `movies.db`: SQLite database tracking Movies and MovieTags.

## Database Schema

A SQLite database is used to track movies and tags:

- **Movies**
  - `name` (TEXT PRIMARY KEY)
  - `year` (INTEGER)

- **MovieTags**
  - `movie` (TEXT, references `Movies.name`)
  - `tag` (TEXT)
  - `timestamp` (TEXT)

## Common Tags

Tags can be used for genres, ratings, and other labels.

> **Important:** This list is exhaustive. **Do not add tags not described here without explicit approval.** If the user approves a new tag, update this file (`CLAUDE.md`) to include it before using the tag.

### Genres & Ratings

- `rating:g` / `rating:pg-13` / `rating:r` (content rating tags)

### Other Tags

- `memorable`
- `interested`
- `not interested`
- `seen`
- `kids`
- `烧脑` (mind-bending)
- `big budget`
- `small budget`
- `innovative`

## Score Tags

- `score:1` (Couldn't finish)
- `score:2` (Bad)
- `score:3` (Good)
- `score:4` (Memorable)
- `score:5` (Lifetime Memorable)

## Common Genres (examples)

- action
- drama
- comedy
- thriller
- sci-fi
- fantasy
- horror
- romance
- documentary
- animation
- crime

## Renaming a movie (name changes)

When a movie’s name changes, keep everything in sync by doing all three steps:

1. **Rename the movie file**
   - In `notes/movies/Movie List/`, rename the Markdown file to match the new movie name.
   - Example: `notes/movies/Movie List/Old Name.md` → `notes/movies/Movie List/New Name.md`

2. **Update the database entry**
   - Update the `Movies.name` primary key value in `movies.db` to the new name.
   - Example SQL:
     ```sql
     UPDATE Movies
     SET name = 'New Name'
     WHERE name = 'Old Name';
     ```

3. **Update the title line inside the movie file**
   - Open the renamed Markdown file and update the first line (the `# Movie Name` heading) to match the new name.

> ⚠️ Keep the name consistent across file name, database entry, and the Markdown title to avoid mismatches in tooling or queries.