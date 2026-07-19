---
title: Mac and FreeBSD
---
### Mac OS

1. Install [brew](https://brew.sh).
2. Install `coreutils` as follows: `brew install coreutils`.
3. Install `gnu-sed` as follows: `brew install gnu-sed --with-default-names`.
4. **NOTE**: `nano` works great as a default text editor; choosing another one with Mac
   could require a little tweaking with your script.
5. **OPTIONAL**: to include `~/bin` or `~/.local/bin` in your `PATH`, edit or create
   a file called `.bash_profile` in your `$HOME` by typing `nano .bash_profile`
   and after pasting this following line save it and close it using Ctl+x:
   ```
   export PATH=$PATH:$HOME/bin:$HOME/.local/bin
   ```
6. In order to use `mounter` (`restic mount`) you need to install a package
   called `osxfuse` via `brew`: `brew install osxfuse`. If you're using Mojave,
   you may need to type: `brew cask install osxfuse` or follow the instructions
   displayed in your terminal emulator when you typed the first command.

### FreeBSD

1. Install `coreutils` package by typing: `pkg install coreutils`.
2. Set the `PATH` for your `~/bin` or `~/.local/bin`.
3. `csh` work just fine with `rescript`.
5. I tested with FreeBSD only but I'm pretty sure it may work on other BSD systems.

> [!NOTE]
> If `~/bin` doesn't exist and you decide to use the `install` command,
`rescript` will automatically decide to use `~/.local/bin`, so before using
`install` you have to make sure to set your `$PATH` for both locations or move the
script manually to your `$PATH`.

**[⇦ Home](home)**