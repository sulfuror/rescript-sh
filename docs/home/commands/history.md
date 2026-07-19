---
title: rescript history
---

The `history` command displays a detailed timeline of a specific file or folder across all snapshots. It allows you to see exactly when a file was modified or deleted in your backup history.

### How it works
Under the hood, `history` runs a `restic find` search for the specified file across all snapshots. However, raw restic output lists the file in *every single snapshot*, which can be overwhelmingly redundant. 
Rescript parses this output and generates a **deduplicated timeline**. It only prints a new row if the file's **Size** or **Modification Date** actually changed between snapshots, allowing you to instantly identify true revisions.

### Usage
```bash
rescript [repo_name] history [path]
```

### Output Example

**View the backup history of a specific file:**
```bash
rescript my_repo history /home/user/Documents/report.pdf
```
*Output:*
```text
=============================================================================
No   | Snapshot   | Date                  | Size         | Path
=============================================================================
1    | 3a4b5c6d   | 2026-07-01 10:00:00   | 1.2M         | /home/user/Documents/report.pdf
2    | 8f9e0d1c   | 2026-07-05 15:30:00   | 1.5M         | /home/user/Documents/report.pdf
3    | 1a2b3c4d   | 2026-07-10 09:15:00   | 2.1M         | /home/user/Documents/report.pdf
```
*(Notice how the output skips days where the file didn't change, only showing the distinct versions. You can now use the Snapshot ID to extract the exact version you need!)*

**[⇦ Commands](../commands-and-options)**
