Func ffmpegJob($sourceFile, $destFile, $inPoint, $outPoint, $transcodeMethod)
	; if $inPoint is less than 10 seconds, do it the old way
	; otherwise, seek from IN point to ($inPoint - 10 seconds)
	; get the total length of the event ($outPoint - [above])
	; and use 0:10 as the in point, use the thing above, plus 10 seconds as the out - so...

	; 1:25:10 is the IN
	; 1:55:10 is the out
	; seek 1:15:10 from the source side (fast)
	; make the IN 0:10
	; make the OUT (out) - (in - 10 seconds), so 1:55:10 - 1:25:10 = 30 seconds + 10 = 40 seconds

	If $inPoint = "0:00" Then
		$params = '-i "' & $sourceFile & '" -to ' & $outPoint & ' ' ; Source for file goes before seeking, but no IN point
	Else ; if it's not 0:00 then
		If Int(TimeStringToNumber($inPoint)) < 10 Then
			$params = '-i "' & $sourceFile & '" -ss ' & $inPoint & ' -to ' & $outPoint & ' '
		Else
			$newOutPoint = Number(TimeStringToNumber($outPoint)) - Number(TimeStringToNumber($inPoint)) + 10
			$newInPoint = Number(TimeStringToNumber($inPoint)) - 10

			$params = '-ss ' & NumberToTimeString($newInPoint) & ' -i "' & $sourceFile & '" -ss 0:10 -to ' &  NumberToTimeString($newOutPoint) & ' '
		EndIf
	EndIf

	If $transcodeMethod = "(ff) Transcode to ProRes" Then
		$params = $params & ' -c:v prores -c:a pcm_s16le '
	Else
		$params = $params & ' -c copy '
	EndIf

	$params = $params & '"' & $destFile & '"'

	If $hideEncoding = 1 Then
		$thePID = ShellExecute($ffmpegPath, $params, Default, Default, @SW_SHOWMINNOACTIVE)
	Else
		$thePID = ShellExecute($ffmpegPath, $params, Default, Default, @SW_SHOWNOACTIVATE)
	EndIf

	;WinActivate($mainWindow)
	ProcessWaitClose($thePID)
EndFunc