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
*This will scan the snapshot and output the total bytes and file count it contains.*

**[⇦ Commands](../commands-and-options)**
