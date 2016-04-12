Func loadLooper()
	$looperFile = FileOpenDialog("Where is the loop events file you want to trim?", @DesktopDir, "Loop Events File (*.looper)")

	If $looperFile <> "" Then
		_GUICtrlListView_DeleteAllItems($eventsList)

		$eventCount = _FileCountLines($looperFile)

		$currentLooperTFString = StringTrimLeft($looperFile, StringInStr($looperFile, "\", -1, -1))
		$currentLooperTFString = $currentLooperTFString & " (" & $eventCount & " events)"

		GUICtrlSetData($currentLooperTF, $currentLooperTFString)
		GUICtrlSetTip($currentLooperTF, $looperFile)

		$readingFile = FileOpen($looperFile)

		For $i = 1 to $eventCount
			$currentItem = FileReadLine($readingFile, $i)
			$currentItemArray = StringSplit($currentItem, "|")

			$newEvent = $currentItemArray[1] & "|" & $currentItemArray[2] & "|" & $currentItemArray[3]

			$defaultHandles = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultHandles", "2 seconds")
			$newEvent = $newEvent & "|" & $defaultHandles

			If FileExists($currentItemArray[4]) = 0 Then
				$currentItemArray[4] = findFile($looperFile, $currentItemArray[4])
			EndIf

			$newEvent = $newEvent & "|" & $currentItemArray[4]

			$defaultTrim = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultTrim", "Trim Losslessly (ffmpeg)")
			$newEvent = $newEvent & "|" & $defaultTrim

			$newEvent = $newEvent & "|" & ""

			GUICtrlCreateListViewItem($newEvent, $eventsList)
		Next

		FileClose($readingFile)
	EndIf
EndFunc