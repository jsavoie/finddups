#!/usr/bin/perl
use strict;
use warnings;
use Digest::SHA;
use FileHandle;
use Getopt::Std;
use File::Spec;

my $context=new Digest::SHA;
my %filelist;

sub sha1sum ($);
sub processdirectory ($);

sub sha1sum ($)
{
	my $testfile = shift;
	my $filehandler=new FileHandle "<$testfile";
	binmode($filehandler);
	$context->reset();
	$context->addfile($filehandler);
	return $context->hexdigest();
}

sub processdirectory ($)
{
  my $targetdir = shift;
  my $dirhandle;

  opendir($dirhandle, $targetdir) || die "couldn't open directory";
  my @direntries = readdir($dirhandle);

  foreach my $filename (@direntries)
  {
	if (($filename ne "\.") && ($filename ne "\.\."))
	{
		my $fullpath = File::Spec->catfile($targetdir, $filename);
	  	if (-d($fullpath))
	        {
	        	processdirectory($fullpath);
	        }
		elsif (-f($fullpath))
		{
			$filelist{$fullpath} = (stat($fullpath))[7];
		}
	}
  } #end foreach

  closedir($dirhandle);
} # processdirectory

# main
my $lastfilesize = -1;
my $lastfilehash = "none";
my $lastfilename;
my $file;

foreach my $direntry (@ARGV)
{
        processdirectory($direntry);
}

foreach $file (sort {$filelist{$b} <=> $filelist{$a} } keys %filelist)
{
	if ($lastfilesize == $filelist{$file})
	{
		if (sha1sum($file) eq sha1sum($lastfilename))
		{
                	print $file . " and " . $lastfilename . " are duplicates\n";
		}
	}
	$lastfilename = $file;
	$lastfilesize = $filelist{$file};
}
