# ============================================================== #
#                     CONFIGURATION TEMPLATE                     #
# ============================================================== #
config_file() {
cat <<EOF
# =============================================================================== #
#                   R E S C R I P T    C O N F I G U R A T I O N                  #
# =============================================================================== #
# For detailed documentation on all available options and how to configure them,
# please visit: https://github.com/sulfuror/rescript-sh/wiki/Configuration-Files
# =============================================================================== #

# ------------------------------------------------------------------------------- #
# REQUIRED SETTINGS
# ------------------------------------------------------------------------------- #
RESTIC_PASSWORD=""
RESTIC_PASSWORD_COMMAND=""
RESTIC_REPO=""
BACKUP_DIR=("$HOME")

# ------------------------------------------------------------------------------- #
# REPOSITORY SETTINGS (Optional)
# ------------------------------------------------------------------------------- #
DESTINATION=""
TAG=""

# ------------------------------------------------------------------------------- #
# CLOUD CREDENTIALS (Optional)
# ------------------------------------------------------------------------------- #
# Uncomment the credentials for your specific cloud provider if not using local storage.
# AWS_ID=""
# AWS_KEY=""
# AZURE_NAME=""
# AZURE_KEY=""
# B2_ID=""
# B2_KEY=""
# GOOGLE_ID=""
# GOOGLE_CREDENTIALS=""

# ------------------------------------------------------------------------------- #
# OVERRIDE GLOBAL SETTINGS (Optional)
# ------------------------------------------------------------------------------- #
# Uncomment any of the following variables to override your global.conf defaults.
#
# -- Retention --
# KEEP_LAST=""
# KEEP_HOURLY=""
# KEEP_DAILY=""
# KEEP_WEEKLY=""
# KEEP_MONTHLY=""
# KEEP_YEARLY=""
# KEEP_WITHIN=""
# KEEP_TAG=""
#
# -- Notifications & Logs --
# CLEAN=""
# EMAIL=""
# CONFIRMATION_EMAIL=""
# WEBHOOK_URL=""
# CONFIRMATION_WEBHOOK=""
# LOGGING=""
# LOG_RETENTION=""
# 
# -- Hooks --
# PRE_CMD=""
# POST_CMD=""
#
# -- Backup Preferences --
# RESTIC_COMPRESSION=""
# EXCLUDE_CACHE=""
# EXCLUDE_FILE=""
# HOST=""
# ONE_FILE_SYSTEM=""
# SHOW_SNAPS=""
# SHOW_STATS=""
# SKIP_OFFICE=""
#
# -- System Preferences --
# RESCRIPT_EDITOR=""
EOF
}
