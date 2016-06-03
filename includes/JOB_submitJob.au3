Func submitJob()
	$totalCount = _GUICtrlListView_GetItemCount($eventsList)

	$startingItem = 0
	$alreadyCompleted = 0

	For $a = 0 to $totalCount - 1
		If _GUICtrlListView_GetItemText($eventsList, $a, 6) = "Job cancelled" Then
			$doPartialJob = MsgBox(36, "Process a partial job?", 'You have items in your queue that were cancelled during an earlier job.  Would you like to process just the cancelled items, or restart the entire job?' & @CRLF & @CRLF & 'Click "Yes" below to only process the items you cancelled previously, and click "No" to start from job again from the beginning.')

			If $doPartialJob = 6 Then ; You clicked "Yes"
				$startingItem = $a ; Start at the first found non-processed item
			Else
				; Do nothing, the $startingItem is already set to 0
			EndIf

			ExitLoop ; Exit this search and go on with it!
		ElseIf _GUICtrlListView_GetItemText($eventsList, $a, 6) = "Done" Then
			$alreadyCompleted = $alreadyCompleted + 1
		EndIf
	Next

	If $alreadyCompleted = $totalCount Then
		$resubmitJob = MsgBox(36, "Re-submit job?", "It looks like you've already completed this job.  Would you like to re-submit it?" & @CRLF & @CRLF & 'Click "Yes" below to re-submit this job and click "No" to cancel.')

		If $resubmitJob = 7 Then ; You clicked "No"
			$startingItem = $totalCount + 1 ; set $startingItem to one position higher than the repeat loop, cancelling the job
		Else
			If FileExists(GUICtrlRead($destTF) & "\Trimmed.looper") Then ; if the .looper file exists from the job before it
				$writingFile = FileOpen(GUICtrlRead($destTF) & "\Trimmed.looper", 34) ; erase the contents, because it's now a clean slate!
				FileClose($writingFile) ; and close it
			EndIf

			; Do this tango one more time!
		EndIf
	EndIf

	$alreadyCompleted = $startingItem ; re-initialize $alreadyCompleted with the count of items that are done (as you just re-submitted the job)

	For $i = $startingItem to $totalCount - 1
		_GUICtrlListView_SetItem($eventsList, "Waiting to trim...", $i, 6) ; show the items are ready for processing
	Next

	For $i = $startingItem to $totalCount - 1
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
			EndIf

			If GUICtrlRead($newLooperRadio) = 1 Then
				_GUICtrlListView_SetItem($eventsList, "Adding event to new file...", $i, 6)

				$newLooper = GUICtrlRead($destTF) & "\Trimmed.looper"
				$writingFile = FileOpen($newLooper, 33)

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

			$alreadyCompleted = $alreadyCompleted + 1 ; add one to the counter, this is for checking if the whole job completed (and you can delete)
			_GUICtrlListView_SetItem($eventsList, "Done", $i, 6)
		Else
			_GUICtrlListView_SetItem($eventsList, "Job cancelled", $i, 6) ; set the rest of the items to "Job cancelled" if you click cancel
		EndIf
	Next

	If $alreadyCompleted = $totalCount Then ; if you've run completely through the list and completed the job
		If GUICtrlRead($recycleMediaRadio) = 1 Then ; and you want to delete the original source files
			deleteFiles() ; do that!
		EndIf
	EndIf

	$isWorking = 0 ; no longer working
	GUICtrlSetData($submitButton, "Submit Job") ; set the button to the initial state to do it all again
EndFunc