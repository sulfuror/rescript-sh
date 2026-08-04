The `restorer` command easily restores a snapshot. It will automatically create a new folder in your home directory (e.g., `restore-snapshotID-randomnumber`) and restore the contents there, ensuring no existing files are overwritten.

### Usage
```bash
rescript [repo_name] restorer [flags] [snapshot ID]
```

### Command flags
- `-i, --interactive`: (v6.0+) opens a numbered, navigable menu allowing you to restore any snapshot with a single keystroke.
- `-H, --host hostname`: Only consider snapshots for this host when snapshot-ID is `latest`.
- `-P, --path path`: Only consider snapshots which include this absolute path for snapshot-ID `latest`.
- `-Z, --snapshot ID`: Indicate snapshot-ID to restore.
- `--tag tagname`: Only consider snapshots which include this taglist for snapshot-ID `latest`.

### Examples

**Interactive Restore (Recommended):**
```bash
rescript my_repo restorer -i
```
*Output:*
```text
======================================================
  Select Snapshot to Restore  
======================================================
 [1] 3a4b5c6d (2026-07-10 10:00:00) server-01
 [2] 8f9e0d1c (2026-07-11 10:00:00) server-01
 [3] 1a2b3c4d (2026-07-12 10:00:00) server-01
 [4] Exit
======================================================
Select the snapshot you want to restore [ 1 - 4 ]: 
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

**[⇦ Commands & Options](Commands-and-Options)**
