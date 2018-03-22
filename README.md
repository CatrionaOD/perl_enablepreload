# perl_enablepreload
Automating the process of enabling preload on Apache instances to avoid memory leak and performance issues.

Script goes through directory and searches for files missing the lines of code to enable preload. This array is then shortened to only include instances currently running on the server. Backup files are created of the files to be changed and the lines are added to the files. They are then restarted. If they are not successfully restarted within 30 seconds the user is notified and the backup file will be restarted instead.
