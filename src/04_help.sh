# Commands Help																									 #
# ============================================================== #


function backup-help {
cat <<EOF
[backup] is for [backup] command in restic

This command will take a new snapshot using the values set
in your configuration file.

Usage:
  rescript [repo_name] backup [flags]

Command flags:

  -C, --check           Check for errors in repository.
  -U, --cleanup         Apply retention policies and prune.
  -I, --info            Display stats for latest and all snapshots.
  -O, --skip-office     Temporarily exclude open (in-use) 'Office'
                        documents (.xlsx, .docx, .ods, odt, etc.).

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] backup [flags] -- [restic_flags/options] ...

EOF
}

function cleanup-help {
cat <<EOF
[cleanup] is for [forget] and [prune] commands in restic

This command will apply the [forget] policies set in your
configuration file and then execute [prune] to actually
delete the data that has been forgotten.

Usage:
  rescript [repo_name] cleanup [flags] [options]

Command flags:

  -C, --check           Check for errors in repository.
  -I, --info            Display stats for latest and all snapshots.
      --reset           Remove "datefile"; it resets the dates for
                        the CLEAN option in your configuration file.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] cleanup [flags] -- [restic_flags/options] ...

EOF
}

function next-help {
cat <<EOF
[next] displays the next scheduled automatic cleanup time.

This command will read the CLEAN variable in your configuration
file and tell you when the next cleanup and check is scheduled
to occur.

Usage:
  rescript [repo_name] next [flags]

Global flags:
  -h, --help            Display usage.
  -T, --timer           Display output with date, time and duration.
EOF
}



function config-help {
cat <<EOF
[config] is an interactive command to make easy the to set up rescript
configuration and exclusions files. You can create, edit, list
and open your configuration and exclusions files.

Usage:
  rescript config

Global flags:
  -h, --help            Display usage.

EOF
}

function diff-help {
cat <<EOF
[diff] compares the two latest snapshots in your repository to show what
files were added, modified, or removed. You can also pass specific
snapshot IDs to compare them.

Usage:
  rescript [repo_name] diff [snapshot1] [snapshot2]

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] diff [flags] -- [restic_flags/options] ...

EOF
}

function editor-help {
cat <<EOF
[editor] is to select or change the default text editor
to be used to open the rescript configuration and
exclusion files. This will list the most common text editors
used and also have an option to write the executable name
of your favorite text editor if not listed.

Usage:
  rescript editor

Global flags:
  -h, --help            Display usage.

EOF
}

function env-help {
cat <<EOF
[env] is to display the variables values in your
configuration file.

Usage:
  rescript [repo_name] env

Command flags:
  -V, --var VARNAME     Display varname value chosen.

Global flags:
  -h, --help            Display usage.

EOF
}

function extract-help {
cat <<EOF
[extract] allows you to quickly dump a specific file or directory from
a snapshot directly to your current working directory.
If no snapshot ID is provided, the script will automatically search for
the latest snapshot containing that file.

Usage:
  rescript [repo_name] extract [snapshot_id] <file_path>

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] extract [snapshot_id] <file_path> -- [restic_flags/options] ...

EOF
}

function info-help {
cat <<EOF
[info] is for [stats] command in restic

This command will display restore and deduplicated (raw-data)
size of latest and all snapshots in a custom format.

Usage:
  rescript [repo_name] info [flags]

Command flags:
  -H, --host hostname   Only consider snapshots for this host.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

EOF
} 

function install-help {
cat <<EOF
[install] is to simply copy the script to your PATH directory
inside your HOME. If there is no PATH in your HOME then rescript
will ask you if you want to create one. If the answer is yes then
it will create a [/bin] directory inside your [./local] directory.
If the answer is no then it will exit. If you don't want to use
rescript from your PATH then remember to use it indicating the
complete path where the script is located; if you have set another
location for your PATH then just copy the script and put it there.

Usage:
  rescript install

Global flags:
  -h, --help            Display usage.

EOF
}

function logs-help {
cat <<EOF
[logs] is for log files saved by rescript

Usage:
  rescript [repo_name] logs
OR
  rescript [repo_name] logs [flag] [logfile]

Command flags:
  -W, --view logfile    Display output of selected log file.
  -R, --remove logfile  Remove all log files (use 'all' to remove
                        all logs related to the repository).

Global flags:
  -h, --help            Display usage.

NOTE: if you don't indicate a logfile when using [--remove]
it will delete all logfiles related to the [repo_name].

EOF
}

