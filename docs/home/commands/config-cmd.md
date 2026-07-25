---
title: config
---

The `config` command helps you configure repository profiles, global settings, and exclusions without manually finding the configuration files.

### Usage
```bash
rescript config [flags]
```
*(When used without flags, it will prompt you for a text editor and display an interactive menu to edit a repository).*

### Flags
- `-g, --global`: (v6.0+) edit the global configuration hierarchy (`global.conf`).
- `-w, --wizard`: (v6.0+) launch the interactive wizard to bootstrap a new repository profile.

### Examples

**Use the interactive wizard to setup a new repository:**
```bash
rescript config --wizard
```
*This is the fastest way to start. It will prompt you for a repository name, path, password, and target backup directory.*

**Edit the Global Configuration (Defaults for all repos):**
```bash
rescript config --global
```

**Edit a specific repository's configuration interactively:**
```bash
rescript config
```
*It will ask which editor to use (nano, vim, etc.) and let you choose between editing the `conf` file or the `exclusions` file.*

**[⇦ Commands & Options](../commands-and-options)**
