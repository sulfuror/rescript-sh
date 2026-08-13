### Mac OS

1. **NOTE**: `nano` works great as a default text editor; choosing another one with Mac could require a little tweaking with your script.
2. **OPTIONAL**: to include `~/bin` or `~/.local/bin` in your `PATH`, edit or create a file called `.bash_profile` in your `$HOME` by typing `nano .bash_profile` and after pasting this following line save it and close it using Ctl+x:
   ```bash
   export PATH=$PATH:$HOME/bin:$HOME/.local/bin
   ```
3. In order to use `mounter` (`restic mount`) you need to install [macFUSE](https://osxfuse.github.io/) (formerly osxfuse). You can download it directly from their website or install it via Homebrew (`brew install --cask macfuse`).

### FreeBSD

1. Set the `PATH` for your `~/bin` or `~/.local/bin`.
3. `csh` work just fine with `rescript`.
5. I tested with FreeBSD only but I'm pretty sure it may work on other BSD systems.

> [!NOTE]
> If `~/bin` doesn't exist and you decide to use the `install` command,
`rescript` will automatically decide to use `~/.local/bin`, so before using
`install` you have to make sure to set your `$PATH` for both locations or move the
script manually to your `$PATH`.

**[⇦ Home](Home)**