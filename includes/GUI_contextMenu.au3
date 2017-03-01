GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")
GUIRegisterMsg($WM_CONTEXTMENU, "WM_CONTEXTMENU")

; Handle WM_CONTEXTMENU messages
Func WM_CONTEXTMENU($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg, $lParam

	$currentlySelected = _GUICtrlListView_GetSelectedIndices($eventsList, 1)

	If $currentlySelected[0] <> 0 Then
		Local $handlesMenu, $transcodeMenu, $contextMenu

		$handlesMenu = _GUICtrlMenu_CreateMenu() ; create the "Handles" sub menu
		_GUICtrlMenu_AddMenuItem($handlesMenu, "0 seconds", $handlesMenu_0)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "1 second", $handlesMenu_1)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "2 seconds", $handlesMenu_2)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "3 seconds", $handlesMenu_3)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "4 seconds", $handlesMenu_4)
		_GUICtrlMenu_AddMenuItem($handlesMenu, "5 seconds", $handlesMenu_5)

		$transcodeMenu = _GUICtrlMenu_CreateMenu() ; create the "Transcoding" sub menu
		
		$isTSCapable = isSelectionTSCapable($currentlySelected) ; find if .mts or .m2ts exists in current selection
		
		If $isTSCapable = True Then ; if there is a .m2ts or .mts selection in the list, then give tsMuxeR options
			_GUICtrlMenu_AddMenuItem($transcodeMenu, "(tsMuxeR) Trim Losslessly (.m2ts)", $transcodeMenu_LosslessTS)
			_GUICtrlMenu_AddMenuItem($transcodeMenu, "", 0)
		EndIf
		
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Trim Losslessly (keep extension)", $transcodeMenu_Lossless)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Trim Losslessly (.mkv)", $transcodeMenu_LosslessMKV)
		_GUICtrlMenu_AddMenuItem($transcodeMenu, "(ffmpeg) Transcode to ProRes (.mov)", $transcodeMenu_ProRes)

		$contextMenu = _GUICtrlMenu_CreatePopup() ; create the main pop-up menu and add the 2 submenus to it
		_GUICtrlMenu_AddMenuItem($contextMenu, "Media Handles", 0, $handlesMenu)
		_GUICtrlMenu_AddMenuItem($contextMenu, "Transcode Settings", 0, $transcodeMenu)

		_GUICtrlMenu_TrackPopupMenu($contextMenu, $mainWindow) ; show the pop-up menu and get a selection
		_GUICtrlMenu_DestroyMenu($contextMenu) ; delete the pop-up menu on exiting it
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

Func isSelectionTSCapable($currentlySelected)
	$isTSCapable = False ; set to False by default

	For $a = 1 to $currentlySelected[0]
		$currentFilename = _GUICtrlListView_GetItemText($eventsList, $currentlySelected[$a], 4)

		If StringInStr($currentFilename, "mts") <> 0 Or StringInStr($currentFilename, "m2ts") <> 0 Then
			$isTSCapable = True ; if a filename in the list has .mts or .m2ts extensions, then set $isTSCapable to True
		EndIf
	Next
	
	Return $isTSCapable
EndFunc
