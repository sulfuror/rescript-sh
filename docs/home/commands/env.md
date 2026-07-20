---
title: rescript env
---

The `env` command displays the exact variable values currently loaded from your repository's configuration file. It is incredibly useful for debugging your configuration.

### Usage
```bash
rescript [repo_name] env [flags] [VARNAME]
```

### Examples

**Display all configured variables for a repository:**
```bash
rescript my_repo env
```
*Output:*
```text
======================
     Environment      
======================
BACKUP_DIR:     /home/user/Documents/
RESTIC_OPTS:    --exclude-caches
KEEP_LAST:      14
CLEAN:          7
======================
```

**Display a specific variable's value:**
```bash
rescript my_repo env KEEP_LAST
```
*Output:*
```text
14
```

**[⇦ Commands](../commands-and-options)**
