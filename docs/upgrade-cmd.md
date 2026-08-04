The `upgrade` command easily upgrades your restic repository to the newer v2 repository format (which supports better deduplication and compression).

### Usage
```bash
rescript [repo_name] upgrade
```

### Examples

**Upgrade repository format:**
```bash
rescript my_repo upgrade
```
*Note: This process cannot be undone. Ensure you are using a compatible Restic version.*

**[⇦ Commands & Options](Commands-and-Options)**
