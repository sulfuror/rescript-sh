The `uninstall` command provides a straightforward way to remove Rescript from your system. It cleanly deletes the executable binary and the Bash autocompletion scripts installed previously.

### How it works

Running the command will present an interactive menu allowing you to choose between a system-wide or user-level uninstallation. It will first check if Rescript is actually installed in the selected location; if not, it will alert you and prevent the action. For system-wide uninstallation, it will prompt you dynamically for your `sudo` password to proceed.

After uninstalling the program files, you will also be prompted on whether you want to delete your configuration directory (`~/.rescript`), which contains all your repository configuration files, datefiles, and logs.

### Usage

```bash
rescript uninstall
```

### Output Example

```bash
rescript uninstall
```

*Output:*

```text
==============================
     Uninstallation   
==============================
 [1] System-wide      
 [2] For this user    
 [3] Exit             
==============================
Select an option and press Enter [ 1 - 3 ]: 2
User uninstallation successful!

Do you also wish to delete your configurations and logs in [/home/user/.rescript]? (y/N): n
Configurations kept.
```

**[⇦ Commands & Options](Commands-and-Options)**
