The `extract` command restores a single file or directory from a specific snapshot to your local machine. It features a custom progress bar to monitor extraction speed.

### Usage
```bash
rescript [repo_name] extract [snapshot-ID] [path/in/snapshot]
```

> **Note:** You must provide the exact full absolute path of the file as it was backed up, not just the filename.

### Examples

**Extract a single document from a specific snapshot ID to your current directory:**
```bash
rescript my_repo extract 3a4b5c6d /home/user/Documents/report.pdf
```
*Output:*
```text
Using provided snapshot ID [3a4b5c6d]...
Extracting [/home/user/Documents/report.pdf] to [./report.pdf]...
[0:02] 100.00%  1 / 1 files extracted
```

> **Safety Feature:** If `./report.pdf` already exists in your current directory, Rescript will automatically extract it as `report_snap_3a4b5c6d.pdf` to prevent overwriting your local file. If you extract it multiple times, it will safely append `(1)`, `(2)`, etc.

**Auto-detect the latest snapshot and extract a folder as a zip archive:**
> **Note:** Because Rescript uses `restic dump` under the hood, directories are automatically streamed and packaged into a `.zip` archive to preserve their internal structure without cluttering your system with absolute paths. You can easily unpack it using standard zip tools.
```bash
rescript my_repo extract /home/user/Photos
```
*Output:*
```text
Auto-detecting latest snapshot for this file...
Extracting [/home/user/Photos] to [./Photos]...
[0:02] 100.00%  1 / 1 files extracted
Directory successfully extracted as a zip archive.
Saved to: ./Photos.zip
```

**[⇦ Commands & Options](Commands-and-Options)**
