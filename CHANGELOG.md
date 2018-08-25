8/25/2018 - Edited "Bail if restic is already running". Now the script will 
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

#Bail if restic is already running

``if pidof -x restic >/dev/null; then
    echo "Restic is already running"
    exit
fi``

8/19/2018 - Added start date and hour of script, end date and hour of script
and duration of all script at the end.

8/18/2018 - Added "Bail if restic is already running" so if there's a previous
job that is not finished it doesn't mess it up and just let it finish.