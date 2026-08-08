The `status` command (introduced in v6.0) provides a rapid dashboard overview of all your repositories. 

### How it works
Under the hood, `status` reads all your repository profiles (`.conf` files) in `~/.rescript/config/` and quickly pings each repository to retrieve its snapshot count and the date of the most recent snapshot. By default, it skips heavy operations (like checking consistency or calculating total size), making it incredibly fast even if you have dozens of repositories configured.

### Usage
```bash
rescript [repo_name] status [flags]
rescript status [flags]
```

### Flags
- `-F, --full`: Fetch advanced stats like exact size and perform a health check (`restic check`) on the repository. *(Note: This can take a long time on very large repositories).*
- `-X, --ignore-repo`: Exclude specific repos when running a global status check.

### Output Examples

**Standard Dashboard (Fast):**
```bash
rescript status
```
*Output:*
```text
======================================================
Repository      | Snapshots  | Latest Date
======================================================
home_backup     | 12         | 2026-07-14 10:00:00
work_files      | 5          | 2026-07-13 18:30:00
system_etc      | 1          | 2026-07-10 09:15:00
```

**Full Dashboard with Advanced Stats:**
```bash
rescript status --full
```
*In full mode, Rescript calculates total repository sizes and runs a health check across all your repositories **in parallel**. This concurrent execution dramatically reduces total wait time. While this happens, you will see a unified loading spinner (`Calculating status for X repositories... \`) instead of raw Restic output. Once all background tasks finish, the full table is printed at once:*

```text
========================================================================================
Repository      | Snapshots  | Latest Date           | Size         | Health
========================================================================================
home_backup     | 12         | 2026-07-14 10:00:00   | 150.45 GiB   | OK
work_files      | 5          | 2026-07-13 18:30:00   | 12.30 GiB    | OK
system_etc      | 1          | 2026-07-10 09:15:00   | 450.00 MiB   | OK
```

**[⇦ Commands & Options](Commands-and-Options)**
