# perl_enablepreload
Automating the process of enabling preload on Apache instances to avoid memory leak and performance issues.

Script goes through directory and searches for files missing the lines of code to enable preload. This array is then shortened to only include instances currently running on the server. Backup files are created of the files to be changed and the lines are added to the files. They are then restarted. I want to add that it will check that the instances have restarted properly and, if they haven't, that the backup file will be started again and the user informed of the failed restart.
