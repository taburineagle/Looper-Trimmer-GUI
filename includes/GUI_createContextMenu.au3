Func createContextMenu()
	#cs
	--------------================== STUFF A DO!!!!! ==================--------------
	
	- Check to see if the context menu came from the right (in fact, maybe it would make more sense
	if the menu only generated when you clicked the right button)
		- Check the selection
		- Make the menu (including the .m2ts selections)
		- Display the menu
		- Re-select the correct positions in the list
			- It would be amazingly awesome not to need to do this step!
		- Delete the menu
		- Set $menuCreated to False (or don't use a Global for that variable, only use it in this function?
	
	- If you click the right button, generate the menu every single time?
	
	- Create the menu on right click, and then immediately destroy it when the selection is made?
	
	- Maybe eliminate $menuCreated global - but leave it in to trigger the menu itself...?
		- If $menuCreated is true then go along with showing the menu
		- Then re-select the correct items (or maybe just disable the list view altogether when the menu is up?)
			- Will re-selecting the items work for all of the selections, or will it screw up after a few of them?
			
	--------------================== STUFF A DO!!!!! ==================--------------
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
