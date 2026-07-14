# Rescript - POSIX-compliant Bash shell wrapper for Restic

`rescript` is a POSIX-compliant Bash shell wrapper for [Restic](https://restic.net/) that makes it easy to configure repositories and work with them. The script was made for GNU/Linux systems but it may also work on MacOS and FreeBSD.

> [!WARNING] DISCLAIMER / USE AT YOUR OWN RISK
> I'm not a developer, programmer or anything related; I'm just a regular user sharing my basic knowledge. I created this for my personal use but decided to share it because when I was looking for something like this, I did not find something that could fulfill my expectations. I know maybe there are some things in my script that can be done in a different way, better or even more easily but unfortunately I don't have enough knowledge. You're more than welcome to get in touch if you want to contribute, fix, add something, etc.

## Installation

### Dependencies
1. `restic` >= 0.9.2
2. `wget`

You can install the script using the following commands:
```bash
git clone https://gitlab.com/sulfuror/rescript.sh.git
cd rescript.sh
chmod 700 rescript
./rescript install
```

| Options | Installation Directory |
| ------- | ---------------------- |
| 1. System-wide | `/usr/bin` |
| 2. For this user | `~/bin` or `~/.local/bin` |

*(Note: If you choose option 2, make sure your `$PATH` includes `~/bin` or `~/.local/bin` in your `.profile`).*

## Documentation

For full documentation regarding advanced usage, commands, global configuration (`v6.0+`), security, cron jobs, and specific OS requirements (Mac/FreeBSD), please visit our official Wiki:

📚 **[Read the Official Rescript Wiki](https://gitlab.com/sulfuror/rescript.sh/-/wikis/home)**

*(Alternatively, you can browse the raw Markdown documentation inside the `docs/` folder of this repository).*

## Having problems?

If you have any problem with the script you can reach out so it can be fixed.
If you have any problem using restic check out the [restic forum](https://forum.restic.net/); maybe you can find answers or submit a question about your problem. I'm not affiliated with the **restic** team in any way.