# ============================================================== #
#                GLOBAL CONFIGURATION TEMPLATE                   #
# ============================================================== #

function global_config_template {
cat <<EOF
# =============================================================================== #
#             G L O B A L    R E S C R I P T    C O N F I G U R A T I O N         #
# =============================================================================== #
# Variables defined here will act as defaults for all your repository profiles.
# If a repository profile sets a different value for the same variable, the
# repository's value will override the global value here.
# ------------------------------------------------------------------------------- #

# ------------------------------------------------------------------------------- #
# RETENTION POLICIES
# ------------------------------------------------------------------------------- #
# Keep Policies (leave blank if not used)
KEEP_LAST=""
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"
KEEP_WITHIN=""
KEEP_TAG=""

# ------------------------------------------------------------------------------- #
# NOTIFICATIONS AND POLICIES
# ------------------------------------------------------------------------------- #
# CLEAN: determine when it will execute forget, prune and check (i.e.: 7minutes, 7hours, 7days); by default is set to 7 days.
CLEAN="7days"

# CONFIRMATION_EMAIL: set to "yes" to receive email with output when job finished successfully.
CONFIRMATION_EMAIL=""

# WEBHOOK_URL: set to a Discord/Slack webhook URL to receive push notifications.
WEBHOOK_URL=""

# EMAIL: put your email address to receive emails with output when something fails (when using cron only).
EMAIL=""

# LOGGING: set to "yes" to save a log with output when using the automatic function (by default is set to yes).
LOGGING="yes"

# LOG_RETENTION: number of days to keep logs (e.g., 30). Leave blank to keep all logs forever.
LOG_RETENTION=""

# ------------------------------------------------------------------------------- #
# EXECUTION HOOKS
# ------------------------------------------------------------------------------- #
# PRE_CMD: command to run before the automatic backup starts.
# Commands here will execute globally across all manual or automatic backups.
PRE_CMD=""

# POST_CMD: command to run after the automatic backup finishes successfully.
POST_CMD=""

# ------------------------------------------------------------------------------- #
# BACKUP PREFERENCES
# ------------------------------------------------------------------------------- #
# RESTIC_COMPRESSION: set to "auto", "max" or "off" to configure data compression (requires restic 0.14.0+).
RESTIC_COMPRESSION="auto"

# EXCLUDE_CACHE: set "yes" to use "--exclude-cache" flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
EXCLUDE_CACHE="yes"

# EXCLUDE_FILE: set "yes" to use the exclude file generated for backups (by default is set to yes; if blank it will read the exclusion file for previous versions comptability).
EXCLUDE_FILE="yes"

# HOST: use a custom hostname for your snapshots across all repositories.
HOST=""

# ONE_FILE_SYSTEM: set to "yes" to use "--one-file-system" flag for backups.
ONE_FILE_SYSTEM=""

# SHOW_SNAPS: set to "yes" to show a list of snapshots at the end of the backup.
SHOW_SNAPS="yes"

# SHOW_STATS: set to "yes" to calculate and display repository stats at the end.
SHOW_STATS="yes"

# SKIP_OFFICE: set to yes to temporarily exclude open (in use) "office" documents.
SKIP_OFFICE=""
EOF
}
