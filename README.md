## About `rescript`
This script was created for the sole purpose of using
[Restic](https://restic.net/) (deduplication backup program).

## This `script` was made to run the following commands automatically:
1. backup
2. snapshots
3. forget
4. prune
5. check
6. stats

Also, it'll give you a nice output additional of the restic output with
the date it started, date ended, where are you backing up, excluded files,
the days left for the next "cleanup" run, the days it'll run the next "cleanup"
operation and the duration of the whole operation.

## Keep in mind
1. If you use this script is at your own risk. If you do something wrong, that's on you.
   You should take the time to study the script and see if it can help you
   for what you need; if you use it without knowing what you're doing, that's on you too.
2. You need `restic 0.9.2` or latest installed to use this script (`stats` are not in older versions of `restic`).
3. This script was made for GNU/Linux use. You could use it for other systems but you'll
   probably have to edit some things depending on your system. As far as I know, it works with
   FreeBSD and Mac OS with some issues / workarounds.
4. I'm not a developer, programmer or anything related; I'm just a regular user
   sharing my basic knowledge. I created this for my personal use but decided
   to share it because when I was looking for something like this, I did not
   find something that could fulfill my expectations. I know maybe there are some things
   in my script that can be done in a different way, better or even more easily but
   unfortunately I don't have enough knowledge. You're more than welcome to get in touch
   if you want to contribute something, fix something or whatever.

**For Mac OS**:

1. Install [brew](https://brew.sh).
2. `brew install coreutils`
3. `brew install gnu-sed --with-default-names`
4. **NOTE**: `nano` works great as a default text editor; chosing another one with Mac
   could require a little tweaking with your script.
5. **OPTIONAL**: to include `$HOME/bin` or `$HOME/.local/bin` in your `PATH`, edit or create
   a file called `.bash_profile` in your `$HOME` by typing `nano .bash_profile`
   and after pasting this following line save it and close it using Ctl+x:
```
export PATH=$PATH:$HOME/bin:$HOME/.local/bin
```

**For FreeBSD**:

1. Install `coreutils` package by typing: `pkg install coreutils`.
2. Set your `PATH` for your 
3. You may need to: 1) replace `#!/bin/bash` to `#!/usr/local/bin/bash` (this is the first line in the script),
   OR 2) use as follows: `bash /path/to/rescript [repo_name] [command]`. If you prefer the first method
   you can type `bash` which will open a bash session and call it without the full path; you need
   to set your `PATH` for this preferably for `$HOME/bin` or `$HOME/.local/bin`.

## Installation:

_**Note**: if you were using v2.0 or earlier make sure to backup your script before
continuing and rename your config file to `repo_name.conf`, your exclusion to
`repo_name-exclusions` and your datefile to `repo_name-datefile`._

You can install the script easily using the following commands:

```
~$ git clone https://gitlab.com/sulfuror/rescript.sh.git
~$ cd rescript.sh
~$ chmod 700 rescript
~$ ./rescript install
```
What you just did was to download the files and move `rescript` to your `~/bin` or `~/.local/bin`
directory. If the `~/bin` directory already exists it will move the script there. If not, it will move it to `~/.local/bin`.
If neither of these mentioned files is present, then it will ask you if you want to create it and it will create `~/.local/bin`.

Note that you can just move the script to any location and use it from there if you know what you're doing but if you 
use the install command it will move it to the directories mentioned before. Also, you need to already have your `$PATH`
for one of those directories or both. Distributions like _**Ubuntu**_ have already these paths set on the 
`.profile` file in your Home directory. If `$HOME/.local/bin` was already there you don't have to do anything else. Just check your 
your `.profile` text file if your distribution already have this option enabled. If you see these next lines
it means it is already enabled:

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
your computer in order for this work. The same applies if you needed to copy and paste the code before.

**Different repositories**:

You can use `rescript` to easily manage different repositories by creating a
configuration file for every repository (it is done via `rescript config`) and
assigning an easy name to remember for each repository.

## Usage:

You can use this script using an **_automatic_** function that will run `backup`,
`snapshots`, `forget`, `prune`, `check` and `stats` using your configuration
file. If your "LOGGING" variable is "yes" it will also create a log file with
the output. If you want to use the automatic function just type the following:

```
rescript [repo_name]
```

Rescript has its own commands that doesn't need a `[repo_name]` indicated. These
commands are: `config`, `editor`, `help`, `install` and `version`. Usage e.g.:

```
rescript [config|editor|help|install|version]
```

If you want to run a specific `rescript` or `restic` command:

```
rescript [repo_name] [command] [--flags] [options]
```

First thing to do is to to configure your repository by typing:

```
rescript config
```
This command will display a dialog where you'll be asked to select a text editor
you want to use. The list of editors are: Nano, Vim, Gedit, Mousepad, Leafpad,
Pluma and Kate (the default text editors for almost any DE).

Once the text editor is set, then it will display 3 options: 1) Configuration,
2) Exclusions, 3) Exit. Select 1 to open the configuration file, 2 to open the 
exclusion list and 3 to exit the dialog. Once you've done that you can start
using the script. If you don't have any repo remember to run `rescript [repo_name} init`
after configuring `rescript` or else it will fail to do anything.

**Things you need to change in your configuration file**:

* `RESTIC_PASSWORD=""`: Put your restic password between the "".
* `RESTIC_REPO=""`: Put your repository directory.
* `BACKUP_DIR="$HOME"`: This is what you're backing up; by default is your home directory.
* `KEEP_LAST="0"`: Indicate the number of "last" backups you want to keep
* `KEEP_HOURLY="8"`: Indicate the number of hourly backups you want to keep.
* `KEEP_DAILY="7"`: Indicate the number of daily backups you want to keep.
* `KEEP_WEEKLY="4"`: Indicate the number of weekly backups you want to keep.
* `KEEP_MONTHLY="12"`: Indicate the number of montly backups you want to keep.
* `KEEP_YEARLY="10"`: Indicate the number of yearly backups you want to keep.

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

The configuration file also have variables for B2 and AWS ID's and Keys. If not required
just leave it blank.

**Exclusions**:

By default, rescript create a very simple exclusion file. You can tell rescript to build another
more complete exclusion file for you that will contain common exclusions patterns and directories.
This is all done via `rescript config`.

## Commands and Options:

Commands and options are optional but the script will always need to indicate a `[repo_name]`.
(see [usage](https://gitlab.com/sulfuror/rescript.sh#usage)).

You can pass any restic command after calling the script. For example, if you
want to display your snapshots you just need to do this:

```
rescript [repo_name] snapshots
```

You can use as many commands and flags as you want, as you were using restic alone.
There are three commands that will not work as restic usually work, and those are the following commands:

1. `backup`: This command will run a backup according to the variables set before.
2. `help`: This command will display `rescript` help.
3. `version`: This command will display the current version of `rescript` you're using.
 
As far as I've tested, all other restic commands will run as using restic alone. For help
with restic commands type:

```
restic help [command]
OR
rescript [repo_name] [command] --help
```

Please see restic `help` and [documentation](https://restic.readthedocs.io/en/stable/) for more.

**Rescript Commands**:

1. `backup`: take a snapshot using the values set in your configuration file.
2. `cleanup`: this will perform `forget` according to the policies in your configuration file and `prune`.
3. `config`: this will open the configuration dialog. This command does not need a `[repo_name]`.
4. `editor`: change the default rescript text editor (for configuration and exclusion files). This command does not need a `[repo_name]`.
5. `help`: display help dialog. This command does not need a `[repo_name]`.
6. `install`: this will place rescript in your `$PATH` (in your home directory). This command does not need a `[repo_name]`.
7. `logs`: this command needs an option. Options are as follows:
	1. `--cat`: display output of selected log file (you need to copy and paste the filename to display it).
	e.g.: `rescript [repo_name] logs --cat rescript-log-2018-01-01-00:00`
	2. `--help`: help for `logs`.
	3. `--list`: list all log files saved.
	3. `--remove`: remove all log files related to your script (if you have different scripts for different repositoies
	  you need to call `--remove` for every instance).
8. `mounter`: this option will mount your repository; it'll create a 
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
9. `restorer`: this command will restore the snapshot you want to restore. You need to indicate
   the snapshot-ID you want to restore. With this command you don't need to indicate where to restore,
   it will automatically create a new file in your home directory called `restore-snapshotID-randomnumber`.
   It will do the random number so it will not conflict with maybe a file called the same in your
   home directory. You can use `restorer` with the following restic flags: `--host`, `--path` and `--tag`;
   there is also a tag for indicating the snapshot ID alone and this is `--snapshot`. This "snapshot"
   tag is only available for `rescript`. For help type `rescript [repo_name] restorer --help`.
   This command with any flag used with `rescript` will run `--verify` flag when restoring.
10. `unlocker`: this command WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this command
   and it will delete the lock file so you can continue with your operation.
11. `version`: display rescript version. This command does not need a `[repo_name]`.

**Rescript Flags**:

1. `--help`: display help for a specific command.
2. `--log`: if you set the "LOGGING" variable to "yes" you don't need this flag
   when you run the automatic option (`rescript [repo_name]`); this flag is intended
   to use when you run a `rescript` command. For example, you can run `rescript [repo_name] cleanup --log`
   to create a logfile for this specific command. This is available for `backup`,
   `cleanup`, `restorer` and `check` when used with `--random` flag. It is very important
   that if you want to use this flag, you need to use it at the end of all other commands,
   flags and options. e.g. `rescript [repo_name] restorer --tag [your_tag] --log`.
3. `--random`: this flag is only available for `check` and if used, you can't combine
   it with another `restic` flag; you can use `--log` when using this flag.
   This flag will execute `check --read-data-subset #/10` and it will select a random
   number between 1-10 out of 10 groups.

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

If you want to just do backups with this script without the need to run
the entire script, you can set up a cron job including the `backup` command,
just to run a backup and anything else. It will look as follows:

```
0 */4 * * * /PATH/TO/YOUR/rescript [repo_name] backup
```
Because commands and options will not create any log, you will not have a log
for this cron job. You can create one using the `--log` flag and that will create
a log inside your `$HOME/.rescript/logs` directory. If you want this in your
`crontab` you can do this as follows:
```
0 */4 * * * /PATH/TO/YOUR/rescript [repo_name] backup --log
```

You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

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

## Having problems?
If you have any problem with the script you can reach out so it can be fixed.
If you have any problem using restic check out the [restic forum](https://forum.restic.net/);
maybe you can find answers or submit a question about your problem. I'm no affiliated
with the **restic** team in any way.

That's it. Make this your own and make it better.

## Based on:
This script based on an example of a Restic Script found in
the following link: https://pastebin.com/ydN9fJ4H.

The original script was made for Borg and you can find it at this site:
https://blog.andrewkeech.com/posts/170718_borg.html

My intention is not to steal someone elses work so that's why I need to 
disclose the original source. I found all sources in this Reddit thread:
https://www.reddit.com/r/ScriptSwap/comments/7v7vby/restic_backup_script/