Func createContextMenu()
	#cs
	- Check to see if the context menu came from the right (in fact, maybe it would make more sense
	if the menu only generated when you clicked the right button)
	
	- If you click the right button, generate the menu every single time?
	#ce
	
	If $menuCreated = True Then
		GUICtrlDelete($eventsListContextMenu)
		$menuCreated = False
	EndIf

	$currentlySelected = _GUICtrlListView_GetSelectedIndices($eventsList, 1)

	If $currentlySelected[0] <> 0 Then
		$eventsListContextMenu = GUICtrlCreateContextMenu($eventsList)

		$handlesMenu = GUICtrlCreateMenu("Media Handles", $eventsListContextMenu)
		$handlesMenu_0 = GUICtrlCreateMenuItem("0 seconds", $handlesMenu)
		$handlesMenu_1 = GUICtrlCreateMenuItem("1 second", $handlesMenu)
		$handlesMenu_2 = GUICtrlCreateMenuItem("2 seconds", $handlesMenu)
		$handlesMenu_3 = GUICtrlCreateMenuItem("3 seconds", $handlesMenu)
		$handlesMenu_4 = GUICtrlCreateMenuItem("4 seconds", $handlesMenu)
		$handlesMenu_5 = GUICtrlCreateMenuItem("5 seconds", $handlesMenu)

		$transcodeMenu = GUICtrlCreateMenu("Transcode Settings", $eventsListContextMenu)

		$isTSCapable = 0

		For $a = 1 to $currentlySelected[0]
			$currentFilename = _GUICtrlListView_GetItemText($eventsList, $currentlySelected[$a], 4)

			If StringInStr($currentFilename, "mts") <> 0 Or StringInStr($currentFilename, "m2ts") <> 0 Then
				$isTSCapable = 1
			EndIf
		Next

		If $isTSCapable = 1 Then
			$transcodeMenu_LosslessTS = GUICtrlCreateMenuItem("(tsMuxeR) Trim Losslessly (.m2ts)", $transcodeMenu)
			GUICtrlSetOnEvent($transcodeMenu_LosslessTS, "transcodeMenu_LosslessTS")
			GUICtrlCreateMenuItem("------------------", $transcodeMenu) ; seperator, not actually a menu item
		EndIf

		$transcodeMenu_Lossless = GUICtrlCreateMenuItem("(ffmpeg) Trim Losslessly (keep extension)", $transcodeMenu)
		$transcodeMenu_LosslessMKV = GUICtrlCreateMenuItem("(ffmpeg) Trim Losslessly (.mkv)", $transcodeMenu)
		$transcodeMenu_ProRes = GUICtrlCreateMenuItem("(ffmpeg) Transcode to ProRes (.mov)", $transcodeMenu)

		GUICtrlSetOnEvent($handlesMenu_0, "handlesMenu_0")
		GUICtrlSetOnEvent($handlesMenu_1, "handlesMenu_1")
		GUICtrlSetOnEvent($handlesMenu_2, "handlesMenu_2")
		GUICtrlSetOnEvent($handlesMenu_3, "handlesMenu_3")
		GUICtrlSetOnEvent($handlesMenu_4, "handlesMenu_4")
		GUICtrlSetOnEvent($handlesMenu_5, "handlesMenu_5")
		GUICtrlSetOnEvent($transcodeMenu_Lossless, "transcodeMenu_Lossless")
		GUICtrlSetOnEvent($transcodeMenu_LosslessMKV, "transcodeMenu_LosslessMKV")
		GUICtrlSetOnEvent($transcodeMenu_ProRes, "transcodeMenu_ProRes")

		$menuCreated = True
	EndIf
EndFunc
