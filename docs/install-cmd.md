Install rescript to your system so it can be executed from any terminal. The install command will ask if you want a system-wide installation or a local installation just for your user. Note that system-wide installations will dynamically prompt for your sudo password to place files in protected directories.

Additionally, this command will automatically configure Programmable Bash Autocompletion so you can press `TAB` to quickly auto-complete your configured repository names, rescript commands, and global flags.

Usage:
```bash
rescript install [flags]
rescript install --autocomplete-only [system|user]
```

### Command flags
* `--autocomplete-only`: Install ONLY the bash autocompletion feature without reinstalling the rescript binary. It can optionally receive `system` or `user` to skip the interactive prompt.

### Example Output

```text
======================
     Installation     
======================
 [1] System-wide      
 [2] For this user    
 [3] Exit             
======================
Select an option and press Enter [ 1 - 3 ]: 1

The system-wide installation copies files to protected system
directories (like /usr/bin and /etc/bash_completion.d).
Administrative privileges are required to complete these actions.

Please enter your sudo password to proceed.

[sudo] password for user:
 * Bash autocompletion installed at: /etc/bash_completion.d/rescript

Installation successful!
Run [rescript config] to configure your repository.
```

**[⇦ Commands & Options](Commands-and-Options)**
