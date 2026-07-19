---
title: rescript backup
---

The `backup` command takes a snapshot using the values set in your repository's configuration file. In v6.0+, it features an auto-heal network retry loop for maximum resilience.

### Usage
```bash
rescript [repo_name] backup [flags]
```

### Flags
- `-C, --check`: check for errors in the repository after backup.
- `-c, --cleanup`: apply retention policies and prune immediately after backup.
- `-i, --info`: display stats for the latest and all snapshots after backup.
- `-S, --skip-office`: temporarily exclude open "Office Documents" to prevent locking issues.

### Examples

**Standard backup:**
```bash
rescript my_repo backup
```

**Backup, then run cleanup policies and check for errors:**
```bash
rescript my_repo backup -c -C
```

**Backup while temporarily ignoring open Office documents:**
```bash
rescript my_repo backup -S
```
*Useful if you run this manually while actively working on spreadsheets or text documents.*

**[⇦ Commands](../commands-and-options)**
