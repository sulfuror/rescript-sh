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
# Or, if using a password manager/command (leave RESTIC_PASSWORD empty):
RESTIC_PASSWORD_COMMAND=""
RESTIC_REPO=""
BACKUP_DIR="$HOME"

# ------------------------------------------------------------------------------- #
# CLOUD CREDENTIALS
# ------------------------------------------------------------------------------- #
# Provide the necessary credentials for your cloud provider (leave blank if local).
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
# DESTINATION: display name of your destination in output instead of path (i.e.: Wasabi, B2, etc.).
DESTINATION=""

# TAG: tag your snapshots.
TAG=""

# ------------------------------------------------------------------------------- #
# OVERRIDE GLOBAL VARIABLES
# ------------------------------------------------------------------------------- #
# The following variables can be defined globally in ~/.rescript/config/global.conf
# If you wish to OVERRIDE the global value for this specific repository only, 
# uncomment the variable below and assign your new value.

# Backup Preferences
# EXCLUDE_FILE="yes"
# HOST=""
# SKIP_OFFICE=""

# Notifications and Output
# SHOW_SNAPS="yes"
# SHOW_STATS="yes"

# ------------------------------------------------------------------------------- #
# RETENTION POLICIES
# ------------------------------------------------------------------------------- #
# Keep Policies (leave blank if not used)
# KEEP_LAST=""
# KEEP_HOURLY="8"
# KEEP_DAILY="7"
# KEEP_WEEKLY="4"
# KEEP_MONTHLY="12"
# KEEP_YEARLY="10"
# KEEP_WITHIN=""
# KEEP_TAG=""

# ------------------------------------------------------------------------------- #
# NOTIFICATIONS AND POLICIES
# ------------------------------------------------------------------------------- #
# CLEAN: determine when it will execute forget, prune and check (i.e.: 7minutes, 7hours, 7days); by default is set to 7 days.
# CLEAN="7days"

# CONFIRMATION_EMAIL: set to "yes" to receive email with output when job finished successfully.
# CONFIRMATION_EMAIL=""

# WEBHOOK_URL: set to a Discord/Slack webhook URL to receive push notifications.
# WEBHOOK_URL=""

# EMAIL: put your email address to receive emails with output when something fails (when using cron only).
# EMAIL=""

# LOGGING: set to "yes" to save a log with output when using the automatic function (by default is set to yes).
# LOGGING="yes"

# LOG_RETENTION: number of days to keep logs (e.g., 30). Leave blank to keep all logs forever.
# LOG_RETENTION=""

# ------------------------------------------------------------------------------- #
# EXECUTION HOOKS
# ------------------------------------------------------------------------------- #
# PRE_CMD: command to run before the automatic backup starts.
# PRE_CMD=""

# POST_CMD: command to run after the automatic backup finishes successfully.
# POST_CMD=""

# ------------------------------------------------------------------------------- #
# BACKUP PREFERENCES
# ------------------------------------------------------------------------------- #
# RESTIC_COMPRESSION: set to "auto", "max" or "off" to configure data compression (requires restic 0.14.0+).
# RESTIC_COMPRESSION="auto"

# EXCLUDE_CACHE: set "yes" to use "--exclude-cache" flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
# EXCLUDE_CACHE="yes"

# ONE_FILE_SYSTEM: set to "yes" to use "--one-file-system" flag for backups.
# ONE_FILE_SYSTEM=""
EOF
}
