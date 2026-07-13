# Rescript - POSIX-compliant Bash shell wrapper for Restic
---
## About
---
`rescript` is a POSIX-compliant Bash shell wrapper for [Restic](https://restic.net/) that makes it easy to configure repositories and work with them. The script was made for GNU/Linux systems but it may also work on MacOS and FreeBSD.

### Index
1. [Mac and FreeBSD](#mac-and-freebsd)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Command and Options](#commands-and-options)
5. [Security](#security)
6. [Adding a Cron Job](#adding-a-cron-job)
7. [Some Things Worth to Mention](#some-things-worth-to-mention)
8. [Workarounds](#workarounds)
9. [Having Problems?](#having-problems)
10. [Remove rescript](#remove-rescript)

> [!warning] DISCLAIMER / USE AT YOUR OWN RISK
> I'm not a developer, programmer or anything related; I'm just a regular user sharing my basic knowledge. I created this for my personal use but decided to share it because when I was looking for something like this, I did not find something that could fulfill my expectations. I know maybe there are some things in my script that can be done in a different way, better or even more easily but unfortunately I don't have enough knowledge. You're more than welcome to get in touch if you want to contribute, fix, add something, etc.

## Mac and FreeBSD
---
### Mac OS:

1. Install [brew](https://brew.sh).
2. Install `coreutils` as follows: `brew install coreutils`.
3. Install `gnu-sed` as follows: `brew install gnu-sed --with-default-names`.
4. **NOTE**: `nano` works great as a default text editor; choosing another one with Mac
   could require a little tweaking with your script.
5. **OPTIONAL**: to include `~/bin` or `~/.local/bin` in your `PATH`, edit or create
   a file called `.bash_profile` in your `$HOME` by typing `nano .bash_profile`
   and after pasting this following line save it and close it using Ctl+x:
   ```
   export PATH=$PATH:$HOME/bin:$HOME/.local/bin
   ```
6. In order to use `mounter` (`restic mount`) you need to install a package
   called `osxfuse` via `brew`: `brew install osxfuse`. If you're using Mojave,
   you may need to type: `brew cask install osxfuse` or follow the instructions
   displayed in your terminal emulator when you typed the first command.

### FreeBSD:

1. Install `coreutils` package by typing: `pkg install coreutils`.
2. Set the `PATH` for your `~/bin` or `~/.local/bin`.
3. `csh` work just fine with `rescript`.
5. I tested with FreeBSD only but I'm pretty sure it may work on other BSD systems.

> [!NOTE]
> If `~/bin` doesn't exist and you decide to use the `install` command,
`rescript` will automatically decide to use `~/.local/bin`, so before using
`install` you have to make sure to set your `$PATH` for both locations or move the
script manually to your `$PATH`.

**[⇦ Back to index](#index)**

## Installation
---

### Dependencies:
1. restic >= 0.9.2
2. wget

You can install the script using the following commands:

```
~$ git clone https://gitlab.com/sulfuror/rescript.sh.git
~$ cd rescript.sh
~$ chmod 700 rescript
~$ ./rescript install
```
|Options | Installation Directory |
| -----  |  --------------------  |
|1. System-wide | `/usr/bin` |
|2. For this user | `~/bin` or `~/.local/bin` |

If you chose the second option make sure to have these lines inside your `.profile`.

```
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```
If you don't have these lines in your `.profile` then just copy those and paste it
at the end. Once everything is set, if it's not working properly don't panic, maybe the `~/.local/bin`
wasn't there and the script created it and you only need to restart your session, or log out and login, or reboot
your computer in order for this work. The same applies if you needed to copy and paste the code mentioned above.

### Different repositories

You can use `rescript` to easily manage different repositories by creating a
configuration file for every repository (it is done via `rescript config`) and
assigning an easy name to remember for each repository.

**[⇦ Back to index](#index)**

## Usage:
---

You can use this script using an **_automatic_** function that will run `backup`,
`snapshots`, `forget`, `prune`, `check` and `stats` using your configuration
file. If your "LOGGING" variable is "yes" it will also create a log file with
the output. If you want to use the automatic function just type the following:

```
rescript [repo_name]
```
Using `rescript` this way is perfect for `cron` since you can set the configuration
file to save you a logfile, it will run all commands and if anything fails it will
send you an email (you need `mailutils` installed) using `mail` utility.
You need to setup this on your own so it can send you and email if you put your
email address in the `EMAIL` variable inside your configuration file.

Rescript has its own commands that doesn't need a `[repo_name]` indicated. These
commands are: `config`, `editor`, `help`, `install` and `version`.

Usage:

```
rescript [config|editor|help|install|version]
```

Use `rescript` commands:

```
rescript [repo_name] [command] [--flags] ...
```

Use `restic` commands:

```
rescript [repo_name] [restic_command] [flags] ...
```

For `rescript` commands info and usage:
```
rescript help [command]
```
First thing to do is to configure your repository by typing:

```bash
rescript config --wizard
```

This will launch the **Interactive Configuration Wizard** which will ask for your repository name, password, target directory, and webhooks to automatically generate your configuration file and initialize your repository.

Alternatively, you can manually run:
```bash
rescript config
```
This command will give you a menu where you can edit your existing configuration files, create new ones manually, or edit the **Global Configuration**. 

You can also bypass the menu and directly edit your global configuration by running:
```bash
rescript config --global
```
The Global Configuration (`global.conf`) allows you to define variables (like `KEEP_*` retention policies, `WEBHOOK_URL`, `EXCLUDE_FILE`, or `CLEAN` policies) that act as defaults for all your repositories! Cloud credentials and passwords remain safely isolated to your repository-specific files.

When you use the `config` command to manually create a repository configuration file, `rescript` will create a template of the configuration file for you. It will also set the permissions for those configuration files to `600`, which means that only the user who created that configuration file will have the permission over the file (read/write); no other user will be able to open and read that configuration file.

### Things you need to change in your configuration file

> [!NOTE]
> _Always put the values between the quotes to avoid globbing._

* `RESTIC_PASSWORD=""`: Put your restic password.
* `RESTIC_REPO=""`: Put your repository directory.
* `BACKUP_DIR="$HOME"`: This is what you're backing up; by default is your home directory.

> [!TIP]
> **Global Retention Policies:** You no longer need to define `KEEP_*` policies for every single repository! You can define your ideal retention policy directly in the **Global Configuration** (`global.conf`). Repositories will automatically inherit these global retention policies unless you explicitly override them in the repository's specific `.conf` file.
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
* `PRE_CMD=""`: Arbitrary system commands to run *before* the backup process, whether manual or automatic (e.g. `docker stop mycontainer`).
* `POST_CMD=""`: Arbitrary system commands to run *after* the backup process, whether manual or automatic (e.g. `docker start mycontainer`).

The configuration file also has variables for B2 and AWS ID's and Keys. If not required
just leave it blank.

### Exclusions

By default, rescript create a very simple exclusion file. You can tell rescript to build another
more complete exclusion file for you that will contain common exclusions patterns and directories
or simply build your own exclusion file by yourself. `rescript` will always create an exclusion file that
you can open and edit it as you wish. This is all done via `rescript config`.

**[⇦ Back to index](#index)**

## Commands and Options
---
There are three commands that will not work as restic usually works, which are the following:

1. **backup**: This command will run a backup according to the variables set before.
2. **help**: This command will display `rescript` help.
3. **version**: This command will display the current version of `rescript` you're using.
 
As far as I've tested, all other restic commands will run exactly as they do using restic alone. For help
with restic commands type:

```
restic help [command]
```

Please see restic `help` and [documentation](https://restic.readthedocs.io/en/stable/) for more.

### Rescript Commands

1. **all**: This is a powerful orchestrator command. It will execute the given command sequentially across *all* your configured repositories. It natively processes help flags (`-h`/`--help`) and features consistently formatted terminal headers.
   Usage:
    ```
    rescript all [command] [flags] ...
    ```
   Command flags:
    1. `-X, --ignore-repo`: skips a specific repository during the run. e.g. `rescript all backup -X repo_name`

2. **backup**: take a snapshot using the values set in your configuration file.
   Usage:
    ```
    rescript [repo_name] backup [flags]
    ```
   Command flags:
    1. `-C, --check`: check for errors in repository.
    2. `-U, --cleanup`: apply retention policies and prune (see `cleanup` command).
    3. `-I, --info`: display stats for the latest and all snapshots.
    4. `-O, --skip-office`: temporarily exclude open "Office Documents".
    
3. **cleanup**: this will perform `forget` according to the policies in your configuration file and `prune`.
   Usage:
    ```
    rescript [repo_name] cleanup [flags] [options]
    ```
   Command flags:
    1. `-C, --check`: check for errors in repository.
    2. `-I, --info`: display stats for the latest and all snapshots.
    3. `--reset`: remove "datefile"; it resets the dates for the CLEAN option.

4. **diff**: this command replaces the deprecated `changes`. It automatically compares the two most recent snapshots. If you pass specific restic arguments, it will transparently act as a wrapper for `restic diff`.
   Usage:
    ```
    rescript [repo_name] diff [flags] [options]
    ```

5. **env**: display the variable values in your configuration file.
   Usage:
    ```
    rescript [repo_name] env [flags] [VARNAME]
    ```

6. **extract**: extract a single file or directory from a specific snapshot into your local machine. Features a custom progress bar and color-coded validation for success/failure. If no snapshot ID is provided, it auto-detects the latest snapshot containing that file.
   Usage:
    ```
    rescript [repo_name] extract [snapshot-ID] <file_path>
    ```

7. **history**: display a detailed history (timeline) of a specific file or folder across all snapshots. This command tracks the *actual evolution* of the file by comparing sizes and modification dates, skipping identical consecutive snapshots.

   > [!TIP]
   > **Pro-Tip:** You can use the `**` wildcard to recursively search through any number of nested subdirectories. This is extremely useful to find a file deeply buried inside a specific path without knowing its exact depth. Example:
   > ```bash
   > rescript [repo_name] history "/path/to/folder/**/file.txt"
   > ```
   
   Usage:
    ```
    rescript [repo_name] history <pattern>
    ```

8. **info**: this command will display stats for latest and all snapshots in a custom formatted table.

9. **logs**: this command needs an option. It can be used to display saved logs, display output in logs, and remove logs. It automatically lists logs in a custom layout providing the total file count and location path.
    Usage:
     ```
     rescript [repo_name] logs [--view=|-W ] [log-name]
     rescript [repo_name] logs [--remove=|-R ] [log-name]
     ```
10. **mounter**: this option will mount your repository in your `/home`.
    Usage:
     ```
     rescript [repo_name] mounter [--background]
     ```
    The new `--background` flag allows you to mount the repository without locking your terminal session. A PID file is created in `/tmp`.

11. **next**: displays the next scheduled automatic cleanup time. This command will read the CLEAN variable in your configuration file and tell you when the next cleanup and check is scheduled to occur.
    Usage:
     ```
     rescript [repo_name] next [flags]
     ```

12. **restorer**: restore the snapshot you want to restore. It will automatically create a new folder in your home directory called `restore-snapshotID-randomnumber`. You can also run it interactively to select from a menu of snapshots.

     ```bash
     rescript [repo_name] restorer [-i|--interactive] [-H|--host=host] [-P|--path=path] [-Z|--snapshot=snapshot ID] [-T|--tag=tag]
     ```

13. **search**: quickly search for a specific file or directory across all your snapshots.
    Usage:
     ```
     rescript [repo_name] search [query]
     ```

14. **size**: calculate the exact size of a specific snapshot ID or path. Features a custom progress bar. If no snapshot is specified, it defaults to 'latest'.
    Usage:
     ```
     rescript [repo_name] size [snapshot-ID] <path>
     ```

15. **snaps**: this command is simply `snapshots --compact` wrapped up in a custom Rescript-styled table. You may use it with any restic flags.

16. **umounter**: elegantly kill any background mounter processes and unmount the repository safely.
    Usage:
     ```
     rescript [repo_name] umounter
     ```

17. **unlocker**: this command WILL NOT unlock your restic repository. It deletes the temporary `.lock` file created by the script if it got stuck due to a forceful exit.

18. **upgrade**: easily upgrade your restic repository to the newer v2 repository format.

### Rescript Global Flags

You can mix Rescript and Restic flags naturally.

Usage:
```
rescript [repo_name] [command] [flags]
```

1. **`-D, --debug`**: Enable trace debugging (`set -xv`) for the script.
2. **`-E, --email`**: force sending an email with output.
3. **`-h, --help`**: display help for a specific command.
4. **`-L, --log`**: Create a logfile for this specific manual run.
5. **`-Q, --quiet`**: silence output. If you use `--log` it will still log the output.
6. **`-S, --simulate`**: Performs a dry-run of destructive commands like `backup` or `cleanup`, printing the exact restic command that would be run without actually modifying the repo.
7. **`-T, --timer`**: display output with date, time and duration at the end of execution.

Make use of `rescript` global flags with `restic` commands normally:
```
rescript [repo_name] [restic_command] -L -Q [restic_flags] ...
```

**[⇦ Back to index](#index)**

## Security
---
By default, the configuration files are as secure as your computer/user. `rescript` itself does not
contain any information about your repositories. Configuration files hold that information and when
a configuration file is created, it is created inside the user's home directory with `chmod 600` for the file,
so if another user is navigating through the user's files, they can see the file but not the content.

> [!WARNING]
> Because `PRE_CMD` and `POST_CMD` are executed via `eval`, it is critical that configuration files are never world-writable (i.e. permissions should be `600`). If a malicious user can write to the `.conf` file, they can inject arbitrary commands that will run with your privileges (e.g. as `root` if running from cron).

If you share a user in your computer or you are just paranoid, then you should create a password file for your
repository and encrypt it. Using GPG is a great way to do this and all you need to do (after creating your encrypted password file)
in the configuration file is edit the password variable as follows:
```
RESTIC_PASSWORD="$(cat <(gpg -qd /path/to/your/password_file.gpg))"
```
Since GPG will ask for your passphrase, this will not work with automatic jobs (such as using `cron`). You can edit
the time for your keyring to remember your passphrase. **_DO NOT save your passphrase in plain text or to your keyring_**; that's
bad practice and it is as secure as not using encryption at all.

Another option is to not save your password in your configuration file and export `RESCRIPT_PASS`. As long as your session
is active, this variable will work. Once the session is closed you will need to export this variable again. Use it as follows:
```
~$ export RESCRIPT_PASS=mytotallysecurepassword
```

**[⇦ Back to index](#index)**

## Adding a Cron Job
---
You can use a cron job to run backups automatically. You'll need to open your 
terminal emulator and edit your crontab file by typing `crontab -e` and pressing `Enter`.
After that you need to add a new cronjob like `10 */2 * * * /PATH/TO/YOUR/rescript [repo_name]`.
This cron job will execute every two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /PATH/TO/YOUR/rescript [repo_name]`.

If you do this your `crontab` will look like this:

```
0 */4 * * * /PATH/TO/YOUR/rescript [repo_name]
```

You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

**[⇦ Back to index](#index)**

## Some things worth to mention
---
This script will create one (1) directory (`.rescript`) in your $HOME and
three (3) subdirectories: `config`, `lock` and `logs`.

`config` directory will contain the `rescript` `repo_name.conf` file, the `repo_name-datefile`
and the `repo_name-exclusions`. If you have multiple repositories, this subdirectory
will contain those three files for every repository.

`lock` directory will always be empty except when `rescript` is running. `rescript`
creates a temporary file called `repo_name.lock` every time it runs and the file
should be removed at the end of every operation. This "lock" prevents other
processes from running if `rescript` is already running and is not finished yet. For example:
you set scheduled jobs but you forgot and tried to make a `prune`. If the scheduled
job is not finished it will display a message telling you that `rescript` is already
running, so you'll have to wait until `rescript` finishes to do what you want to do.
This way `rescript` prevents possible problems with your repository.

`logs` directory is used to save `rescript` logs.

### Why the "datefile"?

The `datefile` is created by the script in the first run. This file will be placed 
inside `.rescript/config` and it will be called `repo_name-datefile`. 
_**Why is it there?**_ I liked the way my script was, but I really didn't want to do
the `check`, `forget` and `prune` commands every day or even in every run of the script.
So, I found a way to play with the dates to make this happen, which involved creating a 
file where the script could read and write dates. The `datefile` will only contain
one date and that is 7 days from the moment you run the script for the first time
(this 7 days is by default but you can change it in the "CLEAN" value).
_**So, what does this mean?**_ It means that every time the script runs, before running
`check`, `forget` and `prune` it will read the date in your `datefile` and if those
seven days have not passed yet (again, you can change the days), then it'll not run
the `check`, `forget` and `prune`. When it's time to run `check`, `forget` and `prune`
the script will run all three operations and it'll override the date in the file
created. If, for some reason the file is deleted then the script will not know 
and it will run `check`, `forget` and `prune` according to your policies and 
it will create the `datefile` again adding the date for the next "cleaning" run.
If you do not wish to use this option you can leave the "CLEAN" variable _blank_;
the `datefile` will be created anyways but it will do nothing.

**[⇦ Back to index](#index)**

## Workarounds
---
### Backing up more than one directory

You can backup more than one location at the same time
using the same configuration file. Just open your configuration file and edit
the following line:
```
BACKUP_DIR="/path/to/dir/1 /path/to/dir/2"
```
This is not exactly a workaround but with earlier versions you can't do that
unless you have edited the script to do so.


## Having problems?
---
If you have any problem with the script you can reach out so it can be fixed.
If you have any problem using restic check out the [restic forum](https://forum.restic.net/);
maybe you can find answers or submit a question about your problem. I'm not affiliated
with the **restic** team in any way.

**[⇦ Back to index](#index)**

## Remove rescript
---
If installed system-wide:
```
sudo rm -f /usr/bin/rescript
```
In all cases, remember that you will still have the `.rescript` hidden directory
in your `$HOME` directory. If you didn't store your repository credentials elsewhere,
make sure to backup this directory or copy the configuration files located in
`$HOME/.rescript/config/repo_name.conf` before deleting this directory.

**[⇦ Back to index](#index)**