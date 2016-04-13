Func tsMuxeRJob($sourceFile, $destFile, $inPoint, $outPoint)
	$adjustOffset = 80; 1066 ; small amount of offset for tsMuxeR clippings, they tend to be off by this many milliseconds when trimming

	$inPoint = TimeStringToNumber($inPoint) * 1000 - $adjustOffset ; convert looper IN file to milliseconds for tsMuxer
	$outPoint = TimeStringToNumber($outPoint) * 1000 - $adjustOffset ; convert looper OUT file to milliseconds for tsMuxer

	$metaText = 'MUXOPT --no-pcr-on-video-pid --new-audio-pes --vbr  --cut-start=' & $inPoint & 'ms --cut-end=' & $outPoint & 'ms --vbv-len=500'
	$metaText = $metaText & @CRLF & 'V_MPEG4/ISO/AVC, "' & $sourceFile & '"' & ', insertSEI, contSPS, track=4113'
	$metaText = $metaText & @CRLF & 'A_AC3, "' & $sourceFile & '"' & ', track=4352'
	$metaText = $metaText & @CRLF & 'S_HDMV/PGS, "' & $sourceFile & '"' & ', track=4608'

	$writingFile = FileOpen(@TempDir & "\Trimmer.meta", 2)
	FileWrite($writingFile, $metaText)
	FileClose($writingFile)

	If $hideEncoding = 1 Then
		$thePID = ShellExecute($tsMuxeRPath, @TempDir & '\Trimmer.meta "' & $destFile & '"', Default, Default, @SW_HIDE)
	Else
		$thePID = ShellExecute($tsMuxeRPath, @TempDir & '\Trimmer.meta "' & $destFile & '"')
	EndIf

	WinActivate($mainWindow)
	ProcessWaitClose($thePID)

	FileDelete(@TempDir & "\Trimmer.meta") ; delete the temporary .meta file tsMuxeR needs to use for processing
EndFunc