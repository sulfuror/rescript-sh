---
title: next
---
Displays the calculated time remaining until the next automatic cleanup (prune and forget) and integrity check will be executed for your repository.

Rescript optimizes operations by not running `cleanup` on every single backup. Instead, it spaces them out based on your `CLEAN` policy defined in the repository configuration (e.g., every 7 days).

Usage:
```bash
rescript [repo_name] next
```

### Example Output

```text
Next cleanup and check in 4 days...
```
*(Or if the time has already passed):*
```text
Repo will be cleaned and checked in the next run...
```

**[⇦ Commands & Options](../commands-and-options)**
