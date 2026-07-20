---
title: Help
---
Display rescript usage and general information about the script's flags and commands. You can also use it to get specific help for a command.

Usage:
```bash
rescript help
rescript help [command]
```

### Example Output

```text
Name        : rescript
Author      : Sulfuror, Copyright (c) 2018 <sulfuror@gmail.com>
URL         : https://gitlab.com/sulfuror/rescript.sh
License     : BSD 2-Clause License
Version     : 6.0
Description : rescript is a bash shell wrapper for restic

Information about restic: https://restic.net

This script will run backup, snapshots, forget, prune, check and
stats commands automatically by just indicating the name given
to your configuration file (repo_name). e.g.:

  rescript [repo_name]

Usage:
  rescript [config_command]
  rescript [repo_name] [command] [flags] ...
  rescript [repo_name] [restic_command] [flags] ...

To execute a command across ALL configured repositories sequentially,
use the 'all' keyword instead of a specific repo name. You can use
--ignore-repo to ignore specific repositories. e.g.:

  rescript all [command] --ignore-repo [repo_name]

Configuration commands:
  config                Rescript configuration.
  editor                Change default text editor used by rescript.
  help                  Display rescript usage.
  install               Install rescript.
  update                Check/install new rescript version.
  version               Display rescript version.

Commands:
  automatic             Run backup and cleanup policies sequentially.
  backup                Take a snapshot.
  cleanup               Apply retention policies and prune.
  diff                  Compare two snapshots.
  env                   Display values in your configurations.
  extract               Extract a specific file or directory.
  history               Show version history of a given file.
  info                  Display stats for latest and all snapshots.
  init                  Initialize a new restic repository.
  logs                  List, view or remove your log files.
  mounter               Mount a restic repo.
  next                  Display next scheduled automatic cleanup time.
  restorer              Restore a restic snapshot.
  search                Find a file or directory across snapshots.
  size                  Calculate recursive size of a given path.
  snaps                 List snapshots in your repository (compact mode).
  status                Print a dashboard with the status of your repositories.
  umounter              Unmount a previously mounted restic repository.
  unlocker              Remove lock created by rescript.
  upgrade               Upgrade restic repository to the latest format.

Global flags:
  -D, --debug           Debug script.
  -E, --email           Force to send email with output.
  -h, --help            Display usage.
  -L, --log             Create log file with command output.
  -M, --metadata        Display execution context metadata.
  -Q, --quiet           Silence output.
  -S, --simulate        Run destructive operations in dry-run mode.
  -T, --timer           Display output with date, time and duration.

Commands usage:
  rescript help [command]
```

**[⇦ Commands](home/commands-and-options)**
