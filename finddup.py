#!/usr/bin/python
import os
import sys

filelist = {}
lastfilesize = None
lastfilename = None

def sha1sum(file):
	import hashlib

	BLOCKSIZE = 65536
	hasher = hashlib.sha1()
	with open(file, 'rb') as afile:
		buf = afile.read(BLOCKSIZE)
		while len(buf) > 0:
			hasher.update(buf)
			buf = afile.read(BLOCKSIZE)
	
	return hasher.hexdigest()

def processdir(path, filelist):
	for filename in os.listdir(path):
		fullpath = os.path.join(path, filename)
		if os.path.isdir(fullpath):
			processdir(fullpath, filelist)
		elif os.path.isfile(fullpath):
			filelist[fullpath] = os.path.getsize(fullpath)

for directories in sys.argv[1:]:
	processdir(directories, filelist)

for filename, filesize in sorted(filelist.items(), key=lambda x:x[1]):
	if filesize == lastfilesize:
		if sha1sum(filename) == sha1sum(lastfilename):
			print str(filename) + " and " + str(lastfilename) + " are duplicates"

	lastfilename = filename
	lastfilesize = filesize
