---
title: rescript extract
---

The `extract` command restores a single file or directory from a specific snapshot to your local machine. It features a custom progress bar to monitor extraction speed.

### Usage
```bash
rescript [repo_name] extract [snapshot-ID] [path/in/snapshot] [local/destination]
```

### Examples

**Extract a single document from a specific snapshot ID to your desktop:**
```bash
rescript my_repo extract 3a4b5c6d /home/user/Documents/report.pdf /home/user/Desktop/
```
*Output:*
```text
[0:02] 100.00%  1 / 1 files extracted
```

**Extract an entire folder:**
```bash
rescript my_repo extract 3a4b5c6d /home/user/Photos /home/user/Desktop/RecoveredPhotos/
```

**[⇦ Commands](../commands-and-options)**
