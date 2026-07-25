---
title: Global Flags
---

Rescript provides several global flags that alter the behavior of its execution. These flags can be used across almost any command, whether it's a native Rescript command or a standard `restic` command passed through the wrapper.

### Index

- **[-D, --debug](#-d---debug)**: Enable trace debugging for the script.
- **[-E, --email](#-e---email)**: Force sending an email with the command output.
- **[-h, --help](#-h---help)**: Display help usage.
- **[-L, --log](#-l---log)**: Force creating a log file for the execution.
- **[-M, --metadata](#-m---metadata)**: Print execution context metadata before running the command.
- **[-Q, --quiet](#-q---quiet)**: Silence output completely.
- **[-T, --timer](#-t---timer)**: Calculate and display the total duration of the command.

---

### `-D, --debug`

Enables Bash trace debugging (`set -xv`). This prints every single line of the wrapper script as it is interpreted by the shell. It is incredibly verbose but essential if you are experiencing a bug in the wrapper itself and need to trace exactly where it is failing.

### `-E, --email`

Forces Rescript to send an email with the output of the command, regardless of the `CONFIRMATION_EMAIL` policy set in your configuration file. *Note: Requires `mailutils` to be installed and configured on your system.*

### `-h, --help`

Displays general help for the wrapper or specific usage instructions for a command if appended after the command name.

```bash
rescript my_repo backup --help
```

### `-L, --log`

Forces the creation of a log file for the current manual run, saving it in your repository's log directory. This happens even if `LOGGING="no"` is set in your configuration file.

### `-M, --metadata`

Prints a highly detailed "Execution Context" block at the very beginning of the output. This metadata block includes information about your OS, the restic version, execution mode, destination paths, and exclusions loaded.

**Example:**

```bash
rescript my_repo env --metadata
```

*Output:*

```text
================================================================================
                           Rescript Execution Context
================================================================================
  Date/Time      : 2026-07-20 12:12:55
  System         : Linux
  Hostname       : server-01
  Profile        : my_repo
  Command        : env
  Mode           : Live
  Backend        : Local
  Restic Version : 0.19.0
  Destination    : /backup/destination
  Backup Source  : /home/user/Documents
  Exclusions     : 6 rules applied
================================================================================
```

### `-Q, --quiet`

Silences all standard output from the command, making it completely invisible on your terminal.
*Note: If combined with `--log`, the output will still be written to the log file even though it won't be printed to the screen.*

### `-T, --timer`

Wraps the execution in a timer and appends a block at the very end of the output showing the total duration (in seconds, minutes, or hours) that the entire process took to complete.

**Example:**

```bash
rescript my_repo env --timer
```

*Output:*

```text
[... normal command output ...]
--------------------------------------------------------------------------------
Duration: 0 seconds
```

---

**[⇦ Commands & Options](commands-and-options)**
