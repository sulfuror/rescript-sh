---
title: rescript restorer
---

The `restorer` command easily restores a snapshot. It will automatically create a new folder in your home directory (e.g., `restore-snapshotID-randomnumber`) and restore the contents there, ensuring no existing files are overwritten.

### Usage
```bash
rescript [repo_name] restorer [flags] [snapshot ID|tag|latest]
```

### Flags
- `-i, --interactive`: (v6.0+) opens a numbered, navigable menu allowing you to restore any snapshot with a single keystroke.

### Examples

**Interactive Restore (Recommended):**
```bash
rescript my_repo restorer -i
```
*This will fetch all available snapshots and present a numbered menu. Simply type the number corresponding to the snapshot you want to restore.*

**Restore the latest snapshot manually:**
```bash
rescript my_repo restorer latest
```

**Restore a specific snapshot ID manually:**
```bash
rescript my_repo restorer 3a4b5c6d
```

**[⇦ Commands](../commands-and-options)**
