# September 2, 2018
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
   checking the `locks` file inside your repository. If the repository is locked 
   it'll run `restic unlock` to proceed with its operation. If you're using this 
   script for multiple machines just delete or comment the lines that contains 
   the `unlock` command along with the `if` parameters.
3. Now the script will tell you the files you're excluding in your snapshots 
   after the backup.
4. The `clean`, `forget` and `prune` operations are calculated because of the 
   `datefile` that now the script will create. When you run your backups and 
   it's not time yet to run this commands it'll output the total amount of 
   days, hours and minutes left until the next "clean" operation.

# August 27, 2018

Added the things you'll want to change at the beginning of the script so 
you don't have to read the whole script trying to figure out what to change or not;
instead I'm using variables at the beginning that you'll use for your password,
repo directory, backup directory, destination, keep and exclude policies, etc.

# August 25, 2018

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

# August 19, 2018

Added start date and hour of script, end date and hour of script
and duration of all script at the end.

# August 18, 2018

Added "Bail if restic is already running" so if there's a previous
job that is not finished it doesn't mess it up and just let it finish.