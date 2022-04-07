<?php
$filelist = array();
$lastfilesize = -1;
$lastfilename = '';

function joinpath() {
    $paths = array();

    foreach (func_get_args() as $arg)
        if ($arg !== '')
		$paths[] = $arg;

    return preg_replace('#/+#','/',join('/', $paths));
}

function processdir($dir, &$filelist)
{
	if ($directoryhandler = opendir($dir))
		while ($file = readdir($directoryhandler))
			if (($file != '.') and ($file != '..'))
			{
				$fullpath = joinpath($dir, $file);
				if (is_file($fullpath) AND (!is_link($fullpath)))
					$filelist[$fullpath] = filesize($fullpath);
				elseif (is_dir($fullpath))
					// further down the rabbit hole you go
					processdir($fullpath, $filelist);
			}
	closedir($directoryhandler);
}

foreach (array_slice($argv,1) as $directory)
{
	if (is_dir($directory))
		processdir($directory, $filelist);
}

asort($filelist, SORT_NUMERIC);
foreach ($filelist as $filename => $filesize)
{
	// being the same size is a necessary, but not sufficient condition
	if ($filesize === $lastfilesize)
		if (sha1_file($filename) === sha1_file($lastfilename))
			echo $filename . " and " . $lastfilename . " are duplicates\n";

	$lastfilename = $filename;
	$lastfilesize = $filesize;
}
?>
