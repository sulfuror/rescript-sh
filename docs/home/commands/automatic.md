---
title: Automatic
---
The `automatic` command is implicitly executed by default when you run `rescript [repo]` without specifying any explicit command. 

It triggers a full backup routine, running your `PRE_CMD` hooks, taking a snapshot using your configured variables, running `cleanup` to enforce retention policies, and finally executing your `POST_CMD` hooks and sending webhook/email notifications. 

Usage:
```bash
rescript [repo_name] automatic
```

*(Note: Just running `rescript [repo_name]` is functionally identical to specifying `automatic`).*

### Example Output

```text
======================
  Repository Status   
======================
   ✓ my_repo
======================

Files:           15 new,    23 changed,  4560 unmodified
Dirs:            0 new,     5 changed,   120 unmodified
Added to the repo: 12.5 MiB

processed 4598 files, 2.3 GiB in 0:04
snapshot b394ae18 saved

Keeping 14 snapshots...
removing 1 old snapshots
[0:00] 100.00%  1 / 1 files deleted
```

**[⇦ Commands](home/commands-and-options)**
