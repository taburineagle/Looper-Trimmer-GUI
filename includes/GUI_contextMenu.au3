GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")

; Handle WM_CONTEXTMENU messages
Func WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $lParam

	$currentlySelected = _GUICtrlListView_GetSelectedIndices($eventsList, 1)

	If $currentlySelected[0] <> 0 Then
		Local $handlesMenu, $transcodeMenu, $contextMenu

		$handlesMenu = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_AddMenuItem($handlesMenu, "0 seconds", $handlesMenu_0)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "1 second", $handlesMenu_1)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "2 seconds", $handlesMenu_2)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "3 seconds", $handlesMenu_3)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "4 seconds", $handlesMenu_4)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "5 seconds", $handlesMenu_5)

		$transcodeMenu = _GUICtrlMenu_CreateMenu()
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(tsMuxeR) Trim Losslessly (.m2ts)", $transcodeMenu_LosslessTS)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "", 0)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Trim Losslessly (keep extension)", $transcodeMenu_Lossless)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Trim Losslessly (.mkv)", $transcodeMenu_LosslessMKV)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Transcode to ProRes (.mov)", $transcodeMenu_ProRes)

		$contextMenu = _GUICtrlMenu_CreatePopup()
		_GUICtrlMenu_AddMenuItem($contextMenu, "Media Handles", 0, $handlesMenu)
		_GUICtrlMenu_AddMenuItem($contextMenu, "Transcode Settings", 0, $transcodeMenu)

		_GUICtrlMenu_TrackPopupMenu($contextMenu, $mainWindow)
		_GUICtrlMenu_DestroyMenu($contextMenu)
	EndIf

	Return True
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $lParam

    Switch $wParam
		Case $handlesMenu_0
			changeItems("0 seconds")
		Case $handlesMenu_1
			changeItems("1 second")
		Case $handlesMenu_2
			changeItems("2 seconds")
		Case $handlesMenu_3
			changeItems("3 seconds")
		Case $handlesMenu_4
			changeItems("4 seconds")
		Case $handlesMenu_5
			changeItems("5 seconds")
		Case $transcodeMenu_LosslessTS
			changeItems("(tsM) Lossless to .m2ts")
		Case $transcodeMenu_Lossless
			changeItems("(ff) Lossless Trim")
		Case $transcodeMenu_LosslessMKV
			changeItems("(ff) Lossless to .mkv")
		Case $transcodeMenu_ProRes
			changeItems("(ff) Transcode to ProRes")
	EndSwitch
EndFunc