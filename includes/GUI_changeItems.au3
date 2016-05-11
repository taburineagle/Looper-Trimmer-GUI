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
					If testEncoderPaths("tsMuxer") <> 0 Then ; if tsMuxeR is properly set up, then check the extensions
						$currentFileName = _GUICtrlListView_GetItemText($eventsList, $selectedItems[$a], 4)

						If StringInStr($currentFileName, "mts") <> 0 Or StringInStr($currentFileName, "m2ts") <> 0 Then
							_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
						Else
							$deniedAnyItems = True ; if ANY of the items selected aren't tsMuxeR-able, then display the setting error below
						EndIf
					Else ; if tsMuxeR isn't configured correctly, then display this error - once
						MsgBox(16, "tsMuxeR Path Error!", "tsMuxer is not properly set up - Looper Trimmer can not find the executable file (" & $tsMuxerPath & ") listed in the preferences.  Either the path is set incorrectly, or the executable for tsMuxeR has moved since you set the preferences up." & @CRLF & @CRLF & "Please reconfigure the tsMuxeR path in preferences and try again.")
						ExitLoop
					EndIf
			EndSwitch
		Next

		If $deniedAnyItems = True Then
			MsgBox(0, "tsMuxeR Setting Error", "Some of the files in the events list can't be processed by tsMuxer.  Looper Trimmer has support for mts and m2ts file trimming through tsMuxeR, and will only work on files with those extensions.")
		EndIf
	EndIf
EndFunc