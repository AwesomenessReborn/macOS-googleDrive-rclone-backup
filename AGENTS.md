# AGENTS.md

## What this repo is
Shell scripts that back up `/Users/hareee234/Dev/projects` to Google Drive via rclone. No build system, no dependencies — just bash/zsh.

## Critical context

**Machine-specific paths** — all scripts hardcode `/Users/hareee234/Dev/projects` as source and `gdrive:backups/dev` as rclone destination. Do not generalize or parameterize without asking.

**rclone remote name**: `gdrive` (configured via `rclone config`). Destination path is `gdrive:backups/dev` — case-sensitive, lowercase.

**Cron schedule**: runs twice daily at 12:30 PM and 11:00 PM. The `backup-to-gdrive.sh` script prepends `/opt/homebrew/bin` to PATH so rclone is found in non-interactive cron shells.

## Developer commands

| Task | Command |
|---|---|
| Run backup manually | `./backup-to-gdrive.sh` |
| Dry-run (preview changes) | `rclone sync /Users/hareee234/Dev/projects gdrive:backups/dev --exclude-from .rclone-exclude --dry-run --verbose` |
| Restore single project | `./restore-from-gdrive.sh <project-name>` |
| Restore all projects | `./restore-from-gdrive.sh --all` |
| Check disk usage | `./check-disk-usage.sh` |
| Clean artifacts before delete | `./clean-project.sh <project-path>` |
| Tree-view git status of all repos | `./show-git-status.zsh` |

## File roles

- **`.rclone-exclude`** — exclusion patterns for rclone (node_modules, venvs, build dirs, caches, logs). Edit here to change what gets backed up.
- **`last-backup-status`** — written by `backup-to-gdrive.sh` with `status=`, `time=`, `files=`, `size=` keys. Used by terminal prompt to show last backup state.
- **`backup.log`** — timestamped start/end lines appended on each run. Ignored by `.gitignore` (may be untracked).

## Storage strategy (don't break this)

- Code lives in `/Dev/projects/` → backed up by rclone to `gdrive:backups/dev`
- Research data/CSVs/recordings go to Google Drive desktop app mount, **not** to `/Dev/` — they stream on demand and must not fill the 512GB SSD
- Never save data to `.tmp/` inside the Google Drive mount — it's an internal staging area, not reliable storage
- The `backups/dev/` folder appears in the streamed Google Drive mount at `My Drive/backups/dev/` but takes negligible local disk — files are metadata-only until opened. This is expected and not a duplication issue.
- `st-work` has two distinct roles: `My Drive/st-work/` is the data archive (CSVs, recordings, shareable via Drive links), while `/Dev/projects/st-work/` is the code home (repos on GitHub, backed up via rclone). Same folder names appear in both but contain different content — this is by design.

## Setup on new machine

1. `brew install rclone`
2. `rclone config` → create remote named `gdrive` (Google Drive, full access)
3. Clone this repo
4. `./restore-from-gdrive.sh --all`
5. Install Google Drive desktop app for streamed data access
