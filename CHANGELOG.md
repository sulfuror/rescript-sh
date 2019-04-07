# April 7, 2019
**Fixes and additions**:

1. Fixed variables quotes, unnecessary commands and others.
2. Added variable "SKIP_OFFICE" for the configuration file and added
   `-S|--skip-office` flag for `backup`. This variable and flag can be used
   to temporarily exclude open (in-use) "Office Documents" at the moment
   a backup process is running. For example, if you have backups running
   automatically via cron or using this script, you could only set the variable
   "SKIP_OFFICE" to "yes" so when a backup is performed the "Office" documents
   in use at the moment will be excluded for this unique snapshot. Why exclude
   open documents? When restic is backing up at the moment an "Office Document" is
   open, there is a posibility that restic saves a truncated/damaged file. For more
   about this subject check [this thread](https://forum.restic.net/t/excluding-in-use-files-necessary/1476)
   in the restic forum.
3. Added `env` command. This command will display variable values in your configuration file.
4. Added `snaps` command. This command is for displaying snapshots but unless `restic`, this
   command will display snapshots in compact mode by default. Also, and this specific flag
   was the real purpose for this command, `snaps` has a flag `-g, --group-by` and it works
   for displaying snapshots by host or tags. So if you execute `rescript [repo_name] snaps --group-by host`
   it will display all snapshots ordered by hostname. It works for host and tags in compact mode only.
5. Fixed `archive` function. If you had an "archive" snapshot already it worked but if not, it was not
   creating a snapshot. Also, the `tmp` directory will now be determined by variables, so if your system
   have another `$TMPDIR`, it will follow that instead of a fixed directory that my or may not exist,
   depending on the operating system (termux in android, for example).
6. Fixed policies array so when determining if there are policies, it will now read them correctly.
7. Fixed `update` and `install` commands. They will now respond properly when using Mac or FreeBSD.
8. `archive` and `update` will now complain for dependencies (`wget, rsync`) if they're not installed.
9. Added a little something to display Android version if used with Termux.

# March 7, 2019
**Fixes**:

1. Fixed `archive` function. Before it was working okay but it was not syncing
   new files. For example: you have snapshot 1 and 2. There is a file called "ImportantFile.txt"
   in the snapshot 1 but it was deleted after that snapshot, so snapshot 2 does not
   have the "ImportantFile.txt"; `archive` took care of it and saved it to the
   special "archive" snapshot. That is expected. Then the file was restored and edited
   and after that a snapshot 3 happened. For some misterious reason the file was deleted
   again and when restic took snapshot 4 the file was missing, so `archive` do its work
   again. You would think that now "archive" snapshot contains the latest "ImportantFile.txt"
   version, but that is not true; the file is in there but is the oldest version. Why this
   happened? `archive` uses rsync to sync the deleted files but the error in the code was
   to use rsync to sync the old snapshot to the new one like this:
   ```
   rsync -a /path/to/old/snapshot/* /tmp/archive
   ```
   In theory it was working but for this specific unsusual behaviour it was taking
   old files and deleting the new ones. Now rsync will execute twice and it will sync
   the old snapshot first and then the new one, so all newly edited files would be
   there but it needs to create a new directory instead of 2, which at the end are deleted;
   now it looks like this:
   ```
   rsync -a /path/to/old/snapshot/* /tmp/archive
   rsync -a /path/to/latest/snapshot/* /tmp/archive
   ```
   After that it will create the new snapshot and that's it.
   

# March 4, 2019
**Changes, fixes and additions**:

1. Fixed output so now it doesn't display 0 days, 0 hours, 0 minutes or 0 seconds;
   now instead of displaying "1 hour 0 minutes and 20 seconds" (for example) it will
   display "1 hour and 20 seconds". This applies for the "duration" and when it display
   "next cleanup".
2. Added a variable called "ARCHIVE". By default is blank and you should change it to
   "yes" if you want to use it for the automatic function (see point 3).
3. Added a new command called `archive`. This command will check differences between
   the latest two snapshot and it will create a new "special snapshot" with the path `/tmp/archive`
   and tag `archive` containing only the files deleted from the latest snapshot. It will also
   be dated as "2015-01-01" so it will always be the first snapshot displayed. To properly have a
   real archive of all deleted files, it is better to use this option after every
   `backup` made, so it will consider all deleted files. If it is used just from time to time,
   it will work but `rescript` will not know if there are other deleted files. For example, if you used
   the `archive` function today and then you took five snapshots and use it again, it will be a gap
   of three snapshots (being the latest two of the five used by `diff`); rescript will only check
   differences between the latest two snapshots and "archive" deleted files between them.
   This function also available as a flag for other commands. For example, you can use 
   `rescript [repo_name] backup --archive` and it will perform a backup and then will
   execute the "archive" function. `archive` could take time if there are a lot of big files; keep
   in mind that this function will need to perform `diff` first, then it will restore all deleted
   files from the second most newest snapshot, then will restore the "archive" snapshot (if exists),
   merge all data and then create a new snapshot with all deleted data. Good thing is that, since
   all this data is already in your repository, the `backup` progress should not take too long.
   This command also have a `-H, --host` flag so you can use it indicating one specific hostname.
   If no hostname is indicated, the default is to use your machine's hostname or the hostname
   in the variable `HOST` in your configuration file. IMPORTANT: must have `rsync` installed 
   to use this function; the script will not display any errors but it will not work correctly.
4. Added flags `-a, --archive` to `backup` and `cleanup` commands.
5. Added `-e, --exec` to `mounter` so you could pass flags like `--allow-other, --allow-root, --host, --path`
   and others but it is sill using tha variables in your configuragion file.
6. Added `-e, --exec` to `backup` so you could pass flags like `--no-lock, --no-cache`
   and others but it is sill using tha variables in your configuragion file.
7. Fixed `stats` output for the "automatic" function, so now will display the hostname and use
   `restic stats --host [hostname]` for original and deduplicated size for latest snapshot.
8. Fixed `changes` command. Now if there is no host, path, tag, etc., it will display
   a message saying that there is no value for your option; it will also now display
   an error message for invalid flags.

# February 14, 2019
**Changes, fixes and additions**:

1. "usage" is now a function instead of a variable; nothing relevant for users.
2. The script variables are now lowercase to make easier to know if the variable
   is just for the script or for the configuration file / system vars.
3. Instead of using commands to work with rescript directories and files, now
   they will work with new script variables for those directories and files;
   this means if you want to move your ".rescript" directory to another location,
   you can just move it manually and set the script variables to point to that
   new location so you don't have to mess around with the whole script and guess
   what function is using the rescript directories/files to manually change it
   all. For example, if you want to use `/etc/rescript` to store your configuration
   files, then you just need to adjust these variables and copy your existing files
   to the new directory. You'll need to make sure to set the right permissions to
   those directory/files.
4. Change a lot of the "if" statements to "case"; it made the whole script longer
   but easier to understand/edit.
5. The script now will read any letter as lowercase except for `logs` and `restorer`.
6. Added a new menu for easier installation when using `rescript install`.
7. Added `printf` to display output so it will automatically display lines and text
   instead of adding custom lines and text per function (it actually shorten the code
   a lot, but as I said, the use of "case" instead of "if" statements makes it longer now).
8. Added a new command called `changes`. This new command will automatically select two must recent
   snapshots and compare them using `restic diff`. This command works per hostname automatically;
   if you are using `HOST` variable in your configuration file, it will automatically use
   that hostname. You can override this behaviour using `-H|--host, -p|--path, -T|--tag`
   flags. It also have an `-m|--metadata` flag to display changes in metadata and this flag
   can be used with `-H, -p, -T`.

# January 29, 2019
**Changes**:

1. Added `update` command. This command can be used to update the script in place.
   This will work from version 3.8 onward.

# January 26, 2019
**Changes**:

1. Changes in the editor menu that removes a bit part of the menu code making
   it a little bit simple. This change remove the need to use `sudo rescript editor`
   when the script is istalled in `/usr/bin`. There is also a new `.deb` package
   for an easier installation that you can find in the [release page](https://gitlab.com/sulfuror/rescript.sh/releases).

# January 23, 2019
**Changes and fixes**:

1. Changed shebang to `env bash` for compatibility with OS's other than GNU/Linux.
2. Changes in editor menu code (it actually doesn't change behavior).
3. Added `--keep-within --keep-tag` to code; from v3.6 onwards, KEEP variables
   can be left blank if not used and it is advise to do so because if you do not
   use all KEEP, leaving it blank prevent the script to pass an additional flag
   and misbehave (it doesn't behave weirdly as far as I tested). So, if, for example,
   you use just "KEEP_LAST" variable, the script will pass `forget` command as follows:
   ```
   restic forget --keep-last N
   ```
   Before this change, the script was passing all flags even if the value was "0" like this"
   ```
   restic forget --keep-last N --keep-hourly --keep-daily --keep-weekly --keep-monthly --keep-yearly
   ```
4. Added new flags to `cleanup`.
   1. `-d, --dry-run`: this flag will allow you to pass `--dry-run` so it will actually 
      delete nothing. e.g.:
      ```
      rescript [repo_name] cleanup -d
      ```
      It also allow your to add other restic flags for `forget`. e.g.:
      ```
      rescript [repo_name] cleanup -d --group-by [host|tags|path] --tag [tag]
      ```
   2. `-e, --exec`: this flag, like `-d` allows other restic flags for `forget` but
      it will actually forget snapshots and delete data with `prune` at the end. e.g.:
      ```
      rescript [repo_name] cleanup -e --group-by [host|tags|path] --tag [tag]
      ```
5. Added new variables in script to set keep rules (it doesn't change anything for
   user's usage).
6. Added new variables in script to set `$TAG` and `$HOST`, if used (it doesn't change
   anything for user's usage).
7. Removed code for "rescript locks" and added a new function for the "rescript lock" file
   (it doesn't change anything for user's usage).
8. Change function for displaying the next `cleanup` time (it doesn't change the behavior,
   just simplify the code a little bit).
9. Added an array for keep policies to improve script behaviour preventing it to
   pass unneded blank keep policies (see point number 3).
10. Added new message if CLEAN is greater than 0 and keep policies are not set.
11. An error message was being displayed if the "datefile" was deleted from the `config` directory.
    Added code to create one if CLEAN if greater than 0 so it doesn't display the
    annoying error.
12. Simplified `cleanup -n` function and now is being re-used for other functions (it doesn't
    change anything for user's usage or behavior).
    
# January 12, 2019
**Changes**:

1. Now you can specify more than one location in `BACKUP_DIR` variable.
2. Rescript flags now are called "Global Flags" because they can be used
   for all commands including restic commands. There's only three: `-h`, `-l`, `-t`.
   These flags now must be used BEFORE all other commands and its flags.

**Fixes**:

1. Fixed error when function decides to display the number of days and hours
   when running `cleanup -n`.

# January 6, 2019
**Changes**:

1. Now the `--random` flag doesn't exists. The `checkout` command replaces it.
2. Added `--time, -t` flag to display output with date, time and duration; this
   is only available for `restic` commands since all `rescript` commands already
   displays an output with date, time and duration. Now `restic` commands will not
   display this output unless specified; version 3.3 displays the output for all
   commands automatically even when it doesn't make any sense. This flag must be
   indicated before any command and it can be combined with `--log`.
3. Changed the behavior for `--log` flag; for version 3.3 and erlier this flag
   was only available for `rescript` commands. Changing the behavior means that
   from now on it will be indicated before any commands and options and now it can
   be used for `restic` commands too and it can be combined with `--time`.
   e.g.: `rescript [repo_name] --time --log check --read-data`.
4. All flags now have a shorthand flag. e.g.: `--help, -h`, `--host, -H`, `--log, -l`,
   `--time, -t`, `--snapshot, -s`, `--tag, -T`, etc.

`--time` and `--log` will not work if indicated at the end of the commands. This was
the only way I found that can be useful for all commands including `restic` commands
alone.

**Fixes**:

1. Fixed output for `cleanup --next` to display singular words when days, hours
   or minutes are 1.
2. Fixed "Build Exclusions" menu; it wasn't recognizing `back` or `exit` options.
3. Fixed a couple of typos.


# December 19, 2018
**Fixes**:

1. Fixed code for Mac OS and FreeBSD when using the `automatic` function, `cleanup`
   command, `cleanup --next`; also `config` and `editor` commands were having
   trouble because of `sed` and now, if you follow the README instructions for
   Mac and FreeBSD, you're not supposed to have any trouble.

# December 18, 2018
**Fixes**:

1. Fixed some issues with the output with Mac OS and FreeBSD when displaying the
   Operating System.
2. Fixed some issues with the ouptput when running the `automatic` function for
   FreeBSD and Mac OS.

**To do**:

1. Fix code for Mac OS and FreeBSD when using the `automatic` function. The `date`
   command is not reading the date from the "datefile". So the "CLEAN" variable
   does not work with FreeBSD and Mac OS for now.

# December 16, 2018
**Changes and Fixes**:

1. Added two functions: one determines the operating system (if it is GNU/Linux, FreeBSD or OSX)
   and another to calculate duration of commands.
2. Added output with date and duration for regular restic commands.
3. Added `--host` flag for backup operations and variable in the configuration
   file for this flag. If the variable is empty the `backup` command will use
   the system `HOSTNAME`. If the variable is used then `backup` command will use
   the hostname indicated in it (fix for issue #1).

# December 12, 2018
**Changes and Fixes**:

1. Added a warning when indicating a rescript invalid flag and displays help.
2. Added "PATH" code for `$HOME/bin` and `$HOME/.local/bin` because if you use 
   cron job and `restic` binary is not in the default system "PATH", it will
   not execute.
3. Fixed code to keep flags and options inside functions.
4. Fixed `restorer` command so it will not misbehave when using invalid options or flags.
5. Other improvements in code.

# November 25, 2018
**Changes**

Ended up redesigning the whole thing. Check the README.
Now the script use functions, a whole new menu in `config`, new commands and flags.

# November 14, 2018
**Changes and Fixes**:

1. Added dialog when you run `rescript config` to choose the text editor and 
   open configuration files.
2. Fixed `logs` command when running `--list` or `--remove`. From now on if your
   `recript` instance doesn't have any log it will display a message telling you
   that there are not any log files to list or remove.

# November 3, 2018
**Changes**:

1. Added some commands (check the [Commands and Options](https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#commands-and-options) section in README):
	1. `install, --install`
	2. `config, --config`
	3. `logs, --logs`
	4. `version, --version`

2. Added a configuration file which contains all variables.

**Fixes**:

1. Fixed the "Destination" output which was displaying the backup directory instead, if leaved blank.

# October 20, 2018

**Changes**:

1. Added "LOGGING" variable to keep logs in your `.rescript/logs` file.
2. Fix date format so it display AM or PM hours.

# October 10, 2018

**Changes**:

1. Added the `-e` option. Use `rescript -e --help` for usage or see README file.
2. Added B2 credentials option.
3. Added an exclusion file and generic exclusion lists.
4. Added `--keep-last` option.
5. Added an option to automatically move `datefile` from `logs` to `config` directory.
6. Removed the exclusion list (unneccesary with exclusion file).

**Fixes**:

1. Typos.
2. Reset credentials.

# October 6, 2018

**Changes**:

Basically, changes are less user commands and more restic commands.
Now all restic commands are available within the script (not sure if this is
the best approach but it works). Past "user commands" were removed
except for `-r` (restore). The only restic commands that are not "available"
(in the sense that if you execute it it will not behave as restic itself) are:

1. `backup`: the command exists but it will behave the same as `-b`.
2. `help`: this command will display the `rescript` help.
3. `version`: this will display the `rescript` version you're using.

# October 2, 2018

**Changes and Fixes**
1. There are changes in v1.5 with the output; now it will display the 
   host and if you do not indicate the "Destination" it will output
   the backup directory instead.
2. Added a "help" command so if you type ./rescript.sh help it will
   actually display the help for the script and not the help for 
   restic (I consider this a fix too because to display the restic
   help is not the best approach because commands may vary).
3. Added "flags" for "user options". Now every user option have its
   own "--help" flag wich will display how to use every option.
   Also, added the ability to pass restic options for those "user
   options" (all explained in the `--help` flag).

In general, now the script has many more options that it used to.
Still, the purpose hasn't changed. I did this for the sole purpose
of getting a nice output (at least for me it looks nice) for automatic
backups and to clean itself in "X" numbers of days. As time has passed
I needed to do some tasks in my repo and having multiple hosts in one
repo and working with various repos, it needed some attention that 
I wasn't able to do automatically or with the script, so I added those
options that I mostly use to make my life easier.

# September 27, 2018

**Changes and Fixes**
1. Divided the "REPO INFO" into two: the ones you MUST put and 
   cannot be left blank and the ones that you can left blank.
2. Now the script will set the "$HOME/bin" and "$HOME./local/bin" (if 
   directories exist) paths in case these paths are not already set, 
   then it won't fail if you have the restic binary in your home directory.
3. The "datefile" will now be created only if you set the "CLEAN" value.
4. Restore option was moved to "User options" instead of the "Automatic" ones.
   I discovered how to use "$OPTARG" for restores, so... yeah, now 
   you can just put the snapshot you want to restore after the `-r` option.
5. The `-n, -next-cleanup` options was giving negative numbers if the time
   for the next "cleanup" already passed, so now it will give you a message
   saying that it will be run "on the next run". Also, if you have not
   set the "CLEAN" variable it will display an explanation on how to do it
   and give you the "usage" link for more information.
6. Any atempt to pass an "User Option" (requires one argument) will tell you
   that "No argument value was indicated for..." the option you chose and it will
   display the "help".
7. The "cleanup" process was changed a little to display the days, hours or minutes
   left to the next "cleanup" and now it will forget first, prune and check --cleanup-cache
   at the end.

# September 21, 2018

**New Options and Some Fixes**

New options are available now. The new options are:

**Automatic Options**
1. `-d, -deep-check`: this option will perform `check` with the `--read-data`
   flag.
2. `-n, -next-cleanup`: this will display when the next "cleanup" will be done.
3. `-s, -stats`: this will display the `stats` with `--mode` flag for 
   original size of latest snapshot, deduplicated size of latest snapshot,
   original size of all snapshots and deduplicated size of all snapshots.
4. `-u, -unlock`: this option WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the 
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this option
   and it will delete the lock file so you can continue with your operation.

**User Options**

I've added some more options called "User Options" because it requires more than
just the option; these options require a "argument".

**Usage**: `./rescript.sh [user_option] [argument]`

1. `-f`: this option is for `forget`; you need to type the `-f` and the snapshot
   ID you want to forget like `./rescript.sh -f 0005sdf6`, for example.
2. `-g`: this option is for `find`; it will help you find a file or directory
   inside your repo when you type `./rescript.sh -g file_pattern_or_directory`.
3. `-k`: this stands for `keys`; you can use any option of the `key` command
   with this option like `./rescript.sh -k list`, for example.
4. `-l`: this option is for `ls` to list files in a snapshot; example:
   `./rescript.sh -l latest`.

You can just use one argument with every "user option". This means that, for
example, you can just use `-f` for one snapshot at a time. I'm using `getopts`
for this and I don't really know how to make this run with infinite arguments.
If you know how to make this better, please feel free to share.

**Fixes**

1. Typos and quoting.
2. Remove `unlock` automatically; you can just use `./rescript.sh unlock` if needed.
3. Now the script will create the lock file for every option except for `-h` and `-v`.
4. Now the script will create one directory with two subdirectories. The main
   directory will be hidden in your `/home` and it will be called `.rescript`; it
   a subdirectory called "lock" where it will be placed the lock file and another
   called "logs" where it will be placed the datefile. I changed it this way
   for convenience. Instead of looking into `./local/etc/etc` I wanted a single
   directory with all the script related files. Also, I use this script with 
   a cron job and logs files are created every run with the cron job and I find
   it convenient to create a `log` file if anyone uses the script the same way.
5. "Commands" code was unnecessary so I just simplified the code a little. Also
   note that **you can run almost every restic command** but the downsize is that
   you cannot run restic options or flags. That means that you can just run
   restic commands that does not require an option (like the "available commands"
   list you get when you type `-h`.)

Change the name from `restic.sh` to `rescript.sh` to not be confused by the 
actual program.

# September 14, 2018

**Commands & Options**

So, I've been playing around with the script and added a few nice features.
Now the script has its own `-h, -help` option so you can see all commands
and options available but the following is an short explanation of the
new options:
1. `-b, -backup`: this option is pretty basic; it does what it says... it'll
   take a new snapshot.
2. `-c, -cleanup`: this option will execute `forget` according to the policies
   indicated in your script; also it'll execute the `--prune` flag so it'll
   actually delete the forgotten snapshots.
3. `-h, -help`: this will bring up the help dialog on your terminal emulator.
4. `-m, -mount`: this option will mount your repository; it'll create a 
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
5. `-r, -restore`: this option will do what it says, it will restore.
   It will create a new directory in your `/home` called `restic-restore`
   and it will restore your latest snapshot only. If you want to restore
   a specific snapshot you will have to do it manually.
6. `-v, -version`: this option will display the current version you're using
   of this script.

# September 10, 2018

**Arguments**:

Now the script could be use with the five following arguments:
1. `check`
2. `init`
3. `prune`
4. `snapshots`
5. `unlock`

You can use these arguments as follows:

`./restic.sh argument`

# September 2, 2018
**Changed the way to handle check, forget and prune along with new additions:**
---
1. Now the script will create a "date file". This will be used to know when it'll 
   need to prune according to your choice in the "CLEAN" variable. The default 
   is 7 which means that the script will run `check`, `forget` and `prune` 
   every 7 days. The file that will be created will only contain the date the 
   script was executed when it runs `check`, `forget` and `prune` and it'll be 
   created as a hidden file. The file will be called `.datefile_restic` and it'll 
   be created in the same directory you put the script. If the file is deleted then 
   it'll run `check`, `forget` and `prune` on the next run and it'll create the 
   file again.
2. The script will now check if your repository is locked. This will be done by 
   checking the `locks` directory inside your repository. If the repository is locked 
   it'll run `restic unlock` to proceed with its operation. This operation is optional
   and by default it is set to `no` in the variable called `UNLOCK` at the 
   beginning of the script. If you're using this script for multiple machines just
   you're better leaving the script by default. I haven't tested it with
   a repository for multiple machines.
3. Now the script will tell you the files you're excluding in your snapshots 
   after the backup.
4. The `clean`, `forget` and `prune` operations are calculated because of the 
   `datefile` that now the script will create. When you run your backups and 
   it's not time yet to run this commands it'll output the total amount of 
   days, hours and minutes left until the next "clean" operation.

# August 27, 2018

Added the things you'll want to change at the beginning of the script so 
you don't have to read the whole script trying to figure out what to change or not;
instead I'm using variables at the beginning that you'll use for your password,
repo directory, backup directory, destination, keep and exclude policies, etc.

# August 25, 2018

Edited "Bail if restic is already running". Now the script will 
create a little "lock" file so if the script is already running it'll know
because the "lock" file created by the latest process is present. Also, if the
process is killed, terminated, exited, interrupted or quit (so maybe you killed
restic itself or you just restarted or turned off your computer) the "lock" file
will be deleted by the script so you don't have to delete it yourself when you
decides to make another backup. This way, if you're running two separate
tasks using restic the script will still run, because maybe you have two
different repositories and both can start at the same time but using the method
before this change you can't do it because it detects restic itself running
and it will not run until restic is not being used; with this new change
you can work with other repositories and still have this script running.
The whole change it supposed to be transparent if you're using the script. If
you still want to use the other method you can replace the "if" and "trap" codes/lines
with this:
 
``#Bail if restic is already running
if pidof -x restic >/dev/null; then
    echo "Restic is already running"
    exit
fi``

# August 19, 2018

Added start date and hour of script, end date and hour of script
and duration of all script at the end.

# August 18, 2018

Added "Bail if restic is already running" so if there's a previous
job that is not finished it doesn't mess it up and just let it finish.