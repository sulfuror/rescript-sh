---
title: rescript cleanup
---

The `cleanup` command performs a `forget` operation according to the retention policies defined in your configuration file, followed by a `prune` operation to free up disk space.

### Usage
```bash
rescript [repo_name] cleanup [flags] [options]
```

### Flags
- `-C, --check`: check for errors in the repository after cleaning.
- `-i, --info`: display stats for snapshots after cleanup.
- `-n, --next`: display the next scheduled `cleanup` based on the `datefile`.
- `--reset`: remove "datefile"; resets the timers for the `CLEAN` policy.

### Examples

**Standard cleanup (Forget & Prune):**
```bash
rescript my_repo cleanup
```

**Simulate a cleanup (Dry-Run):**
```bash
rescript my_repo cleanup --simulate
```
*Highly recommended before making permanent changes to ensure your policies are correct without actually deleting data.*

**Check when the next automatic cleanup is scheduled:**
```bash
rescript my_repo cleanup --next
```

**[⇦ Commands](../commands-and-options)**
