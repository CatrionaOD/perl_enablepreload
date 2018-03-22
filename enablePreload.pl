usr/bin/perl
use 5.010;
use strict;
use warnings;
use Term::ANSIColor;
use File::Find;
use File::Copy qw(copy);
use File::Basename;
chdir "/home/e078272/2sys_apps_01/apache/server20cent/bin/startups";
### Stores all the instances
my @search_files = <"C:/cygwin64/home/e078272/2sys_apps_01/apache/server20cent/bin/startups/apachectl.*">;
### Stores instances that have no preload enabled
my @found_files;
### Searches for instances without preload and pushes them into found_files array
foreach my $file (@search_files) {
  my $counter=0;
  #print "file name = $file\n";
  open (FILE, $file);
  while (my $line = <FILE>) {
    if ($line =~ /preload -M/) {
      $counter++;
      last;
    }
  }
  if ($counter == 0) {
    push @found_files, $file;
  }
  close $file;
}
my @conf_files = <"C:/cygwin64/home/e078272/2sys_apps_01/apache/server20cent/conf/*.conf">;
### Checks through found_files array ANDing them with the conf files to create change_array with the instances to change.
my @change_array;
my @printchange_array;
foreach my $file (@found_files) {
  my($filename, $directories, $suffix) = fileparse($file);
  my $comp_name = substr ($filename, index($filename, '.')+1);  # name from @search_files
  foreach my $file2 (@conf_files) {
    my($filename2, $directories, $suffix) = fileparse($file2);        # name from @conf_files
    if ($filename2  eq "$comp_name.conf") {
      push @change_array, $file;
      push @printchange_array, $comp_name;
    }
  }
}
print ("\nFiles missing Preload: \n");
print ("=======================================================\n");
print join("\n", @printchange_array);
if (scalar(@printchange_array)==0) {
  print "--No files found.";
}
print ("\n=======================================================");
# Make backup of files in change_array of format filename_todaysdate.
my($day,$mon,$year) = (localtime)[3,4,5];
$mon = sprintf '%02d', $mon+1;
$day   = sprintf '%02d', $day;
$year += 1900;
my $curr_date = $year . $mon . $day;
my @bkup_files;
foreach my $file (@change_array) {
  my $new_file = $file . "_" . $curr_date;
y($file, "$new_file") or die "Copy failed: $!";
  push @bkup_files, $new_file;
}
print ("\n\nBackup files created: \n");
print ("=======================================================\n");
print join("\n", @bkup_files);
if (scalar(@bkup_files) == 0) {
  print "--No backup files created.";
}
print ("\n=======================================================");
### Add missing lines to the files
if (scalar(@change_array) != 0) {
  print "\nMissing lines are being added to files.";
}
foreach my $file (@change_array) {
  open (my $in,  '<', $file ) || die "Can't open $!\n";
  open (my $out, '>', "$file.new") || die "Can't open $!\n";
  while(<$in>) { # print the lines before the change
    print $out $_;
    last if $_ =~ /OPENSSL_ENGINES=/;
  }
  my($filename, $directories, $suffix) = fileparse($file);

  my $line = <$in>;
  print $out "NFAST_NFKM_TOKENSFILE=/sys_apps_01/apache/server20Cent/logs/$filename/nfkm_preload\n";
  next if ( $_ =~ /export LD_LIBRARY_PATH LIBPATH OPENSSL_ENGINES/);
  print $out "export LD_LIBRARY_PATH LIBPATH OPENSSL_ENGINES NFAST_NFKM_TOKENSFILE\n\n";
  my $third_line = qq(test -x /opt/nfast/bin/preload && NFAST="/opt/nfast/bin/preload -M");
  print $out "$third_line\ntest -f \$NFAST_NFKM_TOKENSFILE && rm \$NFAST_NFKM_TOKENSFILE\n";
  while( <$in> ) { # print the rest of the lines
    print $out $_;
    last if $_ =~ /HTTPDCONF=/;
  }
  my $fifth_line = qq(HTTPD="\$NFAST /sys_apps_01/apache/server20Cent/versions/server2.4.10/bin/httpd \$HTTPDROOT \$HTTPDCONF"\n)    ;
  print $out $fifth_line;
  while ( <$in> ) {
    print $out $_ unless ( $_ =~ /HTTPD=/ );
  }
  rename ("$file.new", $file) || die "Unable to rename: $!";
  int ("\n\n**Preload successfully enabled!**\n");
   use bash command to restart instances.
  reach my $file (@change_array) {
  my($filename, $directories, $suffix) = fileparse($file);
  system ("apachectl --version=20Cent --instance=$file --command=start");
  my $run_check = 0;
  my $time = 0;
  while (($run_check ==0)&&($time<30)) {
    system ("if pgrep -x $filename > /dev/null
            then
              $run_check = 1;
            else
              sleep(3);
              $time += 3;
          fi");
  }
  if ($run_check == 1) {
    print "\n$filename has been restarted successfully.";
  }
  else {
    print "\n$filename was not successfully restarted, back up file will bei restarted instead.";
    my $bkup_file = $filename."_".$curr_date;
    system ("apachectl --version=20Cent --instance=$bkup_file --command=start");
        }
}        
