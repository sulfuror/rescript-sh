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
2. You need `restic 0.9.2` installed to use this script (I think `stats` are not in older versions of `restic`).
3. This script was made for GNU/Linux use. You could use it for other systems but you'll
   probably have to edit some things depending on your system.
4. I'm not a developer, programmer or anything related; I'm just a regular user
   sharing my basic knowledge.
5. This script was made with an external HDD, sftp connection or using rclone in mind.
   If you need to backup to a S3, B2, or any other service using the service that make use
   of credentials in order to access your repository, make sure to add an export of your credentials.

## Usage:

When you open the script in your favorite text editor you'll see fairly clear instructions but
for the sake of make things clear I'll explain as follows what you need to do:

**Things you need to change**:

* `RESTIC_PASSWORD="CHANGE_ME"`: Put your restic password between the "".
* `RESTIC_REPO="/path/to/your/repo"`: Put your repository directory.
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
* `LOGGING="yes"`: this variable is set to "yes" to keep log files inside your 
   `.rescript/logs` directory. If you don't want logs to be saved just change
   the "yes" to "no". It will save a log every time you run the script; options
   and restic commands will not save logs, it will only log when you run the
   script without any option. If you use this, every run will create a unique log
   file named with the name of the script, date and hour.

**Exclusions**:

In the past you will have to put the exclusions in the same script... from v1.7 onwards this has change.
Now you'll have an option [-e] to work with the exclusions. The exclusion file will be created by the
script in `.rescript/config`, so once you run this script your exclusion file will be created inside
this directory with a couple of exclusions by default, including Trash, rescript lock, private directory
and ecryptfs . You can change this if you want. There are another options to create a more complete
exclusion list for system backups and home directories. The [-e] options are explained as follows:

1. `--build`: this option will build an exclusion file to be used according to your choice. You can add,
   edit or remove exclusions rules as needed. This option by itself will do nothing, you have to chose from
   two other options: `	home` or `sys`. So you need to execute `rescript -e --build home` in order
   to build an exclude generic file for your home directory.
2. `--help`: this will display the help dialog for `-e`.
3. `edit`: now, executing `rescript -e edit` will open your exclusion file so you can either look at it,
   remove, add or edit the exclusion file.
4. `list`: the list option will list the exclusions inside its file.

If you had any exclusion list, copy your exclusion list before doing the change.

Once you have set the variables you can put this script in your `$HOME/.local/bin` or `$HOME/bin` 
directory, so you don't have to indicate the full path every time you want to use it. Distributions like 
_**Ubuntu**_ have already these paths set on the `.profile` file in your Home directory. 
If `$HOME/.local/bin` was already there you don't have to do anything else. Just check your 
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
If you don't have theses lines in your `.profile` then just copy those and paste it
at the end. If you had to create the `$HOME/bin` or `$HOME/.local/bin` directory and / or
edit the `.profile`, then you need to restart your session, or log out and login, or reboot your computer in 
order for this work. If it was already there, you don't need to do anything, just 
give it permission to execute  (`chmod 700 rescript`) and (optional) move 
the script to `/.local/bin`.

If you have different repos you can just change the name of the script and use
one for every repo. For example:

* For a B2 repo change `rescript` to `rescript_b2` so when you type `rescript_b2`
   you're referring to the B2 repo.

## Commands and Options:

Commands and options are optional. If you don't run any command or option
the script will run normally with all the options you have in your script.

You can pass any restic command after calling the script. For example, if you
want to display your snapshots you just need to do this:

```
rescript snapshots
```
You can use as many commands and flags as you want, as you were using restic but
calling the name of the script before the option. There are three commands that will
not work as restic usually work, and those are the following commands:

1. `backup`: This command will run a backup according to the variables set before.
2. `help`: This command will display `rescript` help.
3. `version`: This command will display the current version of `rescript` you're using.
 
As far as I've tested, all other restic commands will run as using restic alone. For help
with restic commands type:

```
restic help command
OR
rescript command --help
```

For restic regular commands usage:

```
rescript [command] [--flags] [options] [etc]
```
Please see restic `help` and [documentation](https://restic.readthedocs.io/en/stable/) for more.

**Rescript Options**:

1. `-b, -backup`: this option is pretty basic; it does what it says... it'll
   take a new snapshot.
2. `-c, -cleanup`: this option will execute `forget` according to the policies
   indicated in your script; also it'll execute the `prune` with `--cleanup-cache` flag so it'll
   actually delete the forgotten snapshots and cleanup your cache.
3. `-d, -deep-check`: Check repository with --read-data flag.
4. `-e`: manage your exclusion file.
5. `-h, -help`: this will bring up the help dialog on your terminal emulator.
6. `-m, -mount`: this option will mount your repository; it'll create a 
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
7. `-n, -next-cleanup`: this will show you the time left for your next cleanup
   according to your option in "CLEAN" days.
8. `-v, -version`: this option will display the version you're using
   of this script.
9. `-u, -unlock`: this option WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this option
   and it will delete the lock file so you can continue with your operation.
10. `-r`: this option will restore the snapshot you want to restore. You need to indicate
   the snapshot-ID you want to restore. With this option you don't need to indicate where to restore,
   it will automatically create a new file in your home directory called `restore-snapshotID-randomnumber`.
   It will do the random number so it will not conflict with maybe a file called the same in your
   home directory. You can use `-r` with the following restic flags: `--host`, `--path` and `--tag`.
   For help type `rescript -r --help`. This option will also run `--verify` flag.

Rescript options usage:

```
rescript -b
OR
rescript -backup
```

For restore:

```
rescript -r [snapshot-ID]
OR
rescript -r [--flag] [host|path|tag]
```

## Adding a Cron Job
You can use a cron job to run backups automatically. You'll need to open your 
terminal emulator and edit your crontab file writing `crontab -e` and `enter`.
After that you need to add a new cronjob like `10 */2 * * * /PATH/TO/YOUR/rescript`.
This cron job will execute every two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /PATH/TO/YOUR/rescript`.

If you want to just do backups with this script without the need to run
the entire script and also save a log you can set up a cron job including the `-b` option,
just to run a backup and anything else, like this:

```
0 */4 * * * /PATH/TO/YOUR/rescript -b >> /home/YOURUSERNAME/.rescript/logs/rescript-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1
```

You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

## Some things worth to mention
This script will create one (1) directory and two (2) files when it runs. 
One is temporary and it is a `lock` file that will be deleted by the script
at the end of it. The other file is a `datefile` created by the script. 
This `datefile` is not temporary and if it is deleted the script will create 
it again on the next run.

**Why the new directory?**

I was looking for something more generic than adding three files in the `/home`
directory. So the script will create a directory called `.rescript` in your `/home` directory.
Inside this new directory will be three  directories called `config`, `lock` and `logs`. If it already exists, it will do
nothing. Inside the`config` directory will be placed the `datefile` and the `exclusion-file`.
Inside the `lock` directory will be placed the `lock` file. The `logs` directory is for you to place
the logs created by your cron jobs.

**Why the `lock` file?**

The lock file will be a 0kb (it contains literally nothing) and the name of 
the file will be `nameofscript.lock`. This `lock` file will be inside 
`/.local/tmp`. Why is it there? Well, I was having trouble with some cron jobs 
that started and the latest run was not finished yet. That leads me to some 
errors in my repo (nothing to be worried in my case). That's why I created 
the `lock` file. When the script start, first it'll check if the
`lock` file is present;  if it is present then it will not execute and it'll show you
a message telling you that the _"nameofscript is already running..."_. That way the script
will not run if it's already running and it's not finished yet. If you kill the script, shut down
your computer, kill restic or something similar the script will delete the file so
you don't have to delete it manually for the next run.

**Why the `datefile`?**

The `datefile` is created by the script in the first run. This file will be placed 
inside `.rescript/config` and it will be called `datefile_nameofscript`. 
Why is it there? I liked the way my script was but I really didn't wanted to do
the `check`, `forget` and `prune` commands every day or even in every run of the script.
So, I find a way to play with the dates to make this happen and it was creating a 
file where the script could read and write dates. The `datefile` will only contain
one date and that is 7 days from the moment you run the script for the first time
(this 7 days is by default but you can change it in the "CLEAN" value).
So, what does this mean? It means that every time the script runs, before running
`check`, `forget` and `prune` it will read the date in your `datefile` and if those
seven days have not passed yet (again, you can change the days), then it'll not run
the `check`, `forget` and `prune`. When it's time to run `check`, `forget` and `prune`
the script will run all three operations and it'll override the date in the file
created. If, for some reason the file is deleted then the script will not know 
and it will run `check`, `forget` and `prune` according to your policies and 
it will create the `datefile` again adding the date for the next "cleaning" run.

If you were using v1.6 the datefile will be automatically moved from `logs` to `config`.

**Why so much trouble to do something that I could have achieve with a cron job?**

Because is cool and all the kids are doing it.

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