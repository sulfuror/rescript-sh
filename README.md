## About rescript
`rescript` is a bash shell wrapper for [Restic](https://restic.net/) that makes easy to configure repositories and work with them.
The script was made for GNU/Linux systems but it may also work on MacOS and FreeBSD.

## Index
1. [Mac and FreeBSD](#mac-and-freebsd)
2. [Installation](#installation)
3. [Usage](#usage)
4. [Command and Options](#commands-and-options)
5. [Adding a Cron Job](#adding-a-cron-job)
6. [Some Things Worth to Mention](#some-things-worth-to-mention)
7. [Workarounds](#workarounds)
8. [Having Problems?](#having-problems)
9. [Based on...](#based-on)
10. [Remove rescript](#remove-rescript)

| **DISCLAIMER / USE AT YOUR OWN RISK** 
| --------------
|**_Use at your own risk_**. I'm not a developer, programmer or anything related; I'm just a regular user sharing my basic knowledge. I created this for my personal use but decided to share it because when I was looking for something like this, I did not find something that could fulfill my expectations. I know maybe there are some things in my script that can be done in a different way, better or even more easily but unfortunately I don't have enough knowledge. You're more than welcome to get in touch if you want to contribute, fix, add something, etc.

## Mac and FreeBSD
**Mac OS**:

1. Install [brew](https://brew.sh).
2. Install `coreutils` as follows: `brew install coreutils`.
3. Install `gnu-sed` as follows: `brew install gnu-sed --with-default-names`.
4. Install `gnu-getopt` as follows (optional; if you want to use long options you need this package): `brew install gnu-getopts`.
4. **NOTE**: `nano` works great as a default text editor; chosing another one with Mac
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
7. Installing `rescript` system-wide may not work. I advise to install it for the user.

**FreeBSD**:

1. Install `coreutils` package by typing: `pkg install coreutils`.
2. Set the `PATH` for your `~/bin` or `~/.local/bin`.
3. Install `rsync` if it is not installed yet: `pkg install rsync`.
4. `csh` work just fine with `rescript`.
5. I tested with FreeBSD only but I'm pretty sure it may work on other BSD systems.

**NOTE**: If `~/bin` doesn't exists and you decide to use `install` command,
`rescript` will automatically decides to use `~/.local/bin`, so before using
`install` you have to make sure to set your `$PATH` for both locations or move the
script manually to your `$PATH`.

**[⇦ Back to index](#index)**

## Installation:

**Dependencies**:
1. restic >= 0.9.2
2. rsync
3. wget

You can add the PPA:
```
sudo add-apt-repository ppa:sulfuror/restic-tools
sudo apt update
sudo apt install rescript
```
To add the repository manually in Debian and others (must be `root`):
```
echo -e 'deb http://ppa.launchpad.net/sulfuror/restic-tools/ubuntu bionic main\rdeb-src http://ppa.launchpad.net/sulfuror/restic-tools/ubuntu bionic main' > /etc/apt/sources.list.d/restic-tools.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0FC71A57B62F6780
apt update
apt install rescript
```

Good thing about the PPA is that I manage to upload the `restic` binaries and
if you install `rescript` this way, it will automatically download `restic` 
and `rsync` (if not installed).

You can download the `.deb` package in the [relase page](https://gitlab.com/sulfuror/rescript.sh/releases)
and execute the following command:
```
sudo dpkg -i rescript*.deb
```

You can also install the script using the following commands (if you have installed rescript via the repository mentioned above or downloading the `.deb` package
from the release page, these additional steps doesn't apply):

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

**Different repositories**:

You can use `rescript` to easily manage different repositories by creating a
configuration file for every repository (it is done via `rescript config`) and
assigning an easy name to remember for each repository.

**[⇦ Back to index](#index)**

## Usage:

[![asciicast](https://asciinema.org/a/224460.svg)](https://asciinema.org/a/224460)

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
First thing to do is to to configure your repository by typing:

```
rescript config
```
This command will display a dialog where you'll be asked to select a text editor
you want to use. The list of editors are: Nano, Vim, Gedit, Mousepad, Leafpad,
Pluma, Kate, Xed, Other (can be used to set other text editor not listed) and Exit (exit the dialog).

Once the text editor is set, then it will display 3 options: 1) Configuration,
2) Exclusions, 3) Exit. Select 1 to open the configuration file, 2 to open the 
exclusion list and 3 to exit the dialog. Once you've done that you can start
using the script. If you don't have any repo remember to run `rescript [repo_name] init`
after configuring `rescript` or else it will fail to do anything.

**Configuration files**:

When you use `config` command to create a repository configuration file, `rescript` will create a template
of the configuration file for you. It will also set the permissions for those configuration files to `700`, which
means that only the user who created that configuration file will have the permission over the file; no other
user will be able to open and read that configuration file.

**Things you need to change in your configuration file**:

_**Note**: always put the values between the quotes to avoid globbing._

* `RESTIC_PASSWORD=""`: Put your restic password.
* `RESTIC_REPO=""`: Put your repository directory.
* `BACKUP_DIR="$HOME"`: This is what you're backing up; by default is your home directory.
* `KEEP_LAST=""`: Indicate the number of "last" backups you want to keep.
* `KEEP_HOURLY="8"`: Indicate the number of hourly backups you want to keep.
* `KEEP_DAILY="7"`: Indicate the number of daily backups you want to keep.
* `KEEP_WEEKLY="4"`: Indicate the number of weekly backups you want to keep.
* `KEEP_MONTHLY="12"`: Indicate the number of montly backups you want to keep.
* `KEEP_YEARLY="10"`: Indicate the number of yearly backups you want to keep.
* `KEEP_WITHIN=""`: Keep within duration needs to be a number of years, months,
   and days, e.g. 2y5m7d will keep all snapshots made in the two years,
   five months, and seven days before the latest snapshot (taken from [original
   restic documentaion](https://restic.readthedocs.io/en/stable/060_forget.html?highlight=keep-within#removing-snapshots-according-to-a-policy)).
* `KEEP_TAG=""`: Indicate the tag you want to keep; for example, if you have one specific
   snapshot that you want to keep forever, you can tag that snapshot with `keep-forever`
   and then put the `keep-forever` tag inside the "" for this variable so next `cleanup` onwards
   it will pass this specfic policy and keep all snapshots with this tag.

**Optional variables**:

These variables are optional because the script will still work if you don't want to setup
 a "cleanup", tag or destination.

* `CLEAN="7"`: Indicate the number (in days) of your cleanup policy (by default is 7 days); 
   this will make sure that the script run forget, check and prune applying your policies every
  days. You may change the number of days or leave it blank if you don't want the script to do this.
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
   command and option. You can turn logging off by swtiching this variable from
   "yes" to "no".
* `ARCHIVE=""`: Indicate "yes" if you want to create a new snapshot with the tag "archive"
   containing files deleted from the latest snapshot.
* `KEEP_ARCHIVE="yes"`: By default is "yes" and this will trigger a new "keep" policy to keep the 
   the tag "archive" when running `cleanup`. Set the variable to blank if not planning on using
   the "archive" function at all.
* `SKIP_OFFICE=""`: Indicate "yes" between the quotes if you want to temporarily exclude open "Office Documents"
   (.xlsx, .docx, .ods, .odt, etc.). This is useful if you have this script running via cron and
   you work with "Office Documents" in a daily basis. If an Excel document, for example, is open
   at the time a backup is running this option will exclude that file only until the next backup, after
   the document is closed. This prevents to store possible damaged files in your repository because
   if you are editing a document while a backup is running, restic will save the document but with the possibility
   that the document will not be fully functional when restored.
* `EMAIL=""`: put your email address in case you want `rescript` to send you an email if anything fails.
   This will only work if you use `rescript` with a cron job. If you just use it from your terminal, it will
   not send any emails because, well, that's not necesary since you can see what it is doing. Besides, `rescript` will
   exit and warn you if any error ocurred. You need `mailutils` installed and I would recommend to setup `ssmtp`. You can
   follow [this tutorial](https://www.howtogeek.com/51819/how-to-setup-email-alerts-on-linux-using-gmail/) in order to do so.
   If you don't want to receive any email, just leave this variable empty.

The configuration file also have variables for B2 and AWS ID's and Keys. If not required
just leave it blank.

**Exclusions**:

By default, rescript create a very simple exclusion file. You can tell rescript to build another
more complete exclusion file for you that will contain common exclusions patterns and directories
or simply build your own exclusion file by yourself. `rescript` will always create an exclusion file that
you can open and edit it as you wish. This is all done via `rescript config`.

**[⇦ Back to index](#index)**

## Commands and Options:

There are three commands that will not work as restic usually work, and those are the following commands:

1. **backup**: This command will run a backup according to the variables set before.
2. **help**: This command will display `rescript` help.
3. **version**: This command will display the current version of `rescript` you're using.
 
As far as I've tested, all other restic commands will run as using restic alone. For help
with restic commands type:

```
restic help [command]
```

Please see restic `help` and [documentation](https://restic.readthedocs.io/en/stable/) for more.

**Rescript Commands**:

1. **archive**: this command will check for differences between the latest two snapshots
   and will make a new snapshot tagged as "archive" containing all files deleted from
   the latest snapshot. For a better result of an "archive" it is better to run this
   command after taking a snapshot; if you run it from time to time the result will not
   be the best because it will be comparing just the latest two snapshot.

   Usage:
    ```
    rescript [repo_name] archive [flags] ...
    ```
   Command flags:
    1. `-H, --host`: only consider snapshots for this host.
    2. `-i, --info`: display stats for latest and all snapshots (see `info` command).
   
   If you do not indicate the "hostname" it will take the hostname from the system or
   the one indicated in the `HOST` variable in your configuration file. This function
   is also available as a flag for `backup` and `cleanup`.
2. **backup**: take a snapshot using the values set in your configuration file.

   Usage:
    ```
    rescript [repo_name] backup [flags]
    ```
   Command flags:
    1. `-a, --archive`: perform archive function (see `archive` command) after `backup`.
    2. `-c, --cleanup`: apply retention policies and prune (see `cleanup` command).
    3. `-d, --dry-run`: this is silly but useful if you want to just quickly check what would you be backing up
       and the size of it using `du`. It will automatically read your exclusion list and use it to read
       your backup directory and exclude those directories in your configuration file.
    4. `-i, --info`: display stats for the latest and all snapshots (see `info` command).
    5. `-S, --skip-office`: temporarily exclude open (in-use) "Office Documents" (.xlsx, .docx, .ods, .odt, etc.).
    
   Make use of restic flags/options as follows:
    ```
    rescript [repo_name] backup [flags] -- [restic_flags/options] ...
    ```
3. **checkout**: this command is will execute `check --read-data-subset #/10` 
   and it will select a random number between 1-10 out of 10 groups.
4. **changes**: this command will automatically select the two most recent snapshots
   and compare them using `restic diff`. When used alone it will select the snapshots
   according to the hostname in the machine that it is running or with the hostname
   indicated in the configuration file (HOST variable).

   Usage:
    ```
    rescript [repo_name] changes [flags] [options]
    ```
   Command flags:
    1. `-H, --host`: only consider snapshots for this host.
    2. `-m, --metadata`: print changes in metadata.
    3. `-p, --path`: only consider snapshots which include this [absolute] path.
    4. `-T, --tag`: only consider snapshots which include this taglist.
5. **cleanup**: this will perform `forget` according to the policies in your configuration file and `prune`.

   Usage:
    ```
    rescript [repo_name] cleanup [flags] [options]
    ```
   Command flags:
    1. `-a, --archive`: perform archive function (see `archive` command) before `cleanup`.
    2. `-i, --info`: display stats for the latest and all snapshots (see `info` command).
    3. `-n, --next`: this flag will display the next scheduled `cleanup` based on the `datefile`
      created by `rescript`; work only when CLEANUP variable is set.
      
   Make use of restic flags/options as follows:
    ```
    rescript [repo_name] cleanup [flags] -- [restic_flags/options] ...
    ```
6. **config**: this will open the configuration dialog. This command does not need a `[repo_name]`.
7. **editor**: change the default rescript text editor (for configuration and exclusion files). This command does not need a `[repo_name]`.
8. **env**: display the variable values in your configuration file.

   Usage:
    ```
    rescript [repo_name] env [flags] [VARNAME]
    ```
   Command flags:
    1. `-v, --var`: display varname value chosen (varname must be UPPERCASE).

9. **help**: display help dialog. This command does not need a `[repo_name]`.
10. **info**: this command will display stats for latest and all snapshots in a custom format.
    
    Output example:
     ```
     Summarized Info                        Restore Size         Deduplicated Size
     --------------------------------------------------------------------------------
     Latest Snapshot                         232.880 GiB               220.390 GiB
     All Snapshots                             2.276 TiB               221.253 GiB

     ```
10. **install**: this will move `rescript` in your `/usr/bin` if "system-wide" option is selected or, if "for this user" is selected, it will move it to `~/.local/bin` or `~/bin`. This command does not need a `[repo_name]`.
11. **logs**: this command needs an option. Could be used to display logs saved, display output in logs and remove logs.

    Usage:
     ```
     rescript [repo_name] logs
     OR
     rescript  [repo_name] logs [flags] [logfile]
     ```
    Command flags:
     1. `-c, --cat`: display output of selected log file (you need to copy and paste the filename to display it).
     2. `-r, --remove`: remove all log files related to your script (if you have different scripts for different repositoies
	     you need to call `--remove` for every instance).
	     
12. **mounter**: this option will mount your repository; it'll create a 
    directory in your `/home` so it can mount your repository. Once you quit
    the mount option with `Ctrl+c` it will delete the directory.

    Usage:
     ```
     rescript [repo_name] mounter
     ```
    Make use of restic flags/options as follows:
     ```
     rescript [repo_name] mounter -- [restic_flags/options] ...
     ```
13. **restorer**: this command will restore the snapshot you want to restore. You need to indicate
    the snapshot-ID you want to restore. With this command you don't need to indicate where to restore,
    it will automatically create a new file in your home directory called `restore-snapshotID-randomnumber`.
    It will do the random number so it will not conflict with maybe a file called the same in your
    home directory.

    Usage:
     ```
     rescript [repo_name] restorer [flags] [host|path|snapshot ID|tag]
     ```
    Command flags:
     1. `-H, --host`: indicate hostname.
     2. `-p, --path`: indicate path.
     3. `-T, --tag`: indicate tag.
     4. `-s, --snapshot`: indicate snapshot-ID.

14. **snaps**: this command is nothing more than `snapshots --compact` wrapped up. You may use it with any restic flags/options.
    If you want to use `rescript` global flags combined with other restic flags/options, do it as follows:
    ```
    rescript [repo_name] snaps [flags] -- [restic_flags/options] ...
    ```
    
15. **unlocker**: this command WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this command
   and it will delete the lock file so you can continue with your operation.

16. **update**: use this command to check and install newest version of `rescript`
    (works from versions 3.8 onward).

17. **version**: display rescript version. This command does not need a `[repo_name]`.

**Rescript Global Flags**:

Global flags are available for all commands (except when it doesn't make sense).
All flags can be combined except for `-h, --help`.

Usage:
```
rescript [repo_name] command [flags] ...
```

1. **`-d, --debug`**: debug WILL NOT debug restic commands; it will only set debug for the script.
2. **`-h, --help`**: display help for a specific command.
3. **`-l, --log`**: if you set the "LOGGING" variable to "yes" you don't need this flag
   when you run the automatic option (`rescript [repo_name]`); this flag is intended
   to use when you run a `rescript` or `restic` command. For example, you can run `rescript [repo_name] cleanup --log`
   to create a logfile for this specific command.
4. **`-q, --quiet`**: silence output. If you use `--log` it will still log the output.
5. **`-t, --time`**: display output with date, time and duration.

Make use of `rescript` global flags with `restic` commands as follows:
```
rescript [repo_name] -dlqt -- [restic_command] [flags] ...
```

**[⇦ Back to index](#index)**

## Adding a Cron Job
You can use a cron job to run backups automatically. You'll need to open your 
terminal emulator and edit your crontab file writing `crontab -e` and `enter`.
After that you need to add a new cronjob like `10 */2 * * * /PATH/TO/YOUR/rescript [repo_name]`.
This cron job will execute every two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /PATH/TO/YOUR/rescript [repo_name]`.

If you do this your `crontab` will look like this:

```
0 */4 * * * /PATH/TO/YOUR/rescript [repo_name]
```

If you want to use commands and options it can be done via cron but, for some reason (at least for me),
using `rescript` with commands and options does not work as it used to. The following two workarounds worked:
1. Redirect the output to `/dev/null` (if you use the log flag you don't have to worry about not getting the output in your logfile; it will
   still save the output to your logfile).
    ```
    0 */1 * * * rescript [repo_name] backup -lt > /dev/null
    ```
2. Command substitution (I don't know if this is good practice but at least for me it worked).
    ```
    0 */1 * * * $(rescript [repo_name] backup -lt)
    ```
You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

**[⇦ Back to index](#index)**

## Some things worth to mention
This script will create one (1) directory (`.rescript`) in your $HOME and
three (3) subdirectories: `config`, `lock` and `logs`.

`config` directory will contain the `rescript` `repo_name.conf` file, the `repo_name-datefile`
and the `repo_name-exclusions`. If you have multiple repositories, this subdirectory
will contain those three files for every repository.

`lock` directory will always be empty except when `rescript` is running. `rescript`
creates a temporarily file called `repo_name.lock` every time it runs and the file
should be removed at the end of every operation. This "lock" prevents another
processes to run if `rescript` is already running and is not finished yet. For example:
you set scheduled jobs but you forgot and tried to make a `prune`. If the scheduled
job is not finished it will display a message telling you that `rescript` is already
running so you'll have to wait until `rescript` finish to do what you want to do.
This way `rescript` prevents possible problems with your repository.

`logs` directory is used to save `rescript` logs.

**Why the `datefile`?**

The `datefile` is created by the script in the first run. This file will be placed 
inside `.rescript/config` and it will be called `repo_name-datefile`. 
_**Why is it there?**_ I liked the way my script was but I really didn't wanted to do
the `check`, `forget` and `prune` commands every day or even in every run of the script.
So, I find a way to play with the dates to make this happen and it was creating a 
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

_**NOTE**: If you were using v1.6 the datefile will be automatically moved from `logs` to `config`._

**[⇦ Back to index](#index)**

## Workarounds:
**Backing up more than one directory**:

From version 3.5 onwards you can backup more than one location at the same time
using the same configuration file. Just open your configuration file and edit
the following line:
```
BACKUP_DIR="/path/to/dir/1 /path/to/dir/2"
```
This is not exactly a workaround but with erlier versions you can't do that
unless you have edited the script to do so.

**Backup without unsing the build-in function**:

You can "omit the configuration file" by indicating `-r, --repo` after calling
`rescript [repo_name]`. You will not really completely omit the configuration file
but if you want to "override" what you're backing up and the exclusion list, then
you can do this (at least use one global flag):
```
rescript [repo_name] --time -- -r /your/repo/location backup /backup/directory
```
This could be useful if you want to add something quickly to your repo. Maybe you found
an old USB and you want to include some files in your repo, well you can quickly backup
those files using `rescript` that way. You can also indicate any other flag, `--exclude`,
etc., using `rescript` that way and it will not only work for `backup` but for any
other `restic` command.

**[⇦ Back to index](#index)**

## Having problems?
If you have any problem with the script you can reach out so it can be fixed.
If you have any problem using restic check out the [restic forum](https://forum.restic.net/);
maybe you can find answers or submit a question about your problem. I'm no affiliated
with the **restic** team in any way.

**[⇦ Back to index](#index)**

## Based on:
This script based on an example of a Restic Script found in
the following link: https://pastebin.com/ydN9fJ4H.

The original script was made for Borg and you can find it at this site:
https://blog.andrewkeech.com/posts/170718_borg.html

My intention is not to steal someone elses work so that's why I need to 
disclose the original source. I found all sources in this Reddit thread:
https://www.reddit.com/r/ScriptSwap/comments/7v7vby/restic_backup_script/

**Note**: the latest script is barely something like the original mentioned above. If you see the first versions it really was similar.

**[⇦ Back to index](#index)**

## Remove rescript

If installed via PPA:
```
sudo apt autoremove --purge rescript
sudo add-apt-repository --remove ppa:sulfuror/restic-tools
```
In Debian:
```
sudo apt autoremove --purge rescript
sudo rm -f /etc/apt/sources.list.d/restic-tools.list
sudo apt-key del B62F6780
```
If manually installed:
```
sudo rm -f /usr/bin/rescript
```
In all cases, remember that you will still have the `.rescript` hidden directory
in your `$HOME` directory. If you didn't stored your repository credentials elsewhere,
make sure to backup this directory or copy the configuration files located in
`$HOME/.rescript/config/repo_name.conf` before deleting this directory.

**[⇦ Back to index](#index)**