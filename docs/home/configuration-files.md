---
title: Configuration Files
---
When you use `config` command to create a repository configuration file, `rescript` will create a template
of the configuration file for you. It will also set the permissions for those configuration files to `600`, which
means that only the user who created that configuration file will have the permission over the file (read/write); no other
user will be able to open and read that configuration file.

### Global Configuration (v6.0+)

Introduced in v6.0, you can now define a global configuration hierarchy. Variables defined in `~/.rescript/config/global.conf` will act as defaults and be inherited by all repository profiles unless explicitly overridden.

To easily set up or edit your global configuration, run:
```bash
rescript config --global
```
*(Note: Retention policies like `KEEP_*` have also been promoted to the global configuration, allowing you to define a single retention strategy for all repositories).*

### Things you need to change in your configuration file

> [!NOTE]
> _Always put the values between the quotes to avoid globbing._

* `RESTIC_PASSWORD=""`: Put your restic password.
* `RESTIC_PASSWORD_COMMAND=""`: (v6.0+) Use an external password manager (e.g., `pass`, `bitwarden-cli`) to dynamically extract the repository password. If this is set, `RESTIC_PASSWORD` can be left empty.
* `RESTIC_REPO=""`: Put your repository directory.
* `BACKUP_DIR="$HOME"`: This is what you're backing up; by default is your home directory.
* `KEEP_LAST=""`: Indicate the number of "last" backups you want to keep.
* `KEEP_HOURLY="8"`: Indicate the number of hourly backups you want to keep.
* `KEEP_DAILY="7"`: Indicate the number of daily backups you want to keep.
* `KEEP_WEEKLY="4"`: Indicate the number of weekly backups you want to keep.
* `KEEP_MONTHLY="12"`: Indicate the number of monthly backups you want to keep.
* `KEEP_YEARLY="10"`: Indicate the number of yearly backups you want to keep.
* `KEEP_WITHIN=""`: Keep within duration needs to be a number of years, months,
   and days, e.g. 2y5m7d will keep all snapshots made in the two years,
   five months, and seven days before the latest snapshot (taken from [original
   restic documentation](https://restic.readthedocs.io/en/stable/060_forget.html?highlight=keep-within#removing-snapshots-according-to-a-policy)).
* `KEEP_TAG=""`: Indicate the tag you want to keep; for example, if you have one specific
   snapshot that you want to keep forever, you can tag that snapshot with `keep-forever`
   and then put the `keep-forever` tag inside the "" for this variable so next `cleanup` onwards
   it will pass this specfic policy and keep all snapshots with this tag.

### Optional variables

These variables are optional because the script will still work if you don't want to setup
 a "cleanup", tag or destination.

* `CLEAN="7days"`: Indicate the number for your cleanup policy (by default is 7 days); 
   this will make sure that the script runs forget, check and prune applying your policies every
   number of minutes, hours, days, etc. (the value must be with the same syntax as the `date` command).
   You may change the number or leave it blank if you don't want the script to do this. Syntax: 7minutes, 7hours, 7days ...
* `TAG=""`: Indicate the tag you want to use for your backups between the "" or just leave it blank
   if you don't want to use tags.
* `DESTINATION=""`: Put the name of your backup destination between the "" 
   (something like S3, Google Drive, External Drive, FriendServerName, etc.). If you don't want to use
   it just leave it blank. This is just used for output purposes.
* `HOST=""`: Write the `hostname` you wish to use. This is useful when `restic` doesn't use a
   stable hostname when taking a snapshot. If your snapshots are always using the same hostname
   you don't need to change this unless you want to assign another hostname to your snapshots.
* `LOGGING="yes"`: By default `rescript` will create a log for every run of the script
   and logs will be located at `$HOME/.rescript/logs`. Commands and options will not
   create a log; logs only will be created when you run the script without any
   command and option. You can turn logging off by switching this variable from
   "yes" to "no".
* `SKIP_OFFICE=""`: Indicate "yes" between the quotes if you want to temporarily exclude open "Office Documents"
   (.xlsx, .docx, .ods, .odt, etc.). This is useful if you have this script running via cron and
   you work with "Office Documents" in a daily basis. If an Excel document, for example, is open
   at the time a backup is running this option will exclude that file only until the next backup, after
   the document is closed. This prevents storage of potentially damaged files in your repository because
   if you are editing a document while a backup is running, restic will save the document but with the possibility
   that the document will not be fully functional when restored.
* `WEBHOOK_URL=""`: (v6.0+) Put a Discord, Slack, or other webhook URL to receive Push Notifications automatically upon job completion or failure.
* `EMAIL=""`: put your email address in case you want `rescript` to send you an email if anything fails.
   This will only work if you use `rescript` with a cron job. If you just use it from your terminal, it will
   not send any emails because, well, that's not necessary since you can see what it is doing. Besides, `rescript` will
   exit and warn you if any error occurred. You need `mailutils` installed and I would recommend setting up `ssmtp`. You can
   follow [this tutorial](https://www.howtogeek.com/51819/how-to-setup-email-alerts-on-linux-using-gmail/) in order to do so or
   setup `nullmailer` using [this tutorial](https://christopherbaek.wordpress.com/2016/05/22/nullmailer-send-mail/), which is even easier than `ssmtp`; be aware
   that `ssmtp` seems not to work with Debian 10 (buster). If you don't want to receive any email, just leave this variable empty.
* `CONFIRMATION_EMAIL=""`: set to "yes" to receive email with output when job finished successfully.
* `EXCLUDE_FILE="yes"`: set "yes" to use the exclude file generated for backups (by default is set to yes; if blank it will read the exclusion file for previous versions compatibility).
* `EXCLUDE_CACHE="yes"`: set "yes" to use `--exclude-cache` flag for backups (by default is set to yes; if blank it will exclude cache for previous versions compatibility).
* `ONE_FILE_SYSTEM=""`: set to "yes" to use `--one-file-system` flag for backups.
* `LOG_RETENTION=""`: Native log rotation. Set a number of days (e.g. `30`) and Rescript will automatically prune `.rescript/logs` older than that amount.
* `PRE_CMD=""`: Arbitrary system commands to run *before* the automatic backup process (e.g. `docker stop mycontainer`).
* `POST_CMD=""`: Arbitrary system commands to run *after* the automatic backup process completes.

The configuration file also has variables for B2 and AWS ID's and Keys. If not required
just leave it blank.

### Exclusions

By default, rescript create a very simple exclusion file. You can tell rescript to build another
more complete exclusion file for you that will contain common exclusions patterns and directories
or simply build your own exclusion file by yourself. `rescript` will always create an exclusion file that
you can open and edit it as you wish. This is all done via `rescript config`.

**[⇦ Home](home)**
