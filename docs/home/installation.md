---
title: Installation
---
### Dependencies:
1. restic >= 0.9.2
2. wget

You can install the script using the following commands:

```
~$ git clone https://gitlab.com/sulfuror/rescript.sh.git
~$ cd rescript.sh
~$ chmod 700 rescript
~$ ./rescript install
```
|Options | Installation Directory |
| -----  |  --------------------  |
|1. System-wide | `/usr/bin` |
|2. For this user | `~/bin` or `~/.local/bin` |

If you chose the second option make sure to have these lines inside your `.profile`.

```
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi
```
If you don't have these lines in your `.profile` then just copy those and paste it
at the end. Once everything is set, if it's not working properly don't panic, maybe the `~/.local/bin`
wasn't there and the script created it and you only need to restart your session, or log out and login, or reboot
your computer in order for this work. The same applies if you needed to copy and paste the code mentioned above.

### Different repositories

You can use `rescript` to easily manage different repositories by creating a
configuration file for every repository (it is done via `rescript config`) and
assigning an easy name to remember for each repository.

**[⇦ Home](home)**