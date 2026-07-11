function config_file {
cat <<EOF
# =============================================================================== #
#                   R E S C R I P T    C O N F I G U R A T I O N                  #
# =============================================================================== #
# You need to set your restic password (password for the repository), the
# directory for your repository, the backup directory (by default the backup
# directory is your Home directory), your tag (empty by default if used) and
# your "keep" and "excludes" policies.
# ------------------------------------------------------------------------------- #
# REQUIRED VALUES
# ------------------------------------------------------------------------------- #
# Set restic password, repository location/directory and backup directory.
RESTIC_PASSWORD=""
RESTIC_REPO=""
BACKUP_DIR="$HOME"

# Keep Policies (leave blank if not used)
KEEP_LAST=""
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"
KEEP_WITHIN=""
KEEP_TAG=""

# AWS, B2, Azure, Google Cloud Credentials; for other not listed here you can
# the values here (leave blank if not used).
AWS_ID=""
AWS_KEY=""
AZURE_NAME=""
AZURE_KEY=""
B2_ID=""
B2_KEY=""
GOOGLE_ID=""
GOOGLE_CREDENTIALS=""

# ------------------------------------------------------------------------------- #
# OPTIONAL VALUES
# ------------------------------------------------------------------------------- #
# CLEAN: determine when it will execute forget, prune and check (i.e.: 7minutes, 7hours, 7days); by default is set to 7 days.
# CONFIRMATION_EMAIL: set to "yes" to receive email with output when job finished successfully.
# DESTINATION: display name of your destination in output instead of path (i.e.: Wasabi, B2, etc.).
# EMAIL: put your email address to receive emails with output when something fails (when using cron only).
# EXCLUDE_FILE: set "yes" to use the exclude file generated for backups (by default is set to yes; if blank it will read the exclusion file for previous versions comptability).
# EXCLUDE_CACHE: set "yes" to use "--exclude-cache" flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
# HOST: use a custom hostname for your snapshots.
# LOGGING: set to "yes" to save a log with output when using the automatic function (by default is set to yes).
# LOG_RETENTION: number of days to keep logs (e.g., 30). Leave blank to keep all logs forever.
# ONE_FILE_SYSTEM: set to "yes" to use "--one-file-system" flag for backups.
# POST_CMD: command to run after the automatic backup finishes successfully.
# PRE_CMD: command to run before the automatic backup starts.
# RESTIC_COMPRESSION: set to "auto", "max" or "off" to configure data compression (requires restic 0.14.0+).
# SHOW_SNAPS: set to "yes" to show a list of snapshots at the end of the backup.
# SHOW_STATS: set to "yes" to calculate and display repository stats at the end.
# SKIP_OFFICE: set to yes to temporarily exclude open (in use) "office" documents.
# TAG: tag your snapshots.
# WEBHOOK_URL: set to a Discord/Slack webhook URL to receive push notifications.
CLEAN="7days"
CONFIRMATION_EMAIL=""
WEBHOOK_URL=""
DESTINATION=""
EMAIL=""
EXCLUDE_FILE="yes"
EXCLUDE_CACHE="yes"
HOST=""
LOGGING="yes"
LOG_RETENTION=""
ONE_FILE_SYSTEM=""
POST_CMD=""
PRE_CMD=""
RESTIC_COMPRESSION="auto"
SHOW_SNAPS="yes"
SHOW_STATS="yes"
SKIP_OFFICE=""
TAG=""
EOF
}