function mounter-help {
cat <<EOF
[mounter] is to automatically mount your repository in your HOME
directory so you can browse and restore your files.
When you finish just use [rescript repo umounter] or press [Ctrl+C].

Usage:
  rescript [repo_name] mounter [--background]

Command flags:
  --background          Mount the repository in the background.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] mounter [--background] -- [restic_flags/options] ...

EOF
}



function restorer-help {
cat <<EOF
[restorer] is for [restore] command in restic

This command will create a new directory in your /home/sulfuror
directory containing the restored files. The new directory will
be named with a unique name so it will not conflict with your
existing directories.

Usage:
  rescript [repo_name] restorer [flags] [host|path|snapshot ID|tag]

Command flags:
  -H, --host hostname   Only consider snapshots for this host
                        when snapshot-ID is [latest].
  -P, --path path       Only consider snapshots which include
                        this [absolute] path for snapshot-ID [latest].
  -Z, --snapshot ID     Indicate snapshot-ID to restore.
  -T, --tag tagname     Only consider snapshots which include this
                        taglist for snapshot-ID [latest].

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

EOF
}

function search-help {
cat <<EOF
[search] allows you to find a specific file or directory across all
snapshots in your repository, showing the snapshot ID and the date.

Usage:
  rescript [repo_name] search <pattern>

Command flags:
  -i, --ignore-case     Ignore case for pattern (e.g., *report* vs *Report*).

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] search [flags] -- [restic_flags/options] ...

EOF
}

function snaps-help {
cat <<EOF
[snaps] is is for [snapshots] command in restic

This is nothing more than [snapshots --compact] in restic.
You can use any restic available flags for [snapshots] command
but it will always display snapshots in compact mode.

Usage:
  rescript [repo_name] snaps [flags] [options]

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] snaps [flags] -- [restic_flags/options] ...

EOF
}

function unlocker-help {
cat <<EOF
[unlocker] is to remove the temporary lock created by rescript.
When rescript is running it will create a temporary lock file
to prevent the interruption of other processes that could be active
at the moment of executing another command within the same instance
(e.g. scheduled jobs). If you are sure there are not any other
processes running in the backgroup, then you can safely remove the
created by rescript using this command.

Usage:
  rescript [repo_name] unlocker

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

EOF
}

function update-help {
cat <<EOF
[update] is to update the rescript script itself.

Usage:
  rescript update

If script is located in /usr/bin:
  sudo rescript update

Global flags:
  -h, --help            Display usage.

EOF
}

function upgrade-help {
cat <<EOF
[upgrade] is to update the restic repository to the latest format (v2).

This command will execute [restic migrate upgrade_repo_v2] to upgrade
your repository. This is necessary to enable features like compression.

Usage:
  rescript [repo_name] upgrade [flags]

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

EOF
}

function size-help {
cat <<EOF
[size] calculates the total size of a specific directory within
a snapshot, parsing restic ls output. If no snapshot is specified,
it defaults to 'latest'.

Usage:
  rescript [repo_name] size [snapshot_id] <path> [flags]

Command flags:
  -H, --host hostname   Only consider snapshots for this host (only applies to 'latest').

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] size [snapshot_id] <path> -- [restic_flags/options] ...

EOF
}

function history-help {
cat <<EOF
[history] searches for a specific file across all snapshots
and displays a chronological table showing only the snapshots
where the file was modified or introduced as a new version
(based on changes in its Size or Modification Date).

Usage:
  rescript [repo_name] history <pattern>

Command flags:
  -i, --ignore-case     Ignore case for pattern.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -Q, --quiet           Silence output.
  -S, --simulate        Simulate execution (dry-run).
  -T, --timer           Display output with date, time and duration.

Make use of restic flags/options as follows:
  rescript [repo_name] history [flags] -- [restic_flags/options] ...

EOF
}

function umounter-help {
cat <<EOF
[umounter] unmounts a repository previously mounted with
[mounter --background] and cleans up the mount point.

Usage:
  rescript [repo_name] umounter

Global flags:
  -h, --help            Display usage.

EOF
}
