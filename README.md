## About `rescript.sh`
This script was created for the sole purpose of using
[Restic](https://restic.net/) (deduplication backup program).

## This `script` was made to run the following commands automatically:
1. backup
2. snapshots
3. check
4. forget
5. prune
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
   probably have to edit the commands depending on your system.
4. I'm not a developer, programmer or anything related; I'm just a regular user
   sharing my basic knowledge.
5. This script was made with an external HDD in mind. If you need to backup
   to a S3 cloud, or with `rclone` you must make sure that you add your
   credentials or put your `rclone` repository correctly in order to function.
6. I made a lot of changes in the latest version (v1.0); I made this "tags" of 
   versions because I still want to have at hand the older one just in case
   I get bored of this one. You're free to navigate to the "tags" and download
   it if you prefer that one. The older one is v0.5.

## Usage:
The best way I've found to use a script is to put the script in your `./local/bin`
directory. This is my choice, you're free to use it as you like. Distributions
like _**Ubuntu**_ have already the options in their system to use this file
as a regular `/bin` file of your system; that means, it already read from
there executable files. So if `./local/bin` is already created, that's a great
place for this script. If not and you don't want to write `./script.sh` every time
you want to use it and instead you wish to type `nameofyourscript` and the options,
then you just need to create it. Once created, verify in your `.profile` document
if your distribution already have this option enabled. If you see this next lines
it means it is already enabled:

```
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```

If you don't have theses lines in your `.profile` then just copy those and paste it
at the end. If you had to create the `/bin` directory and edit the `.profile`, then
you need to restart your session, or log out and login, or reboot your computer in 
order for this work. If it was already there, you don't need to do anything, just 
give it permission to execute  (`chmod 700 rescript.sh`) and (optional) rename the 
script from `rescript.sh`  to `whatevername`, move the script to `/.local/bin`, open your terminal
and type the name of your script.

You'll see a lot of lines in this little script. What you need to change is the following values:

* `RESTIC_PASSWORD="CHANGE_ME"` <- Put your restic password between the ""
* `RESTIC_REPO="/path/to/your/repo"` <- Put your repository directory
* `BACKUP_DIR="$HOME"` <- This is what you're backing up; by default is your home directory
* `DESTINATION="Local"` <- Put the name of your backup destination; something like S3, Google Drive, External Drive, FriendServerName, etc.
* `TAG="YOURTAG"` <- Change YOURTAG to your tag; this is commented (it will not work) by default; just uncomment (delete the "#" symbol at the beginning) if you want to use a tag
* `KEEP_HOURLY="8"` <- Indicate the number of hourly backups you want to keep
* `KEEP_DAILY="7"` <- Indicate the number of daily backups you want to keep
* `KEEP_WEEKLY="4"` <- Indicate the number of weekly backups you want to keep
* `KEEP_MONTHLY="12"` <- Indicate the number of montly backups you want to keep
* `KEEP_YEARLY="10"` <- Indicate the number of yearly backups you want to keep
* `CLEAN="7"` <- Indicate the number (in days) of your cleanup policy (by default is 7 days); this will run forget, check and prune according to your choice

There are 15 exclude rules. You don't have to use it all or delete the ones you're
not using. If there's no file indicated it'll run normally without excluding anything
but the cache and trash. The "excludes" looks like this:

`EXCLUDE01=""`

You just have to put the full path of your excluded items/directories or the patterns
you want to exclude. For example, if I you don't want to backup your "Downloads" foler
just indicate it like this:

`EXCLUDE01="/home/user/Downloads"`

If you want to exclude all PDF files, for example, you could do it like this:

`EXCLUDE01="*.pdf"`

## Commands and Options:

You can use the script with the following five commands and six options:

**Commands**:
1. `check`: This will check your repository
2. `init`: This will create a new repository if it does not exists
3. `prune`: This will delete data (if there's nothing to delete it won't do anything)
4. `snapshots`: This will display a list of your snapshots
5. `unlock`: This will unlock your repository
6. `rebuild-index`: This will build a new index file
7. `stats`: This will scan the repository and show basic statistics

**Automatic Options**:
1. `-b, -backup`: this option is pretty basic; it does what it says... it'll
   take a new snapshot.
2. `-c, -cleanup`: this option will execute `forget` according to the policies
   indicated in your script; also it'll execute the `prune` with `--cleanup-cache` flag so it'll
   actually delete the forgotten snapshots and cleanup your cache.
3. `-d, -deep-check`: Check repository with --read-data flag.
4. `-h, -help`: this will bring up the help dialog on your terminal emulator.
5. `-m, -mount`: this option will mount your repository; it'll create a 
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
6. `-n, -next-cleanup`: this will show you the time left for your next cleanup
   according to your option in "CLEAN" days.
7. `-r, -restore`: this option will do what it says, it will restore.
   It will create a new directory in your `/home` called `restic-restore`
   and it will restore your latest snapshot only. If you want to restore
   a specific snapshot you will have to do it manually.
8. `-v, -version`: this option will display the version you're using
   of this script.
9. `-s, -stats`: this will display the stats with --mode flag for
   original size of latest snapshot, deduplicated size of latest snapshot,
   original size of all snapshots and deduplicated size of all snapshots.
10. `-u, -unlock`: this option WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this option
   and it will delete the lock file so you can continue with your operation.

**User Options**
1. `-f`: this option is for forget snapshots.
2. `-g`: this option is for find; it will help you find a file, pattern or directory
   inside your repo.
3. `-k`: this stands for keys and is for wokring, listing with your repo keys.
4. `-l`: this option is for ls to list files in a snapshot.

You can just use one argument with every "user option". This means that, for
example, you can just use `-f` for one snapshot at a time.

You can use these commands as follows:
```
    ./rescript.sh command
OR
    ./rescript.sh -option
OR
    ./rescript.sh -option argument
```
**Examples**

For `forget`:

`./rescript.sh -f [snapshot ID]`

For `find`:

`./rescript.sh -g [your_file_directory_or_pattern]`

For `key`:

`./rescript.sh -k [list|add|remove|passwd]`

For `ls`:

`./rescript.sh -l [snapshot ID]`

Commands will work if you use the full command. You can use options with
just one letter or the full name of the option. For example, for "help"
you need to type `./rescript.sh -h` or `./rescript.sh -help`. Both are valid
and do the same thing. Optional commands will only wokr with just one letter.

You can use just one command or option at a time.

## Adding a Cron Job
You can use a cron job to run backups automatically. You'll need to open your 
terminal emulator and edit your crontab file writing `crontab -e` and `enter`.
After that you need to add a new cronjob like `10 */2 * * * /PATH/TO/YOUR/rescript.sh`.
This cron job will execute every two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /PATH/TO/YOUR/rescript.sh`.

Also, you can create a log file so the cron job can store the output in a
plaintext file. You can do this by adding in the cron job file the following
after the cron job you've just created:
* `>> /home/YOURUSERNAME/.rescript/logs/rescript-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

That will create a plain text file in the directory `/home/YOURUSERNAME/.rescript/logs`.
Let's say the system ran the job at 12:00 a.m. in January 1, 2018; then this
past line on your `crontab` will create a file called 
rescript-log_2018-01-01-12:00 with all the script process output.

If you do this your `crontab` will look like this:
* `0 */4 * * * /PATH/TO/YOUR/rescript.sh >> /home/YOURUSERNAME/.rescript/logs/rescript-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

You can change the destination to your logs if you want. I made it 
to /home because is just simple and you don't have to mix that with
systems logs. You could also make the log folder hidden (that's my choice)
and just use `ls` to list your logs and `cat` to display the output instead
of opening file by file.

You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

## Some things worth to mention
This script will create one (1) directory and two (2) files when it runs. 
One is temporary and it is a `lock` file that will be deleted by the script
at the end of it. The other file is a `datefile` created by the script. 
This `datefile` is not temporary and if it is deleted the script will create 
it again on the next run.

**Why the new directory?**

I was looking for something more generic than adding two files in the `/home`
directory. So the script will create a directory inside called `/.rescript` in your `/home` directory.
Inside this new directory will be two more called `/lock` and `/logs`. If it already exists, it will do
nothing. Inside the `lock` directory will be placed the `lock` file and in
`/logs` will be the `datefile` and if you want to place your logs if you're using
cron jobs you could direct it to that directory too.

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

The `datefile` is created by the script in the first run. This file will also 
be inside `/.local/tmp` and it will be called `datefile_nameofscript`. 
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