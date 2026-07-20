---
title: unlocker
---

The `unlocker` command deletes the temporary `.lock` file created by the Rescript wrapper.

> [!WARNING]
> This command **WILL NOT** unlock a frozen restic repository lock (you need to use `restic unlock` for that).

It is strictly used to release the local execution lock if the `rescript` process got stuck or was forcefully killed, preventing it from starting again.

### Usage
```bash
rescript [repo_name] unlocker
```

### Examples

**Release a stale execution lock:**
```bash
rescript my_repo unlocker
```

**[⇦ Commands](../commands-and-options)**
