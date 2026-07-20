---
title: all
---

The `all` command is a powerful orchestrator that executes a given rescript command sequentially or in parallel across *all* your configured repositories. It automatically handles global pre/post hooks.

### Usage
```bash
rescript all [command] [flags] ...
```

### Flags
- `-P, --parallel`: (v6.0+) launch all configured repositories simultaneously in the background (enforces quiet mode `-Q`).
- `-X, --ignore-repo`: skips a specific repository during the run.

### Examples

**Run a sequential backup on all repositories:**
```bash
rescript all backup
```
*Output:*
```text
Running Global PRE_CMD... Done!
================================================================================
Running on repository: my_repo_1
================================================================================
open repository
load index files
start scan on [/home/user/Documents]
start backup on [/home/user/Documents]

Files:           0 new,     0 changed,     3 unmodified
Dirs:            0 new,     0 changed,     4 unmodified
Added to the repository: 0 B   (0 B   stored)
snapshot 06e9b83e saved

================================================================================
Running on repository: my_repo_2
================================================================================
...

Running Global POST_CMD... Done!
```

**Run backups on all repositories simultaneously (Parallel Mode):**
```bash
rescript all backup -P
```
*Output:*
```text
Running on repositories: my_repo_1, my_repo_2 (in parallel, enforcing quiet mode)
Running Global PRE_CMD... Done!
All parallel jobs finished!
Running Global POST_CMD... Done!
```
*Note: This will execute backups concurrently. A loading spinner will show while the global PRE/POST hooks run, and output is saved directly to logs.*

**Run a cleanup on all repositories except one (e.g., `remote_server`):**
```bash
rescript all cleanup -X remote_server
```

**[⇦ Commands](../commands-and-options)**
