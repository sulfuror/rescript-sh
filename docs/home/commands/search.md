---
title: rescript search
---

The `search` command allows you to quickly search for a specific file or directory across all your snapshots. 

### Usage
```bash
rescript [repo_name] search [query]
```

### Examples

**Search for a specific document by name:**
```bash
rescript my_repo search "report.pdf"
```

**Search for a file extension:**
```bash
rescript my_repo search "*.xlsx"
```
*This will search through all snapshots and print exactly which snapshots contain matching files.*

**[⇦ Commands](../commands-and-options)**
