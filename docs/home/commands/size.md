---
title: rescript size
---

The `size` command calculates the exact size of a specific snapshot ID. Because Restic deduplicates data, calculating the isolated size of a single snapshot requires processing. This command wraps that functionality with a custom progress bar.

### Usage
```bash
rescript [repo_name] size [snapshot-ID]
```

### Examples

**Calculate the size of a specific snapshot:**
```bash
rescript my_repo size 3a4b5c6d
```
*Output:*
```text
[0:05] 100.00%  1234 / 1234 directories,  5678 / 5678 files

Total Size: 45.2 GiB
```

**[⇦ Commands](../commands-and-options)**
