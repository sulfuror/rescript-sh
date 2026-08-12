# ============================================================== #
#                 GLOBAL CONFIGURATION TEMPLATE                  #
# ============================================================== #

global_config_template() {
cat <<EOF

# -------------------------------------------------------------- #
#  G L O B A L    R E S C R I P T    C O N F I G U R A T I O N   #
# -------------------------------------------------------------- #

# For detailed documentation on all available options and how to configure them,
# please visit: https://github.com/sulfuror/rescript-sh/wiki/Configuration-Files

# -------------------------------------------------------------- #
# VARIABLES DEFINED HERE WILL ACT AS DEFAULTS FOR ALL YOUR REPOSITORY PROFILES. #
# -------------------------------------------------------------- #

# -- Retention --
KEEP_LAST=""
KEEP_HOURLY="8"
KEEP_DAILY="7"
KEEP_WEEKLY="4"
KEEP_MONTHLY="12"
KEEP_YEARLY="10"
KEEP_WITHIN=""
KEEP_TAG=""

# -- Notifications & Logs --
CLEAN="7days"
EMAIL=""
CONFIRMATION_EMAIL=""
WEBHOOK_URL=""
CONFIRMATION_WEBHOOK=""
LOGGING="yes"
LOG_RETENTION=""

# -- Hooks --
PRE_CMD=""
POST_CMD=""

# -- Backup Preferences --
RESTIC_COMPRESSION="auto"
EXCLUDE_CACHE="yes"
EXCLUDE_FILE="yes"
HOST=""
ONE_FILE_SYSTEM=""
SHOW_SNAPS="yes"
SHOW_STATS="yes"
SKIP_OFFICE=""

# -- System Preferences --
RESCRIPT_EDITOR=""
EOF
}
