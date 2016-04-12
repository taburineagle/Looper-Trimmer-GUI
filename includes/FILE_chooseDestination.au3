Func chooseDestination()
	$exportFolder = FileSelectFolder("Where do you want to save the trimmed loop files?", @DesktopDir, 1)

	If $exportFolder <> "" Then
		If StringRight($exportFolder, 1) <> "\" Then
			$exportFolder = $exportFolder & "\"
		EndIf

		GUICtrlSetData($destTF, $exportFolder)
	EndIf
EndFunc