# Rescript - POSIX-compliant Bash shell wrapper for Restic

`rescript` is a POSIX-compliant Bash shell wrapper for [Restic](https://restic.net/) that makes it easy to configure repositories and work with them. The script was made for GNU/Linux systems but it may also work on MacOS and FreeBSD.

> [!WARNING] DISCLAIMER / USE AT YOUR OWN RISK
> I'm not a developer, programmer or anything related; I'm just a regular user sharing my basic knowledge. I created this for my personal use but decided to share it because when I was looking for something like this, I did not find something that could fulfill my expectations. I know maybe there are some things in my script that can be done in a different way, better or even more easily but unfortunately I don't have enough knowledge. You're more than welcome to get in touch if you want to contribute, fix, add something, etc.

## Installation

For complete installation instructions, dependencies, and configuration options, please refer to the **[Installation guide on the Wiki](https://gitlab.com/sulfuror/rescript.sh/-/wikis/home/installation)**.

## Key Features

- **Native Bash Autocompletion:** Running `rescript install` automatically configures Programmable Bash Autocompletion, enabling you to use `TAB` to quickly auto-complete configured repositories, commands, and global flags.
- **Global Configuration & Hooks:** Define global retention policies and pre/post execution hooks.
- **Auto-Heal & Parallel Execution:** Network retries and parallel orchestration.

## Documentation

For full documentation regarding advanced usage, commands, global configuration (`v6.0+`), security, cron jobs, and specific OS requirements (Mac/FreeBSD), please visit our official Wiki:

📚 **[Read the Official Rescript Wiki](https://gitlab.com/sulfuror/rescript.sh/-/wikis/home)**

*(Alternatively, you can browse the raw Markdown documentation inside the `docs/` folder of this repository).*

## Having problems?

If you have any problem with the script you can reach out so it can be fixed.
If you have any problem using restic check out the [restic forum](https://forum.restic.net/); maybe you can find answers or submit a question about your problem. I'm not affiliated with the **restic** team in any way.