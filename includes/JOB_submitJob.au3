Func submitJob()
	$totalCount = _GUICtrlListView_GetItemCount($eventsList)

	For $i = 0 to $totalCount - 1
		_GUICtrlListView_SetItem($eventsList, "Waiting to trim...", $i, 6)
	Next

	For $i = 0 to $totalCount - 1
		If $isWorking = 1 Then
			_GUICtrlListView_EnsureVisible($eventsList, $i, True)

			$currentJobName = _GUICtrlListView_GetItemText($eventsList, $i, 0)
			$currentJobINPoint = _GUICtrlListView_GetItemText($eventsList, $i, 1)
			$currentJobOUTPoint =  _GUICtrlListView_GetItemText($eventsList, $i, 2)
			$currentJobHandles = _GUICtrlListView_GetItemText($eventsList, $i, 3)
			$currentJobSourcefile = _GUICtrlListView_GetItemText($eventsList, $i, 4)
			$currentJobTranscode = _GUICtrlListView_GetItemText($eventsList, $i, 5)

			$adjustedEditPoints = getAdjustedEditPoints($currentJobINPoint, $currentJobOUTPoint, $currentJobHandles)

			_GUICtrlListView_SetItem($eventsList, "Trimming...", $i, 6)

			If $currentJobTranscode = "Trim Losslessly (ffmpeg)" Then
				$destFile = findDestFile(GUICtrlRead($destTF), $currentJobSourcefile, -1, $i)

				If $destFile[0] = 1 Then
					ffmpegJob($currentJobSourcefile, $destFile[1], $adjustedEditPoints[0], $adjustedEditPoints[1], $currentJobTranscode)
				EndIf
			ElseIf $currentJobTranscode = "Transcode to ProRes" Then
				$destFile = findDestFile(GUICtrlRead($destTF), $currentJobSourcefile, ".mov", $i)

				If $destFile[0] = 1 Then
					ffmpegJob($currentJobSourcefile, $destFile[1], $adjustedEditPoints[0], $adjustedEditPoints[1], $currentJobTranscode)
				EndIf
			ElseIf $currentJobTranscode = "Trim Losslessly (tsMuxeR)" Then
				$destFile = findDestFile(GUICtrlRead($destTF), $currentJobSourcefile, ".m2ts", $i)

				If $destFile[0] = 1 Then
					tsMuxeRJob($currentJobSourcefile, $destFile[1], $adjustedEditPoints[0], $adjustedEditPoints[1])
				EndIf

				;$destFile = tsMuxerJob($currentJobSourcefile, $adjustedEditPoints[0], $adjustedEditPoints[1], GUICtrlRead($destTF), $currentJobTranscode, $i)
			EndIf

			If GUICtrlRead($newLooperRadio) = 1 Then
				_GUICtrlListView_SetItem($eventsList, "Adding event to new file...", $i, 6)

				$newLooper = GUICtrlRead($destTF) & "\Trimmed.looper"
				$writingFile = FileOpen($newLooper, 35)

				$writingLine = $currentJobName

				If $adjustedEditPoints[0] = "0:00" Then
					$writingLine = $writingLine & "|" & $currentJobINPoint
					$writingLine = $writingLine & "|" & $currentJobOUTPoint
				Else
					$writingLine = $writingLine & "|" & NumberToTimeString($currentJobHandles)
					$writingLine = $writingLine & "|" & NumberToTimeString(TimeStringToNumber($currentJobOUTPoint) - TimeStringToNumber($currentJobINPoint) + $currentJobHandles)
				EndIf

				$writingLine = $writingLine & "|" & $destFile[1]

				FileWriteLine($writingFile, $writingLine)
				FileClose($writingFile)
			EndIf

			_GUICtrlListView_SetItem($eventsList, "Done", $i, 6)
		Else
			ExitLoop
		EndIf
	Next

	If GUICtrlRead($recycleMediaRadio) = 1 Then
		deleteFiles()
	EndIf

	$isWorking = 0
	GUICtrlSetData($submitButton, "Submit Job")
EndFunc