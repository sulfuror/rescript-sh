---
title: extract
---

The `extract` command restores a single file or directory from a specific snapshot to your local machine. It features a custom progress bar to monitor extraction speed.

### Usage
```bash
rescript [repo_name] extract [snapshot-ID] [path/in/snapshot]
```

### Examples

**Extract a single document from a specific snapshot ID to your current directory:**
```bash
rescript my_repo extract 3a4b5c6d /home/user/Documents/report.pdf
```
*Output:*
```text
Extracting [/home/user/Documents/report.pdf] to [./report.pdf]...
[0:02] 100.00%  1 / 1 files extracted
```

**Auto-detect the latest snapshot and extract a folder:**
```bash
rescript my_repo extract /home/user/Photos
```
*Output:*
```text
Auto-detecting latest snapshot for this file...
Extracting [/home/user/Photos] to [./Photos]...
[0:02] 100.00%  1 / 1 files extracted
```

**[⇦ Commands & Options](../commands-and-options)**
