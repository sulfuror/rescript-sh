### Basics 

You can use this script using an **_automatic_** function that will run `backup`,
`snapshots`, `forget`, `prune`, `check` and `stats` using your configuration
file. If your "LOGGING" variable is "yes" it will also create a log file with
the output. If you want to use the automatic function just type the following:

```
rescript [repo_name]
```
Using `rescript` this way is perfect for `cron` since you can set the configuration
file to save you a logfile, it will run all commands and if anything fails it will
send you an email (you need `mailutils` installed) using `mail` utility.
You need to setup this on your own so it can send you and email if you put your
email address in the `EMAIL` variable inside your configuration file.

Rescript has its own commands that doesn't need a `[repo_name]` indicated. These
commands are: `config`, `editor`, `help`, `install` and `version`.

Usage:

```
rescript [config|editor|help|install|version]
```

Use `rescript` commands:

```
rescript [repo_name] [command] [--flags] ...
```

Use `restic` commands:

```
rescript [repo_name] [restic_command] [flags] ...
```

For `rescript` commands info and usage:
```
rescript help [command]
```
First thing to do is to configure your repository by typing:

```
rescript config
```
This command will display a dialog where you'll be asked to select a text editor
you want to use. You can also use the interactive wizard by typing `rescript config --wizard` to instantly bootstrap a new repository profile without opening a text editor.

Once the text editor is set (or if you used the wizard), you can configure your settings. If you don't have any repo remember to run `rescript [repo_name] init`
after configuring `rescript` or else it will fail to do anything.

> [!NOTE]
> **Auto-Heal (Network Retries)**: (v6.0+) Rest assured that all destructive or network-intensive commands (like `backup`, `check`, `prune`) are wrapped with a self-healing retry loop. If `restic` fails with a network timeout, Rescript will automatically pause and retry the command up to 3 times.

### Configuration files

The configuration process has been moved to its own page. For detailed information on `RESTIC_PASSWORD`, global configurations, retention policies, webhooks, and exclusions, please refer to:

**[Configuration Files](Configuration-Files)**

**[⇦ Home](Home)**