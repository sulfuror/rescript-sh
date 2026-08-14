The `all` command is a powerful orchestrator that executes a given rescript command sequentially or in parallel across *all* your configured repositories. It automatically handles global pre/post hooks.

### Usage
```bash
rescript all [command] [flags] ...
```

### Flags
- `-P, --parallel`: (v6.0+) launch all configured repositories simultaneously in the background (enforces quiet mode `-Q`).
- `-X, --ignore-repo`: skips a specific repository during the run.

### Limitations
- **Global Commands:** Global-scoped commands (such as `status`, `config`, `editor`, `update`, `install`, `uninstall`) cannot be used with the `all` orchestrator.
- **Interactive Prompts (Parallel Mode):** When running in parallel (`-P`), all interactive prompts (like SSH/SFTP password requests) are explicitly denied to prevent silent terminal freezes. Any repository that attempts to prompt for a password will immediately fail. Therefore, you **must** configure SSH keys (passwordless auth) or native Restic password configurations before using parallel mode.
- **Error Logging:** To ensure transparency when running jobs in the background without cluttering your system, parallel mode will automatically preserve and save an error log (`repo-error-date.log`) exclusively for jobs that fail.

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
Running [backup] in parallel for all repositories...
All parallel jobs finished successfully!
Running Global POST_CMD... Done!
```
*Note: This will execute backups concurrently. A loading spinner will show while the global PRE/POST hooks run, and output is saved directly to logs.*

**Run a cleanup on all repositories except one (e.g., `remote_server`):**
```bash
rescript all cleanup -X remote_server
```

**[⇦ Commands & Options](Commands-and-Options)**
