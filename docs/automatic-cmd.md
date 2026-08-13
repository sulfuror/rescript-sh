The `automatic` command is implicitly executed by default when you run `rescript [repo]` without specifying any explicit command.

It triggers a full backup routine, running your `PRE_CMD` hooks, taking a snapshot using your configured variables, running `cleanup` to enforce retention policies, and finally executing your `POST_CMD` hooks and sending webhook/email notifications.

Usage:

```bash
rescript [repo_name] automatic
```

*(Note: Just running `rescript [repo_name]` is functionally identical to specifying `automatic`).*

> **Note on Notifications:** If the backup encounters any warnings (e.g. locked files), Rescript will gracefully handle them, execute your `POST_CMD` hooks, and send a specific Warning notification at the end of the run. To prevent notification fatigue, the standard "Success" notification is automatically suppressed in this scenario.

### Example Output

```text
================================================================================
                        Rescript Execution Context
================================================================================
  Date/Time      : 2026-07-20 10:00:00
  System         : Linux
  Hostname       : server-01
  Profile        : my_repo
  Command        : automatic
  Mode           : Live
  Backend        : Local
  Restic Version : 0.19.0
  Destination    : /backup/destination/my_repo
  Backup Source  : /home/user/Documents
  Exclusions     : 6 rules applied
  Auto-Clean     : Every 7days
================================================================================

Taking a Snapshot...
open repository
using parent snapshot b42180e0
load index files
start scan on [/home/user/Documents]
start backup on [/home/user/Documents]
scan finished in 0.101s: 3 files, 315.131 MiB

Files:           0 new,     0 changed,     3 unmodified
Dirs:            0 new,     2 changed,     2 unmodified
Data Blobs:      0 new
Tree Blobs:      2 new
Added to the repository: 756 B (589 B stored)

processed 3 files, 315.131 MiB in 0:00
snapshot 013464ea saved
There are 6 exclusion rules...
--------------------------------------------------------------------------------
Snapshots List...
================================================================================
ID        Time                 Host          Tags    Size
================================================================================
b42180e0  2026-07-18 21:40:28  server-01             315.131 MiB
013464ea  2026-07-20 10:00:00  server-01             315.131 MiB
--------------------------------------------------------------------------------
Timestamps shown in local timezone
2 snapshots
--------------------------------------------------------------------------------
Next cleanup and check in 5 days...
--------------------------------------------------------------------------------
Calculating repo stats        : [####################](100%)

================================================================================
Summarized Info      | Restore Size       | Deduplicated Size   
================================================================================
Latest Snapshot      |  315.131 MiB       |  314.307 MiB        
All Snapshots        |  5.539 GiB         |  314.329 MiB        
--------------------------------------------------------------------------------
Duration: 7 seconds
```

**[⇦ Commands & Options](Commands-and-Options)**
