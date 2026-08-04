The `umounter` command elegantly kills any background `mounter` processes and safely unmounts the repository from your local file system.

### Usage
```bash
rescript [repo_name] umounter
```

### Examples

**Unmount a previously mounted repository:**
```bash
rescript my_repo umounter
```
*If you mounted the repository with the `--background` flag, this command will safely terminate the process using the stored PID file and unmount the virtual filesystem.*

**[⇦ Commands & Options](Commands-and-Options)**
