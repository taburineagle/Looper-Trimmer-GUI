Func handlesMenu_0()
	changeItems("0 seconds")
EndFunc

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

Func transcodeMenu_LosslessTS()
	changeItems("(tsM) Lossless to .m2ts")
EndFunc

Func transcodeMenu_Lossless()
	changeItems("(ff) Lossless Trim")
EndFunc

Func transcodeMenu_LosslessMKV()
	changeItems("(ff) Lossless to .mkv")
EndFunc

Func transcodeMenu_ProRes()
	changeItems("(ff) Transcode to ProRes")
EndFunc

Func changeItems($statusChange)
	$selectedItems = _GUICtrlListView_GetSelectedIndices($eventsList, true)
	$deniedAnyItems = False

	If IsArray($selectedItems) Then
		For $a = 1 to $selectedItems[0]
			Switch $statusChange
				Case "0 seconds", "1 second", "2 seconds", "3 seconds", "4 seconds", "5 seconds"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 3)
				Case "(ff) Lossless Trim", "(ff) Lossless to .mkv", "(ff) Transcode to ProRes"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
				Case "(tsM) Lossless to .m2ts"
					If testEncoderPaths("tsMuxer") <> 0 Then ; if tsMuxeR is properly set up, then check the extensions
						$currentFileName = _GUICtrlListView_GetItemText($eventsList, $selectedItems[$a], 4)

						If StringInStr($currentFileName, "mts") <> 0 Or StringInStr($currentFileName, "m2ts") <> 0 Then
							_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
						Else
							$deniedAnyItems = True ; if ANY of the items selected aren't tsMuxeR-able, then display the setting error below
						EndIf
					Else ; if tsMuxeR isn't configured correctly, then display this error - once
						If $tsMuxerPath <> "" Then
							MsgBox(16, "tsMuxeR Path Error!", "tsMuxer is not properly set up - Looper Trimmer can not find the executable file (" & $tsMuxerPath & ") listed in the preferences.  Either the path is set incorrectly, or the executable for tsMuxeR has moved since you set the preferences up." & @CRLF & @CRLF & "Please reconfigure the tsMuxeR path in preferences and try again.")
						Else
							MsgBox(16, "tsMuxeR Not Configured!", "tsMuxer is not properly configured yet.  To configure tsMuxeR, go to the preferences and find the tsMuxeR.exe file for your current tsMuxeR installation, save the preferences, and then try to change the transcode setting on this item again.")
						EndIf

						ExitLoop
					EndIf
			EndSwitch
		Next

		If $deniedAnyItems = True Then
			MsgBox(0, "tsMuxeR Setting Error", "Some of the files in the events list can't be processed by tsMuxer.  Looper Trimmer has support for mts and m2ts file trimming through tsMuxeR, and will only work on files with those extensions.")
		EndIf
	EndIf
EndFunc