Func deleteFiles()
	$itemCount = _GUICtrlListView_GetItemCount($eventsList)
	Local $fileDeleteArray[$itemCount]

	For $i = 0 to $itemCount - 1
		$fileDeleteArray[$i] = _GUICtrlListView_GetItemText($eventsList, $i, 4)
	Next

	$fileDeleteArray = _ArrayUnique($fileDeleteArray)

	If $fileDeleteArray[0] = 1 Then
		$deleteFiles = MsgBox(52, "Recycle source file?", "This looper file consists of 1 unique source file.  Are you sure you want to recycle the original file?" & @CRLF & @CRLF & "NOTE: Please make sure to test the new files created by the trimming procedure *first* before deleting any source files, to ensure everything plays smoothly.")
	Else
		$deleteFiles = MsgBox(52, "Recycle source files?", "This looper file consists of " & $fileDeleteArray[0] & " unique source file(s).  Are you sure you want to recycle the original files?" & @CRLF & @CRLF & "NOTE: Please make sure to test the new files created by the trimming procedure *first* before deleting any source files, to ensure everything plays smoothly.")
	EndIf

	If $deleteFiles = 6 Then
		For $i = 1 to $fileDeleteArray[0]
			If $fileDeleteArray[$i] <> "ERROR: File for this event not found" And $fileDeleteArray[$i] <> " <source file recycled>" Then
				FileRecycle($fileDeleteArray[$i]) ; if the path is valid, then recycle the file
			EndIf
		Next

		If $fileDeleteArray[0] = 1 Then
			MsgBox(64, "File recycled", "1 original source file was sent to the recycle bin.")
		Else
			MsgBox(64, "Files recycled", $fileDeleteArray[0] & " original source files were sent to the recycle bin.")
		EndIf

		For $i = 0 to $itemCount
			_GUICtrlListView_SetItemText($eventsList, $i, " <source file recycled>", 4)
		Next

		$disableSubmit = True ; disable submitting a new job if everything's goone!
	Else
		MsgBox(64, "Files not recycled", "You chose not to delete the original source files.")
	EndIf
EndFunc