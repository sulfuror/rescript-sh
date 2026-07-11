# Rescript Changelog

## v6.0

---

### July 11, 2026

#### 🚀 Major Features

* **Parallel Orchestration (`all --parallel`):** The orchestrator now natively supports parallel execution using the `-P` or `--parallel` flag. When using this flag, Rescript will launch all configured repositories simultaneously in the background (enforcing quiet mode `-Q` to keep the terminal clean) and wait for all jobs to complete. This drastically reduces total backup duration for users with multiple repositories.
* **Push Notifications (Webhooks):** Added support for instant Push Notifications via Webhooks. You can now define a `WEBHOOK_URL` (Discord, Slack, etc.) in your repository configuration. Rescript will automatically POST JSON payloads upon successful completion or fatal failure of jobs, complimenting or replacing traditional SMTP email notifications.
* **Auto-Heal (Network Retries):** Added robust network resilience by wrapping destructive restic commands (`backup`, `check`, `forget`, `prune`, `restore`) with a self-healing retry loop. If `restic` fails with a fatal error (like a network timeout, code 1) or a temporary lock (code 11), Rescript will intelligently pause for 30 seconds and retry the command up to 3 times before definitively failing.

#### 🛠️ Internal Refactoring & UI

* **Command Extraction (`install` / `update`):** Completed the strict modular architecture by extracting `install` and `update` commands from the monolithic `04_install.sh` script into `src/commands/install.sh` and `src/commands/update.sh` respectively.
* **Template Separation:** Extracted heavy heredoc template strings (`config_file`, `sys_exclusions`, etc.) from the core `03_config.sh` script into a dedicated `src/templates/` directory, drastically reducing cognitive load and adhering strictly to the "Separation of Concerns" architectural pattern.
* **Core File Renumbering:** Renumbered remaining files in `src/` (01 to 06) sequentially to patch the numbering gap left by the refactorings. Updated the `build.sh` compiler to seamlessly inject the newly separated templates and sequentially concatenate the core files.

---

*End of changelog for version 6.0*

## v5.2

---

### July 10, 2026

#### 🛠️ Internal Refactoring & UI

* **DRY UI Elements:** Refactored all hardcoded menu borders (`======================` and `----------------------`) across `utils`, `config`, and `install` modules into centralized global variables (`$ui_line_eq`, `$ui_line_dash`) defined in `01_globals.sh`. This ensures visual consistency and allows for instant global customization of the UI.
* **Orchestrator Architecture Fix:** Moved the `all` command orchestrator block from `01_globals.sh` to the top of `06_core.sh`. This resolves a dependency order issue, allowing the orchestrator to natively use the `print_line "="` utility function (which calculates dynamic terminal width) instead of relying on manual hardcoded loops, while still catching the command before the strict repository validation router.
* **Command Micro-Modularization:** Split the monolithic `07_commands.sh` script into a new `src/commands/` directory containing individual files for each operational command. Moved remaining core utility functions to `02_utils.sh`. Updated the `build.sh` compiler to dynamically concatenate all command modules, vastly improving codebase maintainability.
* **Bash Strict Mode (Stability):** Implemented strict execution rules (`set -euo pipefail`) at the core level (`01_globals.sh`), ensuring the script fails safely upon encountering uninitialized variables or command errors.
* **Variable Defensiveness:** Added robust variable initializations (`${VAR:-}`) for all external user configurations and internal state flags to ensure full compliance with Strict Mode and prevent silent failures.
* **Module Reordering:** Renamed `08_main.sh` to `07_main.sh` to maintain logical sequential ordering following the modularization process.
* **Host Targeting Fix:** Fixed a bug in the `info` command where it ignored the custom `--host` flag and always queried the system's hostname.
* **Timer Fix:** Resolved an unbound array variable error (`dur`) in the `duration` function when the elapsed time was exactly zero seconds.
* **Array Initializations:** Fixed missing empty array initializations (`=()`) for `policies` and `bu_opts` to prevent unbound variable crashes in strict mode.
* **Flag Argument Protection:** Protected dynamically captured flags (like `$2` in `--host`) with fallbacks (`${2:-}`) to prevent fatal crashes if the flag is provided without a subsequent argument.
* **Raw Restic Command Flags:** Wrapped the default command fallback router (`restic_alone`) with `execute_with_metrics`, enabling all rescript global flags (like `-T` for timer, `-L` for logs) to work seamlessly with any raw restic command.
* **Test Suite Coverage Expansion:** Expanded `tests/run_all.sh` framework to cover strict mode edge cases, including gracefully handling missing flag arguments and extreme duration metrics (`0 seconds`), and verifying raw restic command integration with orchestrator loops.
* **Build Script Polish:** Updated `build.sh` to output directly to the final `rescript` executable, removing the redundant `rescript.new` step for cleaner compilation in development environments.

---

*End of changelog for version 5.2*

## v5.1

---

### July 9, 2026

#### 🚀 New Features & Enhancements

