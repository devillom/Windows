
#cs
mp.au3 (multi-process)
-John Taylor
Apr-30-2012

Documentation
-------------
mp will run a (command line) program in parallel on a group of similar files.
I have tested this with 2 CPU and 16 CPU systems.

cmd-line arguments:

1) the program executable to run in parallel
2) pattern, in double quotes
	a) _input_    the filename plus extension matched by the wildcard file patterns
	b) _base_     the filename without the extension
	c) _ext_      only the file's extension without a leading dot
3) wildcard file pattern #1
4) wildcard file pattern #2
5) wildcard file pattern etc.

icon used: http://www.iconarchive.com/show/angry-birds-icons-by-fasticon/red-bird-icon.html

Examples
---------
mp.exe "C:\Program Files\ImageMagick\convert.exe" "_input_ _base_.tiff" *.png
This will convert all PNG files to tiff files, which will have the same base name

mp.exe bzip2 "-9 _input_" a*.txt
This will compress all text files starting with "a"

To do
-----
1) error checking
2) have a status for the tray icon, # of jobs completed & remaining
3) save output of each command

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#ce


Opt("MustDeclareVars",1)
#include <File.au3>
#include <Array.au3>

; number of `threads' to use
global $cpu_count = EnvGet("NUMBER_OF_PROCESSORS")

; two dimensional array, first col=number of CPUs, second col=list of file to be processed on that CPU
; the second column will be ReDim'd
global $flist[$cpu_count][1]

; number of files in each of the $flist[$x] vectors
global $flist_count[$cpu_count]

; currently running PID on a given CPU
global $pid[$cpu_count]

; number of jobs that have been processed on a given CPU (as not to exceed $flist_count[cpu])
global $job[$cpu_count]

; the acutal command to be run
global $exe

; cmd line file replacement pattern
global $pattern

; total number of jobs send to the Run() function
global $finished = 0

func create_file_lists()
	local $i, $curr, $count
	local $all[1]
	$all[0] = 0

	$count = 0
	for $i = 3 to $CmdLine[0] ; start at 3 b/c 1=exe 2=replacement-pattern 3,4,5,etc=filenames
		;MsgBox(0,$i,$CmdLine[$i])
		$curr = _FileListToArray(".", $CmdLine[$i], 1)
		$count += $curr[0]
		$all[0] = $count
		;_ArrayDisplay($curr)
		_ArrayConcatenate($all,$curr,1)
	next

	_ArrayDelete($all,0)
	$all = _ArrayUnique($all,1)
	;_ArrayDisplay($all)
	
	return $all
endfunc

func multiprocess()
	global $cpu_count, $exe, $pattern, $finished
	global $flist, $flist_count, $pid, $job
	local $i, $curr, $args, $mypattern
	local $input, $base, $ext
	local $szDrive, $szDir, $base, $ext
	local $cmd

	for $i = 0 to $cpu_count-1
		if not ProcessExists( $pid[$i] ) then
			if int($job[$i]) < int($flist_count[$i]) then
				$args = $flist[$i][$job[$i]]
				$input = $flist[$i][$job[$i]]
				_PathSplit($input, $szDrive, $szDir, $base, $ext)
				$ext = StringMid($ext,2)

				$mypattern = $pattern
				$mypattern = StringReplace($mypattern,"_input_", $input)
				$mypattern = StringReplace($mypattern,"_base_", $base)
				$mypattern = StringReplace($mypattern,"_ext_", $ext)

				$cmd = $exe & " " & $mypattern
				;MsgBox(0,"cmd", $cmd)
				$curr = Run($cmd, "", @SW_HIDE)
				$finished += 1
				$job[$i] += 1
				$pid[$i] = $curr
			endif
		endif
	next
endfunc
	

func main()
	global $flist, $cpu_count, $pid, $exe, $finished
	local $all_flist, $item
	if ( $CmdLine[0] < 3 ) then
		MsgBox(0,"Usage",@ScriptName & "[ command executable ] [ pattern ] [ file mask 1] [ file mask 2] ...")
		exit
	endif

	TrayCreateItem("")
	TraySetState()

	$all_flist = create_file_lists()
	
	for $i = 0 to $cpu_count-1
		ReDim $flist[ubound($flist,1)][(ubound($all_flist) / $cpu_count) + 1]
		$flist_count[$i] = 0
		$pid[$i] = -1
		$job[$i] = 0
	next

	local $i = 0
	local $j = 0
	while ubound($all_flist) > 1
		$item = _ArrayPop($all_flist)
		;MsgBox(0,$i,$item)
		$j=$flist_count[$i]
		;Msgbox(0,"index", $i & " " & $j)
		$flist[$i][$j] = $item
		$flist_count[$i] += 1
		$i += 1
		if $i == $cpu_count then
			$i = 0
		endif
	wend
	;_ArrayDisplay($flist)
	
	$exe = $CmdLine[1]
	$pattern = $CmdLine[2]

	do
		multiprocess()
		sleep(250)
	until $finished = $all_flist[0]

	;MsgBox(0,"Finished", $finished & " jobs completed.")
endfunc

main()

