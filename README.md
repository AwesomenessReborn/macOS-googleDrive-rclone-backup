# Dev Backup Framework

Automated backup system for `/Dev/projects` to Google Drive using rclone.

## Quick Start

1. **Install rclone:**
   ```bash
   brew install rclone
   ```

2. **Configure Google Drive:**
   ```bash
   rclone config
   ```
   - Name: `gdrive`
   - Storage: Google Drive
   - Follow browser auth flow
   - Choose "Full access" scope

3. **Run first backup:**
   ```bash
   ./backup-to-gdrive.sh
   ```

4. **Set up automatic daily backups (optional):**
   ```bash
   crontab -e
   # Add this line:
   0 23 * * * /Users/hareee234/Dev/backup-framework/backup-to-gdrive.sh >> /Users/hareee234/Dev/backup-framework/backup.log 2>&1
   ```

## Scripts

| Script | Description |
|--------|-------------|
| `backup-to-gdrive.sh` | Main backup script (run anytime) |
| `check-disk-usage.sh` | See what's using space on your 512GB SSD |
| `restore-from-gdrive.sh` | Restore deleted projects from backup |
| `clean-project.sh` | Remove build artifacts before deleting a project |

## Usage Examples

### Start a new project
```bash
cd /Dev/projects/st-work
mkdir my-new-project
cd my-new-project
# Work normally - backup happens automatically (if cron is set up)
```

### Free up disk space
```bash
# See what's using space
./check-disk-usage.sh

# Clean old project before deletion
./clean-project.sh /Users/hareee234/Dev/projects/old-project

# Delete it (it's backed up!)
rm -rf /Users/hareee234/Dev/projects/old-project
```

### Restore a deleted project
```bash
./restore-from-gdrive.sh project-name
```

### Verify backup
```bash
rclone ls gdrive:Backups/Dev | head -20
rclone size gdrive:Backups/Dev
```

## What Gets Backed Up?

✅ **Included:**
- Source code (.py, .js, .java, etc.)
- Data files (.csv, .json, .txt)
- Configuration (.env, .yaml, etc.)
- Documentation (.md, .pdf)

❌ **Excluded (see `.rclone-exclude`):**
- `node_modules/`
- `.venv/`, `venv/`
- `build/`, `dist/`
- `.git/` (use GitHub for code versioning)
- Cache folders
- Log files

## Backup Strategy

1. **Code:** Git repos → GitHub (primary) + Google Drive (secondary)
2. **Data:** CSV, JSON, recordings → Google Drive only
3. **Full system:** Time Machine (if available)

## 512GB SSD Management

- Keep only **active projects** in `/Dev/projects`
- Delete old projects (they're in Google Drive)
- After restoring a project, reinstall dependencies:
  ```bash
  npm install              # Node.js
  pip install -r requirements.txt  # Python
  ```

## Customization

Edit `.rclone-exclude` to add/remove exclusion patterns, then run backup again.

---

**See `CLAUDE.md` for detailed documentation.**
