# About `restic.sh`

This script based on an example of a Restic Script found in
the following link: https://pastebin.com/ydN9fJ4H. The purpose of it is to
automate the use of [Restic](https://restic.net/) (backup program).

The original script was made for Borg and you can find it at this site:
https://blog.andrewkeech.com/posts/170718_borg.html

My intention is not to steal someone elses work so that's why I need to 
disclose the original source. I found all sources in this Reddit thread:
https://www.reddit.com/r/ScriptSwap/comments/7v7vby/restic_backup_script/

The account is deleted and the pastebin was made as a guest so I haven't found
the person who did the restic original script to thank him/her because that was 
the only script I found and I really couldn't found out how to do that before
without at least a guide (noob).

# This `script` was made with the following commands on the same file:
1. unlock
2. backup
3. check
4. snapshots
5. forget
6. prune
7. stats

# Keep in mind
1. Use this script at your own risk. If you do something wrong, that's on you.
   You should take the time to study the script and see if it could help you
   for what you need; if you use it without knowing what you're doing, that's on you too.
2. You need `restic` installed to use this script.
3. This script was made for GNU/Linux use. You could use it for other systems but you'll
   probably have to edit the commands depending on your system.
4. I'm not a developer, programmer or anything related; I'm just a regular user
   sharing my basic knowledge.
5. This script was made with an external HDD in mind. If you need to backup
   to a S3 cloud, or with `rclone` you must make sure that you add your
   credentials or put your `rclone` repository correctly in order to function.

# Possible changes you'll want to make:
1. The `restic unlock` line. You don't really need to unlock the `restic` repo.
   In fact, [fd0](https://github.com/fd0) (restic developer)
   [doesn't advise to run `unlock` in a script](https://forum.restic.net/t/prune-error-tree-not-found/785/4);
   so keep in mind that if you use it, it will be at your own risk. I've been
   using the `unlock` command because sometimes I totally forget about my
   computers running a backup before shutting them down... so if `restic` was
   running, when I turn on my computer again I need to unlock the repo so 
   the script could keep running regularly. I haven't had any problems with it
   and I don't really think that it could cause any problems because that command
   just remove lock files that it considers stale.
2. You need to change the `CHANGEME` passwords; both at the beginning and the end of the script.
3. You need to set your repo path and change the `/PATH/TO/REPO` in the script.
    * If you're using a `rclone` backend make sure you set up this line with
      `rclone:yourremotename:yourremotefolder` so it can work as intended.
    * The same for this first sub-point for `sftp` but with repo
      (from now on I'll assume you know how this work).
4. You need to hange the `tag` specified after the `backup` command.
   If you don't want to use any tag you can delete the `--tag YOURTAG` after
   the `backup` command. The script will work the same way but it will not have
   any tag. If you want to chose a tag, then change `YOURTAG` for whatever name you want.
5. Exclude list:
    * The exclude list is pretty basic. I use this script for a `rclone` backup
      and my exclude list is extensive so I shrink it to the files most people
      don't want to backup like the `cache` folder, `downloads`, `dbus`
      and `trash`. Feel free to include any other folder or file you don't
      want on your backup adding another line with:
        * `--exclude='/PATH/TO/UNWANTED/FILE/OR/FOLDER'` including the '\' at the end.
6. Feel free to change the forget rules to whatever number of days, hours,
   weeks, months or years you want to keep your snapshots.

# Possible problems with the script:
I use to run this script hourly with a cron but with my repo increasing on size,
the `prune` process was really slow and it causes errors because a cron job was
in process and when it was the time to start the other hourly snapshot then it
all crashed. So, the problems that I had were that after killing all processes
or viewing the log files, the backups were there but the `prune` process was
killed. That leads me to problems with the "trees not found" and running `check`
was giving me errors. I solved this problems using:
* `restic rebuild-index`
* `restic check --read-data`
* `restic prune`

This problem is not because of this script. If you're having any problems
with restic you should look at the [restic forum](https://forum.restic.net/)
page to find answers or submit a question about your problem. I'm no affiliated
with the **restic** team in any way.

Before that I make sure that the system was not executing the cron job
(just adding a # in the cron job file) and made my backups to run every two
hours. You can setup a cronjob using `crontab -e` in your terminal emulator.

Then you'll need to add a new cronjob like
`10 */2 * * * /home/YOURUSERNAME/restic.sh`. This cron job will execute every
two hours at the 10th minute. If you want to change it for every four hours;
for example, at the 0 minute just write `0 */4 * * * /home/YOURUSERNAME/restic.sh`.

Also, you can create a log file so the cron job can store the output in a
plaintext file. You can do this using adding in the cron job file the following
after the cron job you've just created:
* `>> /home/YOURUSERNAME/logs/restic-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

If you do this your cron job will look like this:
* `0 */4 * * * /home/YOURUSERNAME/restic.sh >> /home/YOURUSERNAME/logs/restic-log_$(date +\%Y-\%m-\%d-\%H:00) 2>&1`

You could totally change the destination to your logs if you want. I made it 
to  /home because it's just simple and you don't have to mix that with
systems logs. You could also make the log folder hidden (that's my choice)
and just use `ls` to list your logs and `cat` to display the output instead
of opening file by file.

That's it. If you want to make this script better feel free to do it here.
