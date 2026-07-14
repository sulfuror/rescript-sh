---
title: rescript all
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

**Run backups on all repositories simultaneously (Parallel Mode):**
```bash
rescript all backup -P
```
*Note: This will execute backups concurrently. A loading spinner will show while the global PRE/POST hooks run, and output is saved directly to logs.*

**Run a cleanup on all repositories except one (e.g., `remote_server`):**
```bash
rescript all cleanup -X remote_server
```

**[⇦ Commands](../commands-and-options)**
