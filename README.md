# About `restic.sh`
This script was created for the sole purpose of using
[Restic](https://restic.net/) (deduplication backup program).

# This `script` was made to run the following commands:
1. unlock (when repo is locked)
2. backup
3. snapshots
4. check
5. forget
6. prune
7. stats

Also, it'll give you a nice output additional of the restic output with
the date it started, date ended, where are you backing up, excluded files,
the days left for the next "cleanup" run, the days it'll run the next "cleanup"
operation and the duration of the whole operation.

# Keep in mind
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

# Usage:
You'll se a lot of lines in this little script. What you need to change is the following values:

`RESTIC_PASSWORD="CHANGE_ME" (Put your restic password between the "")
RESTIC_REPO="/path/to/your/repo" (Put your repository directory)
BACKUP_DIR="$HOME" (This is what you're backing up; by default is your home directory)
DESTINATION="Local" (Put the name of your backup destination; something like S3, Google Drive, External Drive, FriendServerName, etc.)
TAG="YOURTAG" (Change YOURTAG to your tag; this is commented {it will not work} by default; just uncomment {delete the "#" symbol at the beginning} if you want to use a tag)
KEEP_HOURLY="8" (Indicate the number of hourly backups you want to keep) 
KEEP_DAILY="7" (Indicate the number of daily backups you want to keep)
KEEP_WEEKLY="4" (Indicate the number of weekly backups you want to keep)
KEEP_MONTHLY="12" (Indicate the number of montly backups you want to keep)
KEEP_YEARLY="10" (Indicate the number of yearly backups you want to keep)
CLEAN="7" (Indicate the number in days your cleanup policy {by default is 7 days}; this will run forget, check and prune according to your choice)
UNLOCK="no" (The default value is "no"; feel free to change it to "yes" if you want to unlock your repo at the beginning of the script)`

There are 15 exclude rules. You don't have to use it all or delete the ones you're
not using. If there's no file indicated it'll run normally without excluding anything
but the cache and trash. The "excludes" looks like this:

`EXCLUDE01=""`

You just have to put the full path of your excluded items/directories or the patterns
you want to exclude. For example, if I you don't want to backup your "Downloads" foler
just indicate it like this:

`EXCLUDE01="/home/user/Downloads"`

If you want to exclude ald PDF files, for example, you could do it like this:

`EXCLUDE01="/*.pdf"`

Also, I have to mention that the **"UNLOCK"** is set to **"no"** by default because
you really should not need to unlock your repo besides maybe in some rare
ocassions. I put it there because Restic creates a lock for every process but
if you cancel the process manually you will not need to unlock it because
Restic take care of unlock the repo when cleaning up the operation. In some rare
ocassions the process could be killed and in that case it may leave the repo locked.
That is why I decided to run `unlock` first in my script if it's locked at the
beginning of the script. My repo is just for one machine and if that's your case
you can run `unlock` at the beginning so maybe if the latest process for some
reason left a lock, then the backup will run after unlocking the repo. If you're
using one repository for multiple machines **you should not use `unlock`** because
it may be lock files from other processes and removing them could cause problems.
In that case it's better to check the origin of the lock before
unlocking the repository.

## Adding a Cron Job
You can use a cron job to run backups automatically. You'll need to open your 
terminal emulator and edit your crontab file writing `crontab -e` and `enter`.
After that you need to add a new cronjob like `10 */2 * * * /home/YOURUSERNAME/restic.sh`.
This cron job will execute every two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /home/YOURUSERNAME/restic.sh`.
You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

Also, you can create a log file so the cron job can store the output in a
plaintext file. You can do this using adding in the cron job file the following
after the cron job you've just created:
* `>> /home/YOURUSERNAME/logs/restic-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

If you do this your cron job will look like this:
* `0 */4 * * * /home/YOURUSERNAME/restic.sh >> /home/YOURUSERNAME/logs/restic-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

You can change the destination to your logs if you want. I made it 
to /home because is just simple and you don't have to mix that with
systems logs. You could also make the log folder hidden (that's my choice)
and just use `ls` to list your logs and `cat` to display the output instead
of opening file by file.

You can read more about how `crontab` works in [here](https://help.ubuntu.com/community/CronHowto).

# Some things worth to mention
This script will create two (2) files when it runs. One is temporary and it is
a `lock` file that will be deleted by the script at the end of it. The other 
file is a `datefile` created by the script. This `datefile` is not temporary
and if it is deleted the script will create it again on the next run.

**Why the `lock` file?**
The lock file will be a 0kb (it contains literally nothing) on the directory
that you put your script and the name of the file will be `.restic_sh.lock`. This
`lock` file is hidden (hence the "." at the beginning). Why is it there?
Well, I was having trouble with some cron jobs that started and the latest run
was not finished yet. That leads me to some errors in my repo (nothing to be worried in my case).
That's why I created the `lock` file. When the script start, first it'll check if the
`lock` file is present;  if it is present then it will not execute and it'll show you
a message telling you that the _"Backup is already running..."_. That way the script
will not run if it's already running and it's not finished yet. If you kill the script, shut down
your computer, kill restic or something similar the script will delete the file so
you don't have to delete it manually for the next run.

**Why the `datefile`?**
The `datefile` is created by the script in the first run and it'll only contain
literally the date of the first run. The file will be on the same directory
of your script and the `lock` file (also hidden) and it will be called `.datefile_restic`.
Why is it there? I liked the way my script was but I really didn't wanted to do the
`check`, `forget` and `prune` commands every day or even in every run of the script.
So, I find a way to play with the dates to make this happen and it was creating
a file where the script could read and write dates. The `datefile` will only contain
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