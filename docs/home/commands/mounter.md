---
title: mounter
---

The `mounter` command allows you to mount your remote or local backup repository as a virtual file system in your `/home`. This lets you browse your backups exactly like regular folders using your file manager.

### Usage
```bash
rescript [repo_name] mounter [--background]
```

### Flags
- `--background`: mount the repository in the background without locking your terminal session. A PID file is created in `/tmp`.

### Examples

**Mount the repository interactively:**
```bash
rescript my_repo mounter
```
*Your terminal will be locked while the mount is active. Press `Ctrl+C` in this terminal to unmount.*

**Mount the repository in the background:**
```bash
rescript my_repo mounter --background
```
*This allows you to close the terminal while the repository remains mounted. Use the `umounter` command to unmount it safely.*

**[⇦ Commands & Options](../commands-and-options)**