* **Targeted Snapshots (`size` and `extract`):** Both commands now natively support passing a specific `snapshot_id`. If omitted, they intelligently auto-detect the `latest` snapshot or the most recent snapshot containing the queried file.
* **Custom Progress Bars:** Added clean, animated ASCII progress bars to the `size` (parsing Restic's calculation progress) and `extract` (simulated progress during dump) commands to improve user feedback during long-running operations.
* **Intelligent History Tracking:** Redesigned the `history` command to track the *actual evolution* of a file across snapshots. It intelligently filters out repetitive snapshots and only lists versions where the file's size or modification date actually changed.
* **Robust Mounter:** Added a polished foreground mode to the `mounter` command with a clean UI, graceful shutdown via Ctrl-C, and safer FUSE unmounting.

#### 💅 Aesthetics and UI

* **Orchestration and Clean Output:** Refined the `all` command orchestrator to reduce visual noise by conditionally suppressing headers during metadata or automatic runs.
* **Simulation Visibility:** Enhanced `SIMULATE` dry-run warnings by applying standard semantic coloring across all hooks, ensuring safe-mode execution is highly visible.
* **Unified Tables (`search`, `history`, `snaps`, `logs`, `env`):**
  * Replaced default Restic ASCII borders with dynamic edge-to-edge `====` dividers.
  * Standardized the `env` command output to use left-aligned, tabular formatting.
  * Added standard grey borders to `snaps` for visual cohesion.
* **Enhanced List Readability:**
  * Added a progressive `No.` (numbering) column to the `history` and `search` tables.
  * Refactored `search` columns to present a much more compact, aligned, and professional layout, removing the redundant `Tag` column to maximize terminal space.
* **Semantic Colorization:** Implemented a standardized semantic color system (`c_white`, `c_cyan`, `c_green`, `c_red`), replacing scattered legacy colors for a unified, modern aesthetic.
* **Consistent Context Banners:** Standardized contextual banners (`logs`, `all`, `umounter`) across the application for identical formatting.
* **Time Formatting Integration:** Integrated a native `duration` utility to present clean, readable runtime strings (e.g., `Duration: 8 seconds`) instead of raw timing outputs.

#### 🐛 Bug Fixes and Documentation

* **Stability Enhancements:** Fixed asynchronous logging display issues to prevent terminal prompt clipping, and improved FUSE teardown stability in the `mounter` command.
* **Flag Collision and Help Parsing:** Resolved a flag collision with `--simulate` (changed `--skip-office` to `-O`). Ensured global help flags (`-h`/`--help`) are correctly handled by orchestrator commands without triggering unintended executions.
* **MTA Failures:** Improved `_send_email` to gracefully catch and suppress `stderr` when a Mail Transfer Agent is not configured, printing a clean warning instead of crashing verbosely.
* **Documentation Cleansing:** Rewrote command descriptions in `README.md` to accurately reflect v5.1 functionalities (e.g., wildcard tips for `history`). Removed deprecated flags (`-a`, `-d`), the obsolete `--next` flag, and the `rsync` dependency.
* **Help Texts Update:** Fixed internal help texts to print the new uppercase namespaces (e.g., `-T, --timer`) and corrected grammar and spelling throughout the documentation.

#### 🛠️ Internal Refactoring

* **Decoupling `next` Logic:** Extracted the auto-cleanup calculation logic. The `Next cleanup and check...` string is no longer redundantly printed at the end of manual operations. It is properly scoped to execute during the `automatic` orchestrator run or via the standalone `next` command.
* **Orchestration Decoupling:** Migrated execution timing, lock management, and logging wrappers from individual commands in `src/07_commands.sh` into a centralized `execute_with_metrics` dispatcher in `src/08_main.sh`, drastically reducing code duplication.
* **Smart Lock Management:** Refactored `rescript_lock` into a state-aware singleton (`rescript_lock_created`), successfully removing all scattered `rm -rf "$lock"` teardown hacks and preventing lock-stealing race conditions during chained command pipelines.
* **Pipeline Consolidation:** Moved chained command sequences (like triggering `cleanup`, `check`, and `statinfo` after a `backup`) strictly into the main engine router, ensuring modular command purity.
* **Centralized Error Handling:** Centralized the `restic` error checking routine in `src/02_utils.sh` to standardize exit code validation and reduce repetition.
* **Helper Functions:** Abstracted the highly duplicated cleanup policy evaluation block in the `automatic` command into a clean internal `_run_auto_cleanup` helper. Extracted repetitive simulation (`dry-run`) validation into a cleaner helper function, and consolidated directory creation logic for POSIX compliance.

#### 🛡️ Security & QA

* **Universal Test Framework:** Built a bulletproof, automated testing framework (`tests/run_all.sh`) that evaluates ~95% of core mechanics, orchestrator behaviors, and edge cases. It executes in a 100% sandboxed environment (`/tmp`), automatically overriding `$HOME` to guarantee zero risk to local user configurations.
* **Continuous POSIX Compliance:** Integrated `shellcheck` into the test suite to automatically validate syntax standards and prevent structural regressions.
* **Configuration File Permissions:** Changed the creation of new repository configuration files (`.conf`) to use `chmod 600` instead of `700`. This hardening measure prevents potential privilege escalation by ensuring config files are strictly non-world-writable, protecting `PRE_CMD` and `POST_CMD` execution.
* **Security Documentation:** Added an explicit warning in the `README.md` regarding the security implications of world-writable configuration files.

---

*End of changelog for version 5.1*

## v.5.0

---

### June 26, 2026

This is a major release marking the evolution of Rescript from a monolithic script to a modular, robust, and fully POSIX (Bash) compliant architecture. The core was redesigned to enable multi-repository orchestration and shield the tool against flag collisions with the restic binary.

### 🏗️ Architecture and Core Refactoring

* **Modular Architecture Migration:** The old monolithic script (`rescript_v4.7`, +86KB) has been split into 8 independent logical modules inside the `src/` directory (e.g., `01_globals.sh`, `02_utils.sh`, `06_core.sh`), greatly improving maintainability. A `build.sh` script was introduced to compile everything into a single final binary.
* **POSIX Compliance (Zsh to Bash):** Full transition from Zsh to pure Bash. Array handling and variable expansions were rewritten to guarantee universal compatibility across modern Linux servers.

### 🔥 New Features

* **Multi-Repository Orchestrator (`all`):**
  * New execution engine that allows running commands sequentially across all configured repositories (e.g., `rescript all backup`).
  * Added the `--ignore-repo` / `-X` flag exclusively for the `all` command, allowing dynamic omission of environments (e.g., `rescript all backup -X omv`).
* **Simulation Mode (`--simulate` / `-S`):**
  * New global flag that enables dry-run simulations of destructive or heavy operations (`backup` and `cleanup`), showing the exact underlying command without affecting the repository.
* **Background Mounting:**
  * The `mounter` macro now supports the `--background` flag, generating PID files in `/tmp` to mount repos without blocking the terminal.
  * The `umounter` macro was refactored to read, gracefully kill background processes, and unmount cleanly.

### 🛡️ Safety and Execution

* **Flag Shielding (Uppercase Namespace):**
  * The strict `getopt` parser was removed.
  * **CRITICAL:** To prevent stealing native Restic flags (like `-e`, `-l`, `-q`), all Rescript global flags were migrated to an uppercase namespace: `-D` (Debug), `-E` (Email), `-L` (Log), `-Q` (Quiet), `-S` (Simulate), `-T` (Timer).
  * Rescript's old `--time` flag (which just displays execution time and takes no arguments) was renamed to `--timer`. This frees up the `--time` flag so that *Restic's native* `--time` flag (which *does* take timestamp arguments like `--time "2020-01-01"`) can now pass through perfectly without interference.
* **Array Space Protection:** Fixed multiple calls in `07_commands.sh` to expand arrays using `"${rest[@]}"` (quoted), preventing Bash from splitting composed arguments (like paths or timestamps with spaces).
* **Atomic Lock Management:** Strict integration of `rescript_lock` at the start of each macro, combined with a native OS `trap` to invoke `unlocker` if the user abruptly cancels with `Ctrl+C`.

### 🛠️ New Commands and Macro Improvements (UX)

* **Completely New Commands:**
  * **`search`:** Finds a specific file or directory across all snapshots.
  * **`history`:** Shows the version history of a given file over time. Paths are displayed in their entirety, without the 80-character limit.
  * **`extract`:** Extracts a specific file or directory from a snapshot.
  * **`size`:** Calculates the true recursive size of a given path using `restic ls --recursive`.
  * **`upgrade`:** Upgrades the restic repository format to version 2.
  * **`umounter`:** Unmounts a repository that was mounted in the background.
* **Background Mounting:** The `mounter` command now supports a `--background` flag, allowing users to mount a repository without locking the terminal session. PID tracking is natively managed and stored in `/tmp`.
* **Renamed Commands:** The old `changes` command was renamed to **`diff`** to align perfectly with Restic's native nomenclature. When executed without arguments, it automatically finds and compares the two most recent snapshots. When executed with arguments (e.g., specific IDs or flags like `--metadata`), it transparently passes them to the native `restic diff` without any interference.
* **Enhanced AWK Tables (`info`, `search`, `history`):** Visual redesign using ANSI sequences (`\e[1m`) to highlight table headers in **bold** format.
* **Custom Progress Bars:** Introduced a new native Bash progress bar (`print_progress`) with in-place terminal updating (`\r`) to provide visual feedback during long-running operations like repository stat calculation and file extraction.
* **`--debug` (`-D`):** Integration of `debug_start` and `debug_stop` (via `set -xv`) wrapping internally around each macro for deep traceability.

### 🗑️ Deprecations and Removals

* The **`archive`** and **`checkout`** commands have been completely removed.
* It is no longer necessary to use the old `-delqt -- [command]` format. Rescript and Restic global flags can now be mixed naturally.

### 🐛 Community Bug Fixes & Patches

* **Cron Job Silent Execution (`-q`):** Fixed a bug where running `rescript [repo] -q` from a cron job (without explicitly passing a command) caused the script to fail. It now correctly falls back to the `automatic` command in total silence.
* **`/dev/stdout` Permission Denied:** Fixed a critical issue where redirecting output to `/dev/stdout` caused permission errors when running as `su` or inside cron environments. Output is now safely routed without violating permissions.
* **unRAID / Blank OS Compatibility:** Fixed OS detection logic that relied solely on `/etc/issue.net` (which is blank in unRAID and some modern distros). The script now robustly falls back to `Unknown Linux OS` instead of crashing or returning empty values.
* **POSIX `command -v` Migration:** Completely eliminated the use of the deprecated `which` command across the codebase in favor of the POSIX-compliant `command -v` for finding system binaries.
* **Native Log Rotation:** Implemented `LOG_RETENTION` variable support. Rescript will now natively prune log files older than the specified days, preventing the `.rescript/logs` folder from growing indefinitely.
* **Pre/Post Execution Hooks:** Added support for `PRE_CMD` and `POST_CMD` variables, allowing users to run arbitrary system commands immediately before and after the `automatic` backup process.

---

*End of changelog for version 5.0*

## v.4.7

---

### May 23, 2023

**Additions**:

1. Change `which` command; now using `commnand -v` for compatibility.

## v.4.6

---

### July 2, 2019

**Additions**:

1. Added a new function to send email confirmation when job is done. This function will not always send you an email. There is a new option for the configuration file called `CONFIRMATION_EMAIL`. You can add it to your configuration file like this `CONFIRMATION_EMAIL="yes"` to receive an email every time a job is successfully done via cron. If you don't set this variable it will not send you an email. Also, you need to install `mailutils` and `ssmtp` (not working on Debian buster), [nullmailer](https://christopherbaek.wordpress.com/2016/05/22/nullmailer-send-mail/) or something that cand allow you to send emails outside your network via `mail` from `mailutils`. If you need a simple tool to send emails outside your network, I would go for `nullmailer`; really easy to configure.
2. Added a new global flag called `-e, --email`. This option will force the script to send the output via email (again, `mailutils` needs to be installed and configured to send emails).
3. Added a way to determine the size of the terminal in session. This way the `rescript` output will rezise itself. This is useful (at least for me) because somethimes, depending on the machine, the output lines and stuff looks kind of messed and now it will adjust to the terminal emulator size.
4. Added a new flag for `backup`: `-C, --check`. This flag will execute `check` after `backup`.
5. Added the abbility to check if target is present. This small part of the code works for `sftp`, `rclone` backends and if the repository is located locally (meaning `/path/to/my/repository`). If the repository you're using `sftp`, then `rescript` will ping your remote server to make sure is reachable and proceed; if the repository is not reachable it will display an error message and exit. If you're using `rclone` backend then it will first execute `rclone about remote:directory`; if that fails it will display an error message and exit. If the repository is stored locally, it will first check if the directory exists and if it doesn't it will display an error message and exit.
6. Added `--host` flag for `info` command. It works just for "Latest Snapshots" and this is not because of the script; `restic` only accept `--host` flag when the snapshot is latest.
7. Added credential variables in configuration file for Azure and Google Cloud Storage; B2 and AWS were already in older versions of this script. For Minio Server, AWS credentials can be used. If you need to setup other services, they can be exported in the configuration file, for example, OpenStack Swift has a lot of different variables that can be used; you can export those in the configuration file.
8. Added `EXCLUDE_FILE="yes"` in the configuration file. Just for compatibility with previous versions, if this variable doesn't exists in the configuration file it will still use the exclusion list created unless you add this variable to the configuration file and set it to "no".
9. Added `EXCLUDE_CACHE="yes"` in the configuration file, and also for compatibility with previous versions, by default is added unless you add this variable to the configuration file and set it to "no".
10. Added `ONE_FILE_SYSTEM=""` in configuration file; by default is blank and it is not used, as in previous versions. If set "yes" then it will add the `--one-file-system` flag for backups.
11. Added a flag for `cleanup` command called `--reset`. This will delete the `datefile` created. The point is to reset the `CLEAN` var and if the datefile gets deleted, then the script will have to create it again and it will "reset" the dates. If used, in the next run will do all cleanup and set the date as in the `CLEAN` var.
12. Added a function for the configuration file and exclusions to make it easier to read the script and also deleting all `echo` commands to send the template to a new configuration file (it was time).
13. There is a new variable called `RESCRIPT_PASS`; this was made with "security" in mind. If you have everything needed in your configuration file you don't have to worry about this. This is for people who does not want to save the  repository password inside the configuration file for security reasons. You can export this variable in your session and make use of `rescript` until the session is closed. i.e.: `export RESCRIPT_PASS="mytotallysecurepassword"`.
14. There is a new function to cleanup files for the archive function.

**Changes / Improvements**:

1. A couple of improvements were made for existing functions and features; this version have some new stuff but initially it was just improvements in the code.
2. Set `PATH` once for all instead of using `if` statements to check if `~/bin` or `~/.local/bin` exists.
3. Improved the function to send errors emails.
4. Updated the `update` command; now this command can be used in Mac OS to install it system-wide.
5. Fixed the function in charge to determine the operating system; didn't notice before but apparently not all GNU/Linux distributions comes with `lsb-release` package installed so now if it is not installed, it will use `cat /etc/issue.net` instead.
6. The option `--var` for `env` command now supports lowercase.
7. `logs` command alone now will display all logs related to the [repo_name]. Also, `--remove` option have a "special" option `all`; if you use `rescript [repo_name] logs --remove all` it will delete all logs related to the [repo_name]; you can still copy and paste just one log file instead.
8. Now `policies` are declared and added if present.
9. Finally, `archive` will not need to create a temp text file to read the files to restore when deleted from the latest snapshot; now it will store it in a variable and read it from there.
10. Headers for output are back and now for any command.
11. `CLEAN` variable can now be set to minutes, hours, days or any format accepted by `date`. If you're using it you need, then you are using it with "days" values; so if you do a cleanup every 7 days, change this variable in your configuration file to `CLEAN="7days"`. NO SPACES between the numbers and letters. If it is not configured correctly, it will be displayed a warning message.
12. Improvements in columns printing.
13. Improvements in `backup` function managing options.
14. Improvements in `env` command.
15. `rescript` will now save a log no matter if the `--log` option is used or not. The difference is that when the `--log` option is used, the log is saved to the logs directory (`~/.rescript/logs`). If the option is not used, `rescript` will create a temporary log file in `/tmp` using `mktmp`. Why? Because that's the only way I figure out to send the output via email if `--email` is used without the `--log` option. To send the output via email I needed to retrieve the output from somewhere and if a log was not present I could't send the output. This temporary log gets always deleted at the end.
16. The time functions were simplified a lot.
17. `getopt` is now called once instead of calling it for every command (except when calling `restic` commands instead of the script's commands).
18. Simplified the `duration` function; it will display the same but now it is shorter.
19. Minor changes in the lock function because if there was a lock created by `rescript` and you're not looking at the terminal, you were never gonna receive an message about that; now it can send an email or log the error with the output telling you that maybe there's another instance running.
20. When you run a `restic` command (no the commands from the script) like check and use something like this: `rescript reponame -t -- --repo /path/to/repo backup ...` and there was an error, the command displayed in the error message was `[--repo] failed...`; now it's fixeded so it display the correct command.

The new features to test/ping the remote server and to send emails when job is done are thanks to ***killmasta93*** (user from restic forum). I'm still looking new ways to improve the script and any suggestion is really welcome.

## v.4.5

---

### June 4, 2019

**Improvements, Changes, Additions and others**:

1. The entire script itself is less cluttered; 1,428 additions, 1,702 removed lines and a total of 274 lines less than version 4.4.
2. Now the script uses `getopt` to manage flags, options, etc. It helped a lot reducing a lot of cluttered lines and simplifying the whole script.
3. Help was modified. It is now shorter since every command have its own help explaining the command and flags.
4. Added the abbility to report errros. Since `restic` is a backup tool and backups are really important,
   the first error detected will trigger an exit and a message with the failed command and exit code.
   For this purpose there is also a new variable used named EMAIL. You can add this variable EMAIL="<user@example.com>"
   in your configuration file to use it. `rescript` will use `mail` (from `mailutils`) to send an email
   if an error ocurred. This is useful if you use `rescript` with `cron`. If you're using `rescript` from
   a terminal and an error ocurred it will not send an email but it will display the error message. If you don't want
   any email, don't add this variable or leave it blank. It will still send an error message but without attempting
   to send an email. For the emails to work you need to setup `mail` to send emails. I would
   reccomend to install `mailutils` and setup `ssmtp`. You can follow [this tutorial](https://www.howtogeek.com/51819/how-to-setup-email-alerts-on-linux-using-gmail/).
5. There is a new command named `info`. This command will display a small three column table with the latest
   snapshot size (restore-size and raw-data) and all snapshots size (restore-size and raw-data).
6. `-d, --debug` flag added. This will debug the script, not restic.
7. `-q, --quiet` flag added. This flag will silence the output.
8. `-c, --cleanup` flag added. Execute `cleanup` after your command. It is not available for every command.
9. `-i, --info` flag added. Execute `info` after your command. It is not available for every command.
10. `-v, --var` flag added for `env` command. Using the `grep` magic, this var can be used to retrieve just one variable from your configuration file.
   For example, you want to see all your "keep" policies without listing all other variables, you do this: `rescript [repo_name] env --var KEEP` and you'll
   see the following output (varname must be indicated UPPERCASE):

   ```
   KEEP_LAST=""
   KEEP_HOURLY="8"
   KEEP_DAILY="7"
   KEEP_WEEKLY="4"
   KEEP_MONTHLY="12"
   KEEP_YEARLY="10"
   KEEP_WITHIN=""
   KEEP_TAG=""
   KEEP_ARCHIVE="yes"
   ```

1. The usage of flags changed. Now all flags must be indicated after the command. You can use long options,
   short options or both. There are some commands that can be used adding restic flags/options. These commands
   are: `backup, cleanup, mounter, snaps`. To indicate restic flags/options you must use a double "minus" sign after
   rescript flags/options. For example: `rescript [repo_name] backup -tl -- --cleanup-cache`. You must also do this when
   if you want to use global flags with restic commands.

   Example:

   ```
   rescript [repo_name] -dlqt -- check --read-data
   ```

1. Now `rescript` output is optional for commands. If you want to display the output for any command just add the
   `-t, --time` flag. There were some inconsistencies in the output displayed, so I made just one output for everything
   except when running the "automatic" function (when indicating just the repository name).
1. ***About MacOS***: if you don't have `gnu-getopt` installed it will work but only with short options. Long options are not
   supported in the default MacOS `getopt`. If you want to use long options you can install `gnu-getopt` with the following command: `brew install gnu-getopt`.
   The script will automatically use the correct path for the new `gnu-getopt` installation, so you don't have to do anything else
   besides installing it.
1. `-d, --debug | -h, --help | -l, --log | -q,--quiet | -t, --time` flags are really now "glogal". They can be used with any command.
    Well... except for `config, editor, help, install, update, version, env, logs` because there's not point for those to
    have flags like that.
1. ***About FreeBSD***: I really tried but didn't get the `gnu-getopt` to work. `rescript` will still work but using only short options.
1. ***Other miscelaneous improvements***: simplify functions to use or re-use existing code/commands. For example, now the automatic function will use other functions
    such as the backup, cleanup, info functions and so on. There was a lot of repeated code, so now it will make use of the existing one. Re-using commands/code makes functions like
    `archive` are a bit faster since instead of checking for snapshots a couple of times, now it just does it two times and then use the ouptut of those two commands to proceed
    and verify the output, and retrieve the information needed to know if it will proceed or not. This makes the function a little bit faster than before.

**Note about `cron`**:

At least for me, it seems to be a little trouble with `v4.5` and cron jobs. I'm guessing it is because of the `getopt` change
that doesn't let me pass arguments (flags, options). If you use `cron` with the automatic function like this: `rescript [repo_name]`,
it runs as expected. However, when you add commands and options it doesn't work at all. The following two workarounds worked for me:

1. "Redirect" the output to `/dev/null` (if you use the log flag you don't have to worry about not getting the output in your logfile; it will
   still save the output to your logfile).

   ```
   0 */1 * * * rescript [repo_name] backup -lt > /dev/null
   ```

2. Command substitution (I don't know if this is good practice but at least for me it worked).

   ```
   0 */1 * * * $(rescript [repo_name] backup -lt)
   ```

Both methods worked just fine. Of course, if you are not using the `--log` feature and you redirect the output yourself,
then you probably won't have this problem since you'll need to use `>` (redirection) anyways and this is what is actually
doing the "trick" for the command to run. If you are not having any problem at all, don't mind this note.

## v.4.4

---

### May 10, 2019

**Fixes**:

1. Minor fixes when displaying version available to download with `update` command.
2. Fixes in `archive` command. Instead of using the variable that sets the path, when
   syncing directories it was doing it with `/tmp/archive`. Now it is fixed (it doesn't
   affect GNU/Linux or FreeBSD distributions; I don't think that with Mac were any problems
   either).

## v.4.3

---

### April 24, 2019

**Fixes, additions and removals**:

1. Fixed `version` command to display more info.
2. Replaced `==` with `=`.
3. Edited help displayed.
4. Since `restic 0.9.5` is out and it includes `--group-by` for `snapshots` command,
   this `rescript` flag was removed; `restic` flag is more complete, you can use it
   with host, paths and tags. The command `snaps` is still there because I like to
   see the compact version by default, but that is all that this `rescript` command does;
   to display compact version of snapshots by default.
5. Fixed some quotes here and there, some variables, etc.
6. Added a `-d, --dry-run` flag for `backup` command. This flag uses `du`. If you use
   this flag, by default it will take your BACKUP_DIR variable and the exclusion file,
   and it will display the files that would be saved and the size. Note that for this
   flag to work properly with the exclusion file, directories must be specified with
   the absolute path; if you have $HOME/Downloads, for example, it will not read it
   properly for some reason. You can also specify other `du` options. e.g.:

        rescript [repo_name] backup --dry-run
        
   This command will display the directories that would be saved and the total size
   using the BACKUP_DIR and your exclusion file.

        rescript [repo_name] backup --dry-run -s
        
   This `-s` option stands for `--summarize` option in `du`. So, this will use your
   BACKUP_DIR but will omit the exclusion file. You can add the exclusion file manually
   adding this other `du` flag `--exclude-from="/path/to/your/exclusion_list"` or
   adding `--exclude="exclude_pattern"`, or both or any other `du` option. By default
   `du` in this script will use `-hc` to display size in human readable and count.
7. Added `--help` flag as in "Global Flags"; the "design" was there initially but
   I never get to add the flag itself.

## v.4.2

---

### April 7, 2019

**Fixes and additions**:

1. Fixed variables quotes, unnecessary commands and others.
2. Added variable "SKIP_OFFICE" for the configuration file and added
   `-S|--skip-office` flag for `backup`. This variable and flag can be used
   to temporarily exclude open (in-use) "Office Documents" at the moment
   a backup process is running. For example, if you have backups running
   automatically via cron or using this script, you could only set the variable
   "SKIP_OFFICE" to "yes" so when a backup is performed the "Office" documents
   in use at the moment will be excluded for this unique snapshot. Why exclude
   open documents? When restic is backing up at the moment an "Office Document" is
   open, there is a posibility that restic saves a truncated/damaged file. For more
   about this subject check [this thread](https://forum.restic.net/t/excluding-in-use-files-necessary/1476)
   in the restic forum.
3. Added `env` command. This command will display variable values in your configuration file.
4. Added `snaps` command. This command is for displaying snapshots but unless `restic`, this
   command will display snapshots in compact mode by default. Also, and this specific flag
   was the real purpose for this command, `snaps` has a flag `-g, --group-by` and it works
   for displaying snapshots by host or tags. So if you execute `rescript [repo_name] snaps --group-by host`
   it will display all snapshots ordered by hostname. It works for host and tags in compact mode only.
5. Fixed `archive` function. If you had an "archive" snapshot already it worked but if not, it was not
   creating a snapshot. Also, the `tmp` directory will now be determined by variables, so if your system
   have another `$TMPDIR`, it will follow that instead of a fixed directory that my or may not exist,
   depending on the operating system (termux in android, for example).
6. Fixed policies array so when determining if there are policies, it will now read them correctly.
7. Fixed `update` and `install` commands. They will now respond properly when using Mac or FreeBSD.
8. `archive` and `update` will now complain for dependencies (`wget, rsync`) if they're not installed.
9. Added a little something to display Android version if used with Termux.

## v.4.1

---

### March 7, 2019

**Fixes**:

1. Fixed `archive` function. Before it was working okay but it was not syncing
   new files. For example: you have snapshot 1 and 2. There is a file called "ImportantFile.txt"
   in the snapshot 1 but it was deleted after that snapshot, so snapshot 2 does not
   have the "ImportantFile.txt"; `archive` took care of it and saved it to the
   special "archive" snapshot. That is expected. Then the file was restored and edited
   and after that a snapshot 3 happened. For some misterious reason the file was deleted
   again and when restic took snapshot 4 the file was missing, so `archive` do its work
   again. You would think that now "archive" snapshot contains the latest "ImportantFile.txt"
   version, but that is not true; the file is in there but is the oldest version. Why this
   happened? `archive` uses rsync to sync the deleted files but the error in the code was
   to use rsync to sync the old snapshot to the new one like this:

   ```
   rsync -a /path/to/old/snapshot/* /tmp/archive
   ```

   In theory it was working but for this specific unsusual behaviour it was taking
   old files and deleting the new ones. Now rsync will execute twice and it will sync
   the old snapshot first and then the new one, so all newly edited files would be
   there but it needs to create a new directory instead of 2, which at the end are deleted;
   now it looks like this:

   ```
   rsync -a /path/to/old/snapshot/* /tmp/archive
   rsync -a /path/to/latest/snapshot/* /tmp/archive
   ```

   After that it will create the new snapshot and that's it.

## v.4.0

---

### March 4, 2019

**Changes, fixes and additions**:

1. Fixed output so now it doesn't display 0 days, 0 hours, 0 minutes or 0 seconds;
   now instead of displaying "1 hour 0 minutes and 20 seconds" (for example) it will
   display "1 hour and 20 seconds". This applies for the "duration" and when it display
   "next cleanup".
2. Added a variable called "ARCHIVE". By default is blank and you should change it to
   "yes" if you want to use it for the automatic function (see point 3).
3. Added a new command called `archive`. This command will check differences between
   the latest two snapshot and it will create a new "special snapshot" with the path `/tmp/archive`
   and tag `archive` containing only the files deleted from the latest snapshot. It will also
   be dated as "2015-01-01" so it will always be the first snapshot displayed. To properly have a
   real archive of all deleted files, it is better to use this option after every
   `backup` made, so it will consider all deleted files. If it is used just from time to time,
   it will work but `rescript` will not know if there are other deleted files. For example, if you used
   the `archive` function today and then you took five snapshots and use it again, it will be a gap
   of three snapshots (being the latest two of the five used by `diff`); rescript will only check
   differences between the latest two snapshots and "archive" deleted files between them.
   This function also available as a flag for other commands. For example, you can use
   `rescript [repo_name] backup --archive` and it will perform a backup and then will
   execute the "archive" function. `archive` could take time if there are a lot of big files; keep
   in mind that this function will need to perform `diff` first, then it will restore all deleted
   files from the second most newest snapshot, then will restore the "archive" snapshot (if exists),
   merge all data and then create a new snapshot with all deleted data. Good thing is that, since
   all this data is already in your repository, the `backup` progress should not take too long.
   This command also have a `-H, --host` flag so you can use it indicating one specific hostname.
   If no hostname is indicated, the default is to use your machine's hostname or the hostname
   in the variable `HOST` in your configuration file. IMPORTANT: must have `rsync` installed
   to use this function; the script will not display any errors but it will not work correctly.
4. Added flags `-a, --archive` to `backup` and `cleanup` commands.
5. Added `-e, --exec` to `mounter` so you could pass flags like `--allow-other, --allow-root, --host, --path`
   and others but it is sill using tha variables in your configuragion file.
6. Added `-e, --exec` to `backup` so you could pass flags like `--no-lock, --no-cache`
   and others but it is sill using tha variables in your configuragion file.
7. Fixed `stats` output for the "automatic" function, so now will display the hostname and use
   `restic stats --host [hostname]` for original and deduplicated size for latest snapshot.
8. Fixed `changes` command. Now if there is no host, path, tag, etc., it will display
   a message saying that there is no value for your option; it will also now display
   an error message for invalid flags.

## v.3.9

---

### February 14, 2019

**Changes, fixes and additions**:

1. "usage" is now a function instead of a variable; nothing relevant for users.
2. The script variables are now lowercase to make easier to know if the variable
   is just for the script or for the configuration file / system vars.
3. Instead of using commands to work with rescript directories and files, now
   they will work with new script variables for those directories and files;
   this means if you want to move your ".rescript" directory to another location,
   you can just move it manually and set the script variables to point to that
   new location so you don't have to mess around with the whole script and guess
   what function is using the rescript directories/files to manually change it
   all. For example, if you want to use `/etc/rescript` to store your configuration
   files, then you just need to adjust these variables and copy your existing files
   to the new directory. You'll need to make sure to set the right permissions to
   those directory/files.
4. Change a lot of the "if" statements to "case"; it made the whole script longer
   but easier to understand/edit.
5. The script now will read any letter as lowercase except for `logs` and `restorer`.
6. Added a new menu for easier installation when using `rescript install`.
7. Added `printf` to display output so it will automatically display lines and text
   instead of adding custom lines and text per function (it actually shorten the code
   a lot, but as I said, the use of "case" instead of "if" statements makes it longer now).
8. Added a new command called `changes`. This new command will automatically select two must recent
   snapshots and compare them using `restic diff`. This command works per hostname automatically;
   if you are using `HOST` variable in your configuration file, it will automatically use
   that hostname. You can override this behaviour using `-H|--host, -p|--path, -T|--tag`
   flags. It also have an `-m|--metadata` flag to display changes in metadata and this flag
   can be used with `-H, -p, -T`.

## v.3.8

---

### January 29, 2019

**Changes**:

1. Added `update` command. This command can be used to update the script in place.
   This will work from version 3.8 onward.

## v.3.7

---

### January 26, 2019

**Changes**:

1. Changes in the editor menu that removes a bit part of the menu code making
   it a little bit simple. This change remove the need to use `sudo rescript editor`
   when the script is istalled in `/usr/bin`. There is also a new `.deb` package
   for an easier installation that you can find in the [release page](https://gitlab.com/sulfuror/rescript.sh/releases).

## v.3.6

---

### January 23, 2019

**Changes and fixes**:

1. Changed shebang to `env bash` for compatibility with OS's other than GNU/Linux.
2. Changes in editor menu code (it actually doesn't change behavior).
3. Added `--keep-within --keep-tag` to code; from v3.6 onwards, KEEP variables
   can be left blank if not used and it is advise to do so because if you do not
   use all KEEP, leaving it blank prevent the script to pass an additional flag
   and misbehave (it doesn't behave weirdly as far as I tested). So, if, for example,
   you use just "KEEP_LAST" variable, the script will pass `forget` command as follows:

   ```
   restic forget --keep-last N
   ```

   Before this change, the script was passing all flags even if the value was "0" like this"

   ```
   restic forget --keep-last N --keep-hourly --keep-daily --keep-weekly --keep-monthly --keep-yearly
   ```

4. Added new flags to `cleanup`.
   1. `-d, --dry-run`: this flag will allow you to pass `--dry-run` so it will actually
      delete nothing. e.g.:

      ```
      rescript [repo_name] cleanup -d
      ```

      It also allow your to add other restic flags for `forget`. e.g.:

      ```
      rescript [repo_name] cleanup -d --group-by [host|tags|path] --tag [tag]
      ```

   2. `-e, --exec`: this flag, like `-d` allows other restic flags for `forget` but
      it will actually forget snapshots and delete data with `prune` at the end. e.g.:

      ```
      rescript [repo_name] cleanup -e --group-by [host|tags|path] --tag [tag]
      ```

5. Added new variables in script to set keep rules (it doesn't change anything for
   user's usage).
6. Added new variables in script to set `$TAG` and `$HOST`, if used (it doesn't change
   anything for user's usage).
7. Removed code for "rescript locks" and added a new function for the "rescript lock" file
   (it doesn't change anything for user's usage).
8. Change function for displaying the next `cleanup` time (it doesn't change the behavior,
   just simplify the code a little bit).
9. Added an array for keep policies to improve script behaviour preventing it to
   pass unneded blank keep policies (see point number 3).
10. Added new message if CLEAN is greater than 0 and keep policies are not set.
11. An error message was being displayed if the "datefile" was deleted from the `config` directory.
    Added code to create one if CLEAN if greater than 0 so it doesn't display the
    annoying error.
12. Simplified `cleanup -n` function and now is being re-used for other functions (it doesn't
    change anything for user's usage or behavior).

## v.3.5

---

### January 12, 2019

**Changes**:

1. Now you can specify more than one location in `BACKUP_DIR` variable.
2. Rescript flags now are called "Global Flags" because they can be used
   for all commands including restic commands. There's only three: `-h`, `-l`, `-t`.
   These flags now must be used BEFORE all other commands and its flags.

**Fixes**:

1. Fixed error when function decides to display the number of days and hours
   when running `cleanup -n`.

## v.3.4

---

### January 6, 2019

**Changes**:

1. Now the `--random` flag doesn't exists. The `checkout` command replaces it.
2. Added `--time, -t` flag to display output with date, time and duration; this
   is only available for `restic` commands since all `rescript` commands already
   displays an output with date, time and duration. Now `restic` commands will not
   display this output unless specified; version 3.3 displays the output for all
   commands automatically even when it doesn't make any sense. This flag must be
   indicated before any command and it can be combined with `--log`.
3. Changed the behavior for `--log` flag; for version 3.3 and erlier this flag
   was only available for `rescript` commands. Changing the behavior means that
   from now on it will be indicated before any commands and options and now it can
   be used for `restic` commands too and it can be combined with `--time`.
   e.g.: `rescript [repo_name] --time --log check --read-data`.
4. All flags now have a shorthand flag. e.g.: `--help, -h`, `--host, -H`, `--log, -l`,
   `--time, -t`, `--snapshot, -s`, `--tag, -T`, etc.

`--time` and `--log` will not work if indicated at the end of the commands. This was
the only way I found that can be useful for all commands including `restic` commands
alone.

**Fixes**:

1. Fixed output for `cleanup --next` to display singular words when days, hours
   or minutes are 1.
2. Fixed "Build Exclusions" menu; it wasn't recognizing `back` or `exit` options.
3. Fixed a couple of typos.

## v.3.3

---

### December 19, 2018

**Fixes**:

1. Fixed code for Mac OS and FreeBSD when using the `automatic` function, `cleanup`
   command, `cleanup --next`; also `config` and `editor` commands were having
   trouble because of `sed` and now, if you follow the README instructions for
   Mac and FreeBSD, you're not supposed to have any trouble.

## v.3.2

---

### December 18, 2018

**Fixes**:

1. Fixed some issues with the output with Mac OS and FreeBSD when displaying the
   Operating System.
2. Fixed some issues with the ouptput when running the `automatic` function for
   FreeBSD and Mac OS.

**To do**:

1. Fix code for Mac OS and FreeBSD when using the `automatic` function. The `date`
   command is not reading the date from the "datefile". So the "CLEAN" variable
   does not work with FreeBSD and Mac OS for now.

## December 16, 2018

**Changes and Fixes**:

1. Added two functions: one determines the operating system (if it is GNU/Linux, FreeBSD or OSX)
   and another to calculate duration of commands.
2. Added output with date and duration for regular restic commands.
3. Added `--host` flag for backup operations and variable in the configuration
   file for this flag. If the variable is empty the `backup` command will use
   the system `HOSTNAME`. If the variable is used then `backup` command will use
   the hostname indicated in it (fix for issue #1).

## v.3.1

---

### December 12, 2018

**Changes and Fixes**:

1. Added a warning when indicating a rescript invalid flag and displays help.
2. Added "PATH" code for `$HOME/bin` and `$HOME/.local/bin` because if you use
   cron job and `restic` binary is not in the default system "PATH", it will
   not execute.
3. Fixed code to keep flags and options inside functions.
4. Fixed `restorer` command so it will not misbehave when using invalid options or flags.
5. Other improvements in code.

## v.3.0

---

### November 25, 2018

**Changes**

Ended up redesigning the whole thing. Check the README.
Now the script use functions, a whole new menu in `config`, new commands and flags.

## v.2.0

---

### November 14, 2018

**Changes and Fixes**:

1. Added dialog when you run `rescript config` to choose the text editor and
   open configuration files.
2. Fixed `logs` command when running `--list` or `--remove`. From now on if your
   `recript` instance doesn't have any log it will display a message telling you
   that there are not any log files to list or remove.

## v.1.9

---

### November 3, 2018

**Changes**:

1. Added some commands (check the [Commands and Options](https://gitlab.com/sulfuror/rescript.sh/blob/master/README.md#commands-and-options) section in README):
1. `install, --install`
1. `config, --config`
1. `logs, --logs`
1. `version, --version`

1. Added a configuration file which contains all variables.

**Fixes**:

1. Fixed the "Destination" output which was displaying the backup directory instead, if leaved blank.

## v.1.8

---

### October 20, 2018

**Changes**:

1. Added "LOGGING" variable to keep logs in your `.rescript/logs` file.
2. Fix date format so it display AM or PM hours.

## v.1.7

---

### October 10, 2018

**Changes**:

1. Added the `-e` option. Use `rescript -e --help` for usage or see README file.
2. Added B2 credentials option.
3. Added an exclusion file and generic exclusion lists.
4. Added `--keep-last` option.
5. Added an option to automatically move `datefile` from `logs` to `config` directory.
6. Removed the exclusion list (unneccesary with exclusion file).

**Fixes**:

1. Typos.
2. Reset credentials.

## v.1.6

---

### October 6, 2018

**Changes**:

Basically, changes are less user commands and more restic commands.
Now all restic commands are available within the script (not sure if this is
the best approach but it works). Past "user commands" were removed
except for `-r` (restore). The only restic commands that are not "available"
(in the sense that if you execute it it will not behave as restic itself) are:

1. `backup`: the command exists but it will behave the same as `-b`.
2. `help`: this command will display the `rescript` help.
3. `version`: this will display the `rescript` version you're using.

## v.1.5

---

### October 2, 2018

**Changes and Fixes**

1. There are changes in v1.5 with the output; now it will display the
   host and if you do not indicate the "Destination" it will output
   the backup directory instead.
2. Added a "help" command so if you type ./rescript.sh help it will
   actually display the help for the script and not the help for
   restic (I consider this a fix too because to display the restic
   help is not the best approach because commands may vary).
3. Added "flags" for "user options". Now every user option have its
   own "--help" flag wich will display how to use every option.
   Also, added the ability to pass restic options for those "user
   options" (all explained in the `--help` flag).

In general, now the script has many more options that it used to.
Still, the purpose hasn't changed. I did this for the sole purpose
of getting a nice output (at least for me it looks nice) for automatic
backups and to clean itself in "X" numbers of days. As time has passed
I needed to do some tasks in my repo and having multiple hosts in one
repo and working with various repos, it needed some attention that
I wasn't able to do automatically or with the script, so I added those
options that I mostly use to make my life easier.

## v.1.4

---

### September 27, 2018

**Changes and Fixes**

1. Divided the "REPO INFO" into two: the ones you MUST put and
   cannot be left blank and the ones that you can left blank.
2. Now the script will set the "$HOME/bin" and "$HOME./local/bin" (if
   directories exist) paths in case these paths are not already set,
   then it won't fail if you have the restic binary in your home directory.
3. The "datefile" will now be created only if you set the "CLEAN" value.
4. Restore option was moved to "User options" instead of the "Automatic" ones.
   I discovered how to use "$OPTARG" for restores, so... yeah, now
   you can just put the snapshot you want to restore after the `-r` option.
5. The `-n, -next-cleanup` options was giving negative numbers if the time
   for the next "cleanup" already passed, so now it will give you a message
   saying that it will be run "on the next run". Also, if you have not
   set the "CLEAN" variable it will display an explanation on how to do it
   and give you the "usage" link for more information.
6. Any atempt to pass an "User Option" (requires one argument) will tell you
   that "No argument value was indicated for..." the option you chose and it will
   display the "help".
7. The "cleanup" process was changed a little to display the days, hours or minutes
   left to the next "cleanup" and now it will forget first, prune and check --cleanup-cache
   at the end.

## v.1.3

---

### September 21, 2018

**New Options and Some Fixes**

New options are available now. The new options are:

**Automatic Options**

1. `-d, -deep-check`: this option will perform `check` with the `--read-data`
   flag.
2. `-n, -next-cleanup`: this will display when the next "cleanup" will be done.
3. `-s, -stats`: this will display the `stats` with `--mode` flag for
   original size of latest snapshot, deduplicated size of latest snapshot,
   original size of all snapshots and deduplicated size of all snapshots.
4. `-u, -unlock`: this option WILL NOT unlock your repository. When you run this
   script it will create a separate lock just for the script (it has nothing
   to do with the restic locks), so if your latest run left a lock (which is
   very unlikely unless it occurs an abrupt shut down while the script was running)
   and you're trying to do something with the script, it will display that the
   script is already running and it will not run again until the lock file is removed.
   If you're really sure the script is not running you can just run this option
   and it will delete the lock file so you can continue with your operation.

**User Options**

I've added some more options called "User Options" because it requires more than
just the option; these options require a "argument".

**Usage**: `./rescript.sh [user_option] [argument]`

1. `-f`: this option is for `forget`; you need to type the `-f` and the snapshot
   ID you want to forget like `./rescript.sh -f 0005sdf6`, for example.
2. `-g`: this option is for `find`; it will help you find a file or directory
   inside your repo when you type `./rescript.sh -g file_pattern_or_directory`.
3. `-k`: this stands for `keys`; you can use any option of the `key` command
   with this option like `./rescript.sh -k list`, for example.
4. `-l`: this option is for `ls` to list files in a snapshot; example:
   `./rescript.sh -l latest`.

You can just use one argument with every "user option". This means that, for
example, you can just use `-f` for one snapshot at a time. I'm using `getopts`
for this and I don't really know how to make this run with infinite arguments.
If you know how to make this better, please feel free to share.

**Fixes**

1. Typos and quoting.
2. Remove `unlock` automatically; you can just use `./rescript.sh unlock` if needed.
3. Now the script will create the lock file for every option except for `-h` and `-v`.
4. Now the script will create one directory with two subdirectories. The main
   directory will be hidden in your `/home` and it will be called `.rescript`; it
   a subdirectory called "lock" where it will be placed the lock file and another
   called "logs" where it will be placed the datefile. I changed it this way
   for convenience. Instead of looking into `./local/etc/etc` I wanted a single
   directory with all the script related files. Also, I use this script with
   a cron job and logs files are created every run with the cron job and I find
   it convenient to create a `log` file if anyone uses the script the same way.
5. "Commands" code was unnecessary so I just simplified the code a little. Also
   note that **you can run almost every restic command** but the downsize is that
   you cannot run restic options or flags. That means that you can just run
   restic commands that does not require an option (like the "available commands"
   list you get when you type `-h`.)

Change the name from `restic.sh` to `rescript.sh` to not be confused by the
actual program.

### September 14, 2018

**Commands & Options**

So, I've been playing around with the script and added a few nice features.
Now the script has its own `-h, -help` option so you can see all commands
and options available but the following is an short explanation of the
new options:

1. `-b, -backup`: this option is pretty basic; it does what it says... it'll
   take a new snapshot.
2. `-c, -cleanup`: this option will execute `forget` according to the policies
   indicated in your script; also it'll execute the `--prune` flag so it'll
   actually delete the forgotten snapshots.
3. `-h, -help`: this will bring up the help dialog on your terminal emulator.
4. `-m, -mount`: this option will mount your repository; it'll create a
   directory in your `/home` so it can mount your repository. Once you quit
   the mount option with `Ctrl+c` it will delete the directory.
5. `-r, -restore`: this option will do what it says, it will restore.
   It will create a new directory in your `/home` called `restic-restore`
   and it will restore your latest snapshot only. If you want to restore
   a specific snapshot you will have to do it manually.
6. `-v, -version`: this option will display the current version you're using
   of this script.

### September 10, 2018

**Arguments**:

Now the script could be use with the five following arguments:

1. `check`
2. `init`
3. `prune`
4. `snapshots`
5. `unlock`

You can use these arguments as follows:

`./restic.sh argument`

### September 2, 2018

**Changed the way to handle check, forget and prune along with new additions:**

1. Now the script will create a "date file". This will be used to know when it'll
   need to prune according to your choice in the "CLEAN" variable. The default
   is 7 which means that the script will run `check`, `forget` and `prune`
   every 7 days. The file that will be created will only contain the date the
   script was executed when it runs `check`, `forget` and `prune` and it'll be
   created as a hidden file. The file will be called `.datefile_restic` and it'll
   be created in the same directory you put the script. If the file is deleted then
   it'll run `check`, `forget` and `prune` on the next run and it'll create the
   file again.
2. The script will now check if your repository is locked. This will be done by
   checking the `locks` directory inside your repository. If the repository is locked
   it'll run `restic unlock` to proceed with its operation. This operation is optional
   and by default it is set to `no` in the variable called `UNLOCK` at the
   beginning of the script. If you're using this script for multiple machines just
   you're better leaving the script by default. I haven't tested it with
   a repository for multiple machines.
3. Now the script will tell you the files you're excluding in your snapshots
   after the backup.
4. The `clean`, `forget` and `prune` operations are calculated because of the
   `datefile` that now the script will create. When you run your backups and
   it's not time yet to run this commands it'll output the total amount of
   days, hours and minutes left until the next "clean" operation.

### August 27, 2018

Added the things you'll want to change at the beginning of the script so
you don't have to read the whole script trying to figure out what to change or not;
instead I'm using variables at the beginning that you'll use for your password,
repo directory, backup directory, destination, keep and exclude policies, etc.

### August 25, 2018

Edited "Bail if restic is already running". Now the script will
create a little "lock" file so if the script is already running it'll know
because the "lock" file created by the latest process is present. Also, if the
process is killed, terminated, exited, interrupted or quit (so maybe you killed
restic itself or you just restarted or turned off your computer) the "lock" file
will be deleted by the script so you don't have to delete it yourself when you
decides to make another backup. This way, if you're running two separate
tasks using restic the script will still run, because maybe you have two
different repositories and both can start at the same time but using the method
before this change you can't do it because it detects restic itself running
and it will not run until restic is not being used; with this new change
you can work with other repositories and still have this script running.
The whole change it supposed to be transparent if you're using the script. If
you still want to use the other method you can replace the "if" and "trap" codes/lines
with this:

``#Bail if restic is already running
if pidof -x restic >/dev/null; then
    echo "Restic is already running"
    exit
fi``

### August 19, 2018

Added start date and hour of script, end date and hour of script
and duration of all script at the end.

### August 18, 2018

Added "Bail if restic is already running" so if there's a previous
job that is not finished it doesn't mess it up and just let it finish.
Added start date and hour of script, end date and hour of script
and duration of all script at the end.

### August 18, 2018

Added "Bail if restic is already running" so if there's a previous
job that is not finished it doesn't mess it up and just let it finish.
