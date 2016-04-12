Func handlesMenu_1()
	changeItems("1 second")
EndFunc

Func handlesMenu_2()
	changeItems("2 seconds")
EndFunc

Func handlesMenu_3()
	changeItems("3 seconds")
EndFunc

Func handlesMenu_4()
	changeItems("4 seconds")
EndFunc

Func handlesMenu_5()
	changeItems("5 seconds")
EndFunc

Func transcodeMenu_Lossless()
	changeItems("Trim Losslessly (ffmpeg)")
EndFunc

Func transcodeMenu_LosslessTS()
	changeItems("Trim Losslessly (tsMuxeR)")
EndFunc

Func transcodeMenu_ProRes()
	changeItems("Transcode to ProRes")
EndFunc

Func changeItems($statusChange)
	$selectedItems = _GUICtrlListView_GetSelectedIndices($eventsList, true)
	$deniedAnyItems = False

	If IsArray($selectedItems) Then
		For $a = 1 to $selectedItems[0]
			Switch $statusChange
				Case "1 second", "2 seconds", "3 seconds", "4 seconds", "5 seconds"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 3)
				Case "Trim Losslessly (ffmpeg)", "Transcode to ProRes"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
				Case "Trim Losslessly (tsMuxeR)"
					$currentFileName = _GUICtrlListView_GetItemText($eventsList, $selectedItems[$a], 4)

					If StringInStr($currentFileName, "mts") <> 0 Or StringInStr($currentFileName, "m2ts") <> 0 Then
						_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
					Else
						$deniedAnyItems = True
					EndIf
			EndSwitch
		Next

		If $deniedAnyItems = True Then
			MsgBox(0, "tsMuxeR Setting Error", "Some of the files in the events list can't be processed by tsMuxer.")
		EndIf
	EndIf
EndFunc