---
title: Uninstall Rescript
---

To remove Rescript from your system cleanly, it is highly recommended to use the built-in `uninstall` command. This will automatically handle removing the binary from your `PATH`, removing the bash autocompletion, and optionally cleaning up your configurations and logs.

```bash
rescript uninstall
```

**[View the uninstall command documentation](home/commands/uninstall-cmd)**

In all cases, remember that you will still have the `.rescript` hidden directory in your `$HOME` directory if you choose not to delete it during the uninstallation process. If you didn't store your repository credentials elsewhere, make sure to backup this directory or copy the configuration files located in `$HOME/.rescript/config/repo_name.conf` before manually deleting this directory.

**[⇦ Home](home)**