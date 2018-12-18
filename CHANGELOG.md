# December 18, 2018
**Fixes**:

1. Fixed some issues with the output with Mac OS and FreeBSD when displaying the
   Operating System.
2. Fixed some issues with the ouptput when running the `automatic` function for
   FreeBSD and Mac OS.

To do:

1. Fix code for Mac OS and FreeBSD when using the `automatic` function. The `date`
   command is not reading the date from the "datefile". So the "CLEAN" variable
   does not work with FreeBSD and Mac OS for now.

# December 16, 2018
**Changes and Fixes**:

1. Added two functions: one determines the operating system (if it is GNU/Linux, FreeBSD or OSX)
   and another to calculate durantion of commands.
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