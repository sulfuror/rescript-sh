The `info` command calculates and displays detailed repository statistics in a highly readable, custom-formatted table.

### How it works
Under the hood, `info` runs multiple passes of `restic stats` to fetch different metrics. It calculates the sizes for both the latest snapshot individually, and all snapshots combined.

It's important to understand the two metrics it provides:
- **Restore Size**: This is the uncompressed, actual size of your data. If you were to extract the snapshot to your hard drive, this is exactly how much space it would consume.
- **Deduplicated Size**: This is the actual footprint the snapshot takes up inside the Restic repository. Because Restic natively deduplicates chunks of data, this number is almost always significantly smaller than the Restore Size.

### Usage
```bash
rescript [repo_name] info
```

### Output Example

```bash
rescript my_repo info
```
*Output:*
```text
================================================================
Summarized Info      | Restore Size       | Deduplicated Size
================================================================
Latest Snapshot      | 150.45 GiB         | 120.10 GiB
All Snapshots        | 1.20 TiB           | 180.50 GiB
================================================================
```
*(Notice how the "Restore Size" for all snapshots combined is massive (1.20 TiB), but thanks to deduplication, it only occupies 180.50 GiB of actual disk space in the repository!)*

**[⇦ Commands & Options](Commands-and-Options)**
