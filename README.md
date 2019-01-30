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
   To install `restic` follow [these instructions](https://restic.readthedocs.io/en/stable/020_installation.html).
   It is advise to use their official standalone binary. Official binaries can be updated in place
   easily using `restic self-update`. Download it [here](https://github.com/restic/restic/releases/tag/v0.9.4).
3. This script was made for GNU/Linux in mind but it also works with MacOS and FreeBSD.
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
5. **OPTIONAL**: to include `~/bin` or `~/.local/bin` in your `PATH`, edit or create
   a file called `.bash_profile` in your `$HOME` by typing `nano .bash_profile`
   and after pasting this following line save it and close it using Ctl+x:
```
export PATH=$PATH:$HOME/bin:$HOME/.local/bin
```

**For FreeBSD**:

1. Install `coreutils` package by typing: `pkg install coreutils`.
2. Set the `PATH` for your `~/bin` or `~/.local/bin`.

**NOTE**: If `~/bin` doesn't exists and you decide to use `install` command,
`rescript` will automatically decides to use `~/.local/bin`, so before using
`install` you have to make sure to set your `$PATH` for both locations or move the
script manually to your `$PATH`.

## Installation:

_**Note**: if you were using v2.0 or earlier make sure to backup your script before
continuing and rename your config file to `repo_name.conf`, your exclusion to
`repo_name-exclusions` and your datefile to `repo_name-datefile`._

You can download the `.deb` package in the [relase page](https://gitlab.com/sulfuror/rescript.sh/releases)
and execute the following command:
```
sudo dpkg -i rescript_v3.7.deb
```

You can also install the script easily using the following commands:

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

**For system wide use**:

```
~$ git clone https://gitlab.com/sulfuror/rescript.sh.git
~$ cd rescript.sh
~$ sudo mv ./rescript /usr/bin/rescript
~$ sudo chmod 755 /usr/bin/rescript
```
Configuration files will be created in every User's home individually. 

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
using the script. If you don't have any repo remember to run `rescript [repo_name] init`
after configuring `rescript` or else it will fail to do anything.

**Things you need to change in your configuration file**:

* `RESTIC_PASSWORD=""`: Put your restic password between the "".
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
2. `checkout`: this command is will execute `check --read-data-subset #/10` 
   and it will select a random number between 1-10 out of 10 groups.
3. `cleanup`: this will perform `forget` according to the policies in your configuration file and `prune`.
   Command flags:
   1. `-d, --dry-run`: do not delete anything, just print what would be done.
      This flag can be used with other restic flags like: `--host, --tag, --path,
      --group-by` and any other flag and option available but it must be specified
      before restic options and after `cleanup`.
      e.g.:
      ```
      rescript [repo_name] cleanup -d --group-by tags --tag YOURTAG
      ```
   2. `-e, --exec`: this is a special tag that will allow you to pass all restic options
      for `forget` using the policies specified on your configuration file. This WILL NOT
      use `--dry-run` and it will actually remove and delete (using `prune` at the end)
      data from your repository.
      e.g.:
      ```
      rescript [repo_name] cleanup -e --group-by tags --tag YOURTAG
      ```
   3. `-n, --next`: this flag will display the next scheduled `cleanup` based on the `datefile`
      created by `rescript`; work only when CLEANUP variable is set.
4. `config`: this will open the configuration dialog. This command does not need a `[repo_name]`.
5. `editor`: change the default rescript text editor (for configuration and exclusion files). This command does not need a `[repo_name]`.
6. `help`: display help dialog. This command does not need a `[repo_name]`.
7. `install`: this will place rescript in your `$PATH` (in your home directory). This command does not need a `[repo_name]`.
8. `logs`: this command needs an option. Options are as follows:
   1. `-c, --cat`: display output of selected log file (you need to copy and paste the filename to display it).
      e.g.: 
      ``` 
      rescript [repo_name] logs --cat rescript-log-2018-01-01-00:00
      ```
   2. `-L, --list`: list all log files saved.
   3. `-r, --remove`: remove all log files related to your script (if you have different scripts for different repositoies
	  you need to call `--remove` for every instance).
9. `mounter`: this option will mount your repository; it'll create a 
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
10. `restorer`: this command will restore the snapshot you want to restore. You need to indicate
    the snapshot-ID you want to restore. With this command you don't need to indicate where to restore,
    it will automatically create a new file in your home directory called `restore-snapshotID-randomnumber`.
    It will do the random number so it will not conflict with maybe a file called the same in your
    home directory. You can use `restorer` with the following restic flags:
    1. `-H, --host`: indicate hostname.
    2. `-p, --path`: indicate path.
    3. `-T, --tag`: indicate tag.
    4. `-s, --snapshot`: indicate snapshot-ID.
    
    This "snapshot" flag is only available for `rescript`. For help type
    `rescript help restorer`. This command will automatically use `--verify` when restoring.
11. `unlocker`: this command WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this command
   and it will delete the lock file so you can continue with your operation.
12. `update`: use this command to check and install newest version of `rescript`
    (works from versions 3.8 onward).
13. `version`: display rescript version. This command does not need a `[repo_name]`.

**Rescript Global Flags**:

These flags were "renamed" as "Global Flags" from v3.5 onwards to simplify and
divide "command flags" that are those flags for specific commands (see `logs` for example).
So, from version 3.5 these "Global Flags" must be used before commands.

For example, if you want to log a command use:

```
rescript [repo_name] -l backup
```
The `help` command also works this way. If you can see the usage for a specific command use:
```
rescript help [rescript_command]
```

1. `-h, --help`: display help for a specific command.
2. `-l, --log`: if you set the "LOGGING" variable to "yes" you don't need this flag
   when you run the automatic option (`rescript [repo_name]`); this flag is intended
   to use when you run a `rescript` or `restic` command. For example, you can run `rescript [repo_name] --log cleanup`
   to create a logfile for this specific command. This is available for all `rescript` and `restic`
   commands. It is very important that if you want to use this flag, you need to use it before of all other commands,
   flags and options. e.g. `rescript [repo_name] --log restorer --tag [your_tag]`.
   You can combine this flag with `--time`.
3. `-t, --time`: this flag is only available for `restic` and if used, it will display
   an output with the date, time and duration of the command executed. Like `--log` it must
   be indicated before all other commands, for example: `rescript [repo_name] --time check [--flags]`.
   You can combine this flag with `--log`.

Since `rescript` commands will always display an output with the date and duration,
the `--time` flag makes no sense for `rescript` commands; this is why the `--time`
flag will only work with `restic` commands.

Because `--log` and `--time` can be combined, you can use these two as follows:
```
rescript [repo_name] -l check
OR
rescript [repo_name] -t check
OR
rescript [repo_name] -t -l check
OR
rescript [repo_name] -l -t check
```
The first option will only create a log file, the second option will just display
the output with duration without creating a log file; the third and fourth will do
the same (it doesn't matter the order), the both will create a log file and will
display the time and duration. You can use for both options the long flags `--log`
and `--time` or the short way `-l` and `-t`. 

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
0 */4 * * * /PATH/TO/YOUR/rescript [repo_name] --log backup
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
you can do this:
```
rescript [repo_name] -r /your/repo/location backup /backup/directory
```
This could be useful if you want to add something quickly to your repo. Maybe you found
an old USB and you want to include some files in your repo, well you can quickly backup
those files using `rescript` that way. You can also indicate any other flag, `--exclude`,
etc., using `rescript` that way and it will not only work for `backup` but for any
other `restic` command.

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