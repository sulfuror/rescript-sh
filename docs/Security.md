By default, the configuration files are as secure as your computer/user. `rescript` itself does not
contain any information about your repositories. Configuration files hold that information and when
a configuration file is created, it is created inside the user's home directory with `chmod 600` for the file,
so if another user is navigating through the user's files, they can see the file but not the content.

> [!WARNING]
> Because `PRE_CMD` and `POST_CMD` are executed via `eval`, it is critical that configuration files are never world-writable (i.e. permissions should be `600`). If a malicious user can write to the `.conf` file, they can inject arbitrary commands that will run with your privileges (e.g. as `root` if running from cron).

If you share a computer or want to maximize security, you should not save your repository password in plain text. Instead, you can use a password manager (like `pass`, `bitwarden-cli`) or an encrypted file (via GPG).

To do this, use the `RESTIC_PASSWORD_COMMAND` variable in your configuration file. This tells Restic to securely execute a command to fetch the password when needed, rather than storing it in a variable.

For example, using an encrypted GPG file:
```bash
RESTIC_PASSWORD_COMMAND="gpg --quiet --decrypt /path/to/your/password_file.gpg"
```
Or using the standard password manager `pass`:
```bash
RESTIC_PASSWORD_COMMAND="pass show restic/my-repo"
```

*Note: If your command requires interactive input (like a GPG passphrase prompt), it will interrupt automatic jobs like `cron`. You can configure your keyring or password manager agent to cache your passphrase temporarily.*

Another option is to not save your password in your configuration file and export `RESCRIPT_PASS`. As long as your session
is active, this variable will work. Once the session is closed you will need to export this variable again. Use it as follows:
```
~$ export RESCRIPT_PASS=mytotallysecurepassword
```

**[⇦ Home](Home)**