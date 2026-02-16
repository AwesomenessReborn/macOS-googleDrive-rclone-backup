# Backup Framework

## Purpose
Automated backup system for `/Dev/projects` to Google Drive using rclone.
- Backs up all code and data files
- Excludes build artifacts (node_modules, .venv, etc.)
- Utilizes 2TB Google One storage efficiently

## Current Setup
- **Source:** `/Users/hareee234/Dev/projects`
- **Destination:** `gdrive:Backups/Dev` (Google Drive)
- **Exclusions:** See `.rclone-exclude` file
- **Automation:** Cron job runs twice daily — 12:30 PM and 11:00 PM (midday catch if Mac sleeps at night)

## Dev Folder Layout

```
/Dev/
├── projects/        ← code repos (backed up automatically to gdrive:Backups/Dev)
│   ├── st-work/     ← ST research projects
│   ├── tt/          ← other projects
│   └── ...
├── data/            ← large datasets, recordings, raw CSVs (NOT backed up automatically)
│   ├── krishna-dodge-recordings/
│   ├── gait_app_debug/
│   ├── Head movement data collection/
│   ├── parsed-glasses-data-collection-logs/
│   └── Blood pressure app screenahots/
└── backup-framework/ ← this project
```

**Important**: `/Dev/data/` is intentionally excluded from the automatic backup sync.
To archive a dataset to Google Drive manually:
```bash
rclone copy /Users/hareee234/Dev/data/<folder> gdrive:Archive/data/<folder> --progress
```
To restore a dataset locally:
```bash
rclone copy gdrive:Archive/data/<folder> /Users/hareee234/Dev/data/<folder> --progress
```

## Scripts

### `backup-to-gdrive.sh`
Main backup script that syncs Dev folder to Google Drive.
- Automatically excludes build artifacts
- Shows progress during sync
- Safe to run multiple times (incremental sync)
- Logs timestamped start/end lines to `backup.log` for auditability

### `restore-from-gdrive.sh`
Restores projects from Google Drive backup.
- Use when setting up new machine or recovering deleted projects

### `check-disk-usage.sh`
Shows disk usage breakdown of Dev projects.
- Identifies large folders
- Helps decide what to clean up (512GB SSD)

### `clean-project.sh`
Safely removes build artifacts from a project before deletion.
- Useful before deleting old projects to free up space

## Common Tasks

### New Project
Just create it anywhere in `/Dev/projects`:
```bash
cd /Dev/projects/st-work
mkdir new-project
cd new-project
# Work normally - backup happens automatically
```

### Manual Backup
```bash
/Users/hareee234/Dev/backup-framework/backup-to-gdrive.sh
```

### Check What Would Be Backed Up
```bash
rclone sync /Users/hareee234/Dev/projects gdrive:Backups/Dev \
  --exclude-from /Users/hareee234/Dev/backup-framework/.rclone-exclude \
  --dry-run --verbose
```

### Restore a Deleted Project
```bash
/Users/hareee234/Dev/backup-framework/restore-from-gdrive.sh project-name
```

### Free Up Disk Space
```bash
# Check what's using space
/Users/hareee234/Dev/backup-framework/check-disk-usage.sh

# Delete old project (it's backed up in Google Drive)
rm -rf /Users/hareee234/Dev/projects/old-project
```

## Maintenance

### Update Exclusion Patterns
Edit `.rclone-exclude` to add/remove patterns, then run backup.

### Verify Backup
```bash
rclone ls gdrive:Backups/Dev | head -20
```

### Check Backup Size
```bash
rclone size gdrive:Backups/Dev
```

## Setup on New Machine
1. Install rclone: `brew install rclone`
2. Configure Google Drive: `rclone config` (name: `gdrive`)
3. Clone this repo: `git clone <repo-url>`
4. Restore all projects: `./restore-from-gdrive.sh`

## Notes
- 512GB SSD - keep only active projects locally
- Old/inactive projects can be deleted (backed up in Google Drive)
- Code repos also backed up to GitHub (double backup)
- Data files (.csv, .json) only backed up to Google Drive
