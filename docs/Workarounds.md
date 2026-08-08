### Backing up more than one directory

You can backup more than one location at the same time
using the same configuration file. Just open your configuration file and edit
the following line:
```bash
BACKUP_DIR=("/path/to/dir/1" "/path/to/dir/2")
```
This uses standard Bash array syntax, allowing you to back up multiple directories safely even if their paths contain spaces.

**[⇦ Home](Home)**