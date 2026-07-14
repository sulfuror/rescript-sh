---
title: rescript diff
---

The `diff` command automatically compares two snapshots to show you exactly which files were added, modified, or deleted. 

### How it works
By default, Rescript automatically fetches the IDs of your two most recent snapshots and runs a `restic diff` between them. You don't need to manually find or specify any snapshot IDs. It acts as a transparent wrapper, so any additional Restic flags you pass will be applied seamlessly.

### Usage
```bash
rescript [repo_name] diff [flags] [options]
```

### Output Example

**Compare the last two snapshots:**
```bash
rescript my_repo diff
```
*Output:*
```text
comparing snapshot 3a4b5c6d to 8f9e0d1c:

+    /home/user/Documents/new_report.pdf
-    /home/user/Downloads/temp_file.zip
M    /home/user/Documents/budget.xlsx

Files:       1 new,     1 removed,     1 changed
Dirs:        0 new,     0 removed
Others:      0 new,     0 removed
Data Blobs: 15 new,    20 removed
Tree Blobs:  2 new,     2 removed
  Added:   4.500 MiB
  Removed: 12.000 MiB
```
*(Legend: `+` means a file was added, `-` means it was removed, and `M` means it was modified).*

**[⇦ Commands](../commands-and-options)**
