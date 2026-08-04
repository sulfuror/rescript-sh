# Rescript - POSIX-compliant Bash shell wrapper for Restic

![GitHub Release](https://img.shields.io/github/v/release/sulfuror/rescript-sh)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/sulfuror/rescript-sh/release.yml)
![License](https://img.shields.io/github/license/sulfuror/rescript-sh)

`rescript` is a POSIX-compliant Bash shell wrapper for [Restic](https://restic.net/) that makes it easy to configure repositories and work with them. The script was made for GNU/Linux systems but it may also work on MacOS and FreeBSD.

> [!IMPORTANT]
> **About this Project**: I originally created this tool for my personal use to simplify Restic backups, as I couldn't find an existing solution that fit my needs. Over time, it has evolved into a POSIX-compliant wrapper. While I'm constantly learning and improving the codebase, community feedback is invaluable. You are more than welcome to open issues, suggest improvements, or submit Pull Requests if you'd like to contribute. For history purposes, the original repository is [gitlab.com/sulfuror/rescript.sh](https://gitlab.com/sulfuror/rescript.sh).

## Quick Look

### Interactive Dashboard (`status`)
![Rescript Dashboard](https://raw.githubusercontent.com/sulfuror/rescript-sh/master/assets/rescript_status.gif)

<details>
<summary><b>Click to see more command examples (Automatic, Backup, History, Size)</b></summary>

### Smart Workflow (`automatic`)
![Automatic Command](https://raw.githubusercontent.com/sulfuror/rescript-sh/master/assets/rescript_automatic.gif)

### Manual Backup with flags (`backup -T -M`)
![Backup Command](https://raw.githubusercontent.com/sulfuror/rescript-sh/master/assets/rescript_backup.gif)

### File History (`history`)
![History Command](https://raw.githubusercontent.com/sulfuror/rescript-sh/master/assets/rescript_history.gif)

### Snapshot Size (`size`)
![Size Command](https://raw.githubusercontent.com/sulfuror/rescript-sh/master/assets/rescript_size.gif)

</details>

## Installation

For complete installation instructions, dependencies, and configuration options, please refer to the **[Installation guide on the Wiki](https://github.com/sulfuror/rescript-sh/wiki/installation)**.

## Key Features

- **Centralized Repository Management:** Manage multiple Restic repositories easily using simple `.conf` profile files.
- **Orchestrator Mode:** Run operations across all your repositories at once using the `all` command, either sequentially or in parallel (`-P`).
- **Smart Automatic Workflow:** The `automatic` command intelligently handles your backups, printing exclusions, enforcing retention policies, calculating cleanup schedules based on configurable datefiles, and validating repository integrity.
- **Global Configuration & Hooks:** Define global settings (`global.conf`), environment variables, and automated `PRE_CMD` / `POST_CMD` hooks that run before or after your backups.
- **Push Notifications & Alerts:** Native support for webhooks (Discord, Slack, etc.) and email alerts to notify you of successful operations or failures, including log attachments.
- **Interactive Dashboards & Utilities:** Quickly view your repositories' `status` (size, snapshot count, latest backup date, and deep integrity checks), track file modification `history`, or `extract` files easily.
- **Native Bash Autocompletion:** Running `rescript install` configures programmable Bash completion, letting you `TAB`-complete your configured repositories, commands, and flags.
- **Safety First:** Most destructive actions support a dry-run/simulate mode (`-S`) to preview changes without modifying data, and a strict locking mechanism prevents concurrent execution collisions.

## Documentation

For full documentation regarding advanced usage, commands, global configuration (`v6.0+`), security, cron jobs, and specific OS requirements (Mac/FreeBSD), please visit our official Wiki:

📚 **[Read the Official Rescript Wiki](https://github.com/sulfuror/rescript-sh/wiki/Home)**

*(Alternatively, you can browse the raw Markdown documentation inside the `docs/` folder of this repository).*

## Feedback & Support

If you encounter any bugs, have feature requests, or have a problem with the script, please [open an Issue](https://github.com/sulfuror/rescript-sh/issues) on GitHub.

If you have any problem using Restic itself, check out the [Restic forum](https://forum.restic.net/); maybe you can find answers or submit a question about your problem. I am not affiliated with the **Restic** team in any way.

## License

This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details.
