The `snaps` command lists all available snapshots in your repository in a clean, compact view.

### How it works
This command is a convenient wrapper around `restic snapshots --compact`. Standard restic output can be very bulky because it lists every single directory path included in the backup. The `--compact` flag hides these paths, presenting a much cleaner and easily readable list of IDs, dates, hostnames, and tags.

### Usage
```bash
rescript [repo_name] snaps [restic_flags]
```

### Output Example

**List all snapshots:**
```bash
rescript my_repo snaps
```
*Output:*
```text
ID        Time                 Host        Tags
------------------------------------------------------
3a4b5c6d  2026-07-10 10:00:00  server-01   
8f9e0d1c  2026-07-11 10:00:00  server-01   
1a2b3c4d  2026-07-12 10:00:00  server-01   keep-forever
------------------------------------------------------
3 snapshots
```

**[⇦ Commands & Options](Commands-and-Options)**
