# ============================================================== #
#                     CONFIGURATION TEMPLATE                     #
# ============================================================== #

config_file() {
cat <<EOF

# -------------------------------------------------------------- #
#          R E S C R I P T    C O N F I G U R A T I O N          #
# -------------------------------------------------------------- #

# For detailed documentation on all available options and how to configure them,
# please visit: https://github.com/sulfuror/rescript-sh/wiki/Configuration-Files

# -------------------------------------------------------------- #
# -------------------------------------------------------------- #

# REQUIRED SETTINGS

# -------------------------------------------------------------- #
#                       RESTIC_PASSWORD=""                       #
#                   RESTIC_PASSWORD_COMMAND=""                   #
#                         RESTIC_REPO=""                         #
#                      BACKUP_DIR=("$HOME")                      #
# -------------------------------------------------------------- #

# REPOSITORY SETTINGS (Optional)

# -------------------------------------------------------------- #
#                         DESTINATION=""                         #
#                             TAG=""                             #
# -------------------------------------------------------------- #

# CLOUD CREDENTIALS (Optional)

# -------------------------------------------------------------- #
# UNCOMMENT THE CREDENTIALS FOR YOUR SPECIFIC CLOUD PROVIDER IF NOT USING LOCAL STORAGE. #
#                           AWS_ID=""                            #
#                           AWS_KEY=""                           #
#                         AZURE_NAME=""                          #
#                          AZURE_KEY=""                          #
#                            B2_ID=""                            #
#                           B2_KEY=""                            #
#                          GOOGLE_ID=""                          #
#                     GOOGLE_CREDENTIALS=""                      #
# -------------------------------------------------------------- #

# OVERRIDE GLOBAL SETTINGS (Optional)
