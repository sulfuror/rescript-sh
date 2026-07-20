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
*Output:*
```text
Found 2 matching files in snapshot 3a4b5c6d:
/home/user/Documents/budget.xlsx
/home/user/Documents/report.xlsx
```

**[⇦ Commands](../commands-and-options)**
