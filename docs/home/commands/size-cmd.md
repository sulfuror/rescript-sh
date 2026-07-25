---
title: size
---

The `size` command calculates the total size of a specific directory within a snapshot by parsing the `restic ls` output. If no snapshot is specified, it defaults to calculating the size in the `latest` snapshot. It wraps the process with a custom progress bar.

### Usage
```bash
rescript [repo_name] size [snapshot-ID] <path> [flags]
```

### Command flags
* `-H, --host hostname`: Only consider snapshots for this host (only applies when no snapshot ID is provided, defaulting to `latest`).

### Examples

**Calculate the size of a directory in the latest snapshot:**
```bash
rescript my_repo size /home/user/Documents
```
*Output:*
```text
Calculating total size        : [####################](100%)

Total size for [/home/user/Documents] in snapshot latest: 40.80 GB
```

**Calculate the size of a directory in a specific snapshot:**
```bash
rescript my_repo size 3a4b5c6d /home/user/Documents
```
*Output:*
```text
Calculating total size        : [####################](100%)

Total size for [/home/user/Documents] in snapshot 3a4b5c6d: 40.80 GB
```

**[⇦ Commands & Options](../commands-and-options)**
