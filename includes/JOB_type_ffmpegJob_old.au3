Func ffmpegJob($sourceFile, $destFile, $inPoint, $outPoint, $transcodeMethod)
	$params = '-i "' & $sourceFile & '" '

	If $inPoint <> "0:00" Then
		$params = $params & '-ss ' & $inPoint & ' '
	EndIf

	$params = $params & '-to ' & $outPoint & ' '

	If $transcodeMethod = "Transcode to ProRes" Then
		$params = $params & ' -c:v prores -c:a pcm_s16le '
	Else
		$params = $params & ' -c copy '
	EndIf

	$params = $params & '"' & $destFile & '"'

	If $hideEncoding = 1 Then
		$thePID = ShellExecute($ffmpegPath, $params, Default, Default, @SW_HIDE)
	Else
		$thePID = ShellExecute($ffmpegPath, $params)
	EndIf

	WinActivate($mainWindow)
	ProcessWaitClose($thePID)
EndFunc