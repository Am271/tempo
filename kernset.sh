#!/usr/bin/perl -w
system ("clear");
print "\n";
if ( $< == 0 )
  {
	print "The kernset.sh script is being run with root privileges.\n\n";
  } 
  else
  {
	print "Your username is - " . (getpwuid($<))[0] . "\n\n";
	print "You must be logged in as root or use sudo to run this script.\n\n";
	print "Do you want to continue kernset.sh via sudo?  <y n>\n";
	chomp ($response = <>);
	if ($response ne "y")
	    {print "\n\n";
    	     print "Run of kernset.sh was aborted by request\n\n";
             exit;}
        print "\n\n";
	use Cwd qw(abs_path);
	my $restartpath = abs_path($0);
        system ("sudo $restartpath");
        exit;
  }
$parmkernelname   = "vmlinuz";
$parminitrdname   = "initramfs.img";
$parminitprefix   = "initramfs";
$dirtarget        = "/boot/";
$dirsource        = "/boot/";

#####################################################################

$vmlinuz_release  = 0;
$vmlinuz_filename = "";
$initrd_release   = 0; 
$initrd_filename  = "";

print "\n";
print "Running the  - Linux -  link setup using source directory   " . $dirsource . ".\n";
print "                                    The target directory is  " . $dirtarget . ".\n";
print "\n";

opendir(IMD, $dirsource) || die("Cannot open directory");
@filearray = readdir(IMD);
@filearray = sort @filearray;
closedir(IMD);
$kernelfound = "no";
$initrdfound = "no";

foreach $filename (@filearray) {
    if (index($filename, 'rescue') != -1) {next}
    if (index($filename, 'dump')   != -1) {next}
    $first6 = substr($filename, 0, 6);
    $first7 = substr($filename, 0, 7);
    $first9 = substr($filename, 0, 9);
    $last4  = substr($filename, -4);
    $last6  = substr($filename, -6);
    $last12 = substr($filename, -12);
    if ($last12 eq "fallback.img") {next}
    if ($first6 eq "initrd")
       {$parminitrdname   = "initrd.img";
        $parminitprefix   = "initrd";}
    if (($last4    eq ".old")) {next}    
    if (($filename eq $parmkernelname) or ($filename eq $parminitrdname)) {next}
    if (($first7 ne $parmkernelname) and ($first9 ne $parminitprefix) and ($first6 ne $parminitprefix)) {next}
    #	print "Processing  $filename\n\n";

    $relstring = $filename;
    $relstring =~ s/-generic//;
    $relstring =~ s/generic//;    
    $relstring =~ s/vmlinuz-//;
    $relstring =~ s/-amd64//;
    $relstring =~ s/initrd//;
    $relstring =~ s/initramfs//;
    $relstring =~ s/.img-//;
    $relstring =~ s/.img//;

    $relstring =~ s/-/./;
    
    $rawrel    = "." . $relstring . ".";
    $rawrel    =~ tr/./ /;

    # print "Rawrel-B $rawrel\n\n";

    my ($rel1, $rel2, $rel3, $rel4) = split " ", $rawrel;
    my $rel1 = sprintf "%05d", $rel1;
    my $rel2 = sprintf "%05d", $rel2;
    my $rel3 = sprintf "%05d", $rel3;
    my $rel4 = sprintf "%05d", $rel4;
    my $release = $rel1 . $rel2 . $rel3 . $rel4;

    # print "Rel1 $rel1 Rel2 $rel2 Rel3 $rel3 Rel4 $rel4 Filled $filled Release $release\n\n";
   
                  
    $fullfile       = ($dirsource . $filename);
  	use Time::localtime;
  	use File::stat;
        $fullfile_printtime = ctime(stat($fullfile)->mtime);
  	if ($first7 eq $parmkernelname) {
    	     $kernelfound = "yes";
    	     print "The modify date for $fullfile         is $fullfile_printtime\n\n";
    	     if ($release > $vmlinuz_release) {
	          $vmlinuz_release   = $release;
    		  $vmlinuz_filename  = $filename;
             }
        }
  
  	if (($first9 eq $parminitprefix) || ($first6 eq $parminitprefix)) {
    	     $initrdfound = "yes";
     	     print "The modify date for $fullfile   is $fullfile_printtime\n\n";
     	     if ($release > $initrd_release) {
	          $initrd_release   = $release;
	          $initrd_filename  = $filename;
             }
        }
}

if (($kernelfound eq "no") || ($initrdfound eq "no"))
   {print "The Linux kernel files were not found in the /boot directory\n\n";
   print  "      kernset.sh was aborted\n\n";
   exit;
}

$vmlinuz_link     = $dirsource . $parmkernelname;
$initrd_link      = $dirsource . $parminitrdname; 

system ("rm   -f        " . $vmlinuz_link);
system ("rm   -f        " . $initrd_link);

$vmlinuz_target = $dirtarget . $vmlinuz_filename;
# print   $vmlinuz_target . "    " . $vmlinuz_link . "  Linker \n";
link $vmlinuz_target , $vmlinuz_link||die "vmlinuz link failed";
$initrd_target  = $dirtarget . $initrd_filename;
link $initrd_target , $initrd_link||die   "initrd link failed";

$vmlinuz_printtime = ctime(stat($dirsource . $vmlinuz_filename)->mtime);
$initrd_printtime  = ctime(stat($dirsource . $initrd_filename)->mtime);
print "\n";
print "\n";
print "\n";
print "The most recent kernel filename is  $vmlinuz_filename          It was modified  $vmlinuz_printtime\n";
print "The kernel release string is        $vmlinuz_release\n\n";
print "The most recent initrd filename is  $initrd_filename    It was modified  $initrd_printtime\n";
print "The initrd release string is        $initrd_release\n\n";
print "\n";
print "\n";
print "   kernset.sh kernel link setup successfully completed\n";
print "\n";
