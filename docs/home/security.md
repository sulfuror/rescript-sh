---
title: Security
---
By default, the configuration files are as secure as your computer/user. `rescript` itself does not
contain any information about your repositories. Configuration files hold that information and when
a configuration file is created, it is created inside the user's home directory with `chmod 600` for the file,
so if another user is navigating through the user's files, they can see the file but not the content.

> [!WARNING]
> Because `PRE_CMD` and `POST_CMD` are executed via `eval`, it is critical that configuration files are never world-writable (i.e. permissions should be `600`). If a malicious user can write to the `.conf` file, they can inject arbitrary commands that will run with your privileges (e.g. as `root` if running from cron).

If you share a user in your computer or you are just paranoid, then you should create a password file for your
repository and encrypt it. Using GPG is a great way to do this and all you need to do (after creating your encrypted password file)
in the configuration file is edit the password variable as follows:
```
RESTIC_PASSWORD="$(cat <(gpg -qd /path/to/your/password_file.gpg))"
```
Since GPG will ask for your passphrase, this will not work with automatic jobs (such as using `cron`). You can edit
the time for your keyring to remember your passphrase. **_DO NOT save your passphrase in plain text or to your keyring_**; that's
bad practice and it is as secure as not using encryption at all.

Another option is to not save your password in your configuration file and export `RESCRIPT_PASS`. As long as your session
is active, this variable will work. Once the session is closed you will need to export this variable again. Use it as follows:
```
~$ export RESCRIPT_PASS=mytotallysecurepassword
```

**[⇦ Home](home)**