Func deleteFiles()
	$itemCount = _GUICtrlListView_GetItemCount($eventsList)
	Local $fileDeleteArray[0]

	For $i = 0 to $itemCount - 1
		$currentItem = _GUICtrlListView_GetItemText($eventsList, $i, 4)

		If $currentItem <> "ERROR: File for this event not found" Then
			_ArrayAdd($fileDeleteArray, $currentItem)
		EndIf
	Next

	$fileDeleteArray = _ArrayUnique($fileDeleteArray)
	$deleteFiles = 0

	If IsArray($fileDeleteArray) Then ; if there aren't any items in it, then it isn't an array
		If $fileDeleteArray[0] = 1 Then
			$deleteFiles = MsgBox(52, "Recycle source file?", "This looper file consists of 1 unique source file.  Are you sure you want to recycle the original file?" & @CRLF & @CRLF & "NOTE: Please make sure to test the new files created by the trimming procedure *first* before deleting any source files, to ensure everything plays smoothly.")
		Else
			$deleteFiles = MsgBox(52, "Recycle source files?", "This looper file consists of " & $fileDeleteArray[0] & " unique source file(s).  Are you sure you want to recycle the original files?" & @CRLF & @CRLF & "NOTE: Please make sure to test the new files created by the trimming procedure *first* before deleting any source files, to ensure everything plays smoothly.")
		EndIf
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
	ElseIf $deleteFiles = 7 Then
		MsgBox(64, "Files not recycled", "You chose not to delete the original source files.")
	Else
		MsgBox(64, "No source files to delete", "The current .looper file has no source files to delete (usually this happens when a .looper file referenced files that were previously deleted.)  So no files were sent to the recycle bin.")
	EndIf
EndFunc