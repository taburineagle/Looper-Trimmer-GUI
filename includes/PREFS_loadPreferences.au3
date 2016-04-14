Func loadPreferences()
	Opt("GUIOnEventMode", 0)
	GUISetState(@SW_DISABLE, $mainWindow) ; disable the main window when the prefs window is open

	$ffmpegPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", "")
	$tsMuxeRPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR", "")
	$hideEncoding = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 0)
	$newLooperDefault = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 1)
	$recycleDefault = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 0)
	$defaultHandles = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultHandles", "2 seconds")
	$defaultTrim = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultTrim", "Trim Losslessly (ffmpeg)")

	$prefsWindow = GUICreate("Looper Trimmer Preferences", 399, 295, -1, -1)

	$pathFFButton = GUICtrlCreateButton("...", 8, 10, 33, 25)
	$pathFFDesc = GUICtrlCreateLabel("Path to ffmpeg", 48, 8, 89, 19)
	$pathFFTF = GUICtrlCreateInput($ffmpegPath, 48, 26, 337, 23, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))

	$pathTSButton = GUICtrlCreateButton("...", 8, 50, 33, 25)
	$pathTSDesc = GUICtrlCreateLabel("Path to tsMuxeR (optional - useful for trimming AVCHD files)", 48, 56, 343, 19)
	$pathTSTF = GUICtrlCreateInput($tsMuxeRPath, 48, 74, 337, 23, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))

	$hideEncodingCheck = GUICtrlCreateCheckbox(" Hide ffmpeg/tsMuxeR encoding windows", 8, 96, 249, 25)

	If $hideEncoding = 1 Then
		GUICtrlSetState($hideEncodingCheck, $GUI_CHECKED)
	EndIf

	$defaultsDesc = GUICtrlCreateLabel("Defaults", 8, 132, 51, 19)

	$newLooperDefaultCheck = GUICtrlCreateCheckbox(" Create new Looper file with the trimmed events", 8, 152, 289, 25)
	$recycleDefaultCheck = GUICtrlCreateCheckbox(" Recycle the original media file(s) when trimming is done", 8, 176, 329, 25)

	If $newLooperDefault = 1 Then
		GUICtrlSetState($newLooperDefaultCheck, $GUI_CHECKED)
	EndIf

	If $recycleDefault = 1 Then
		GUICtrlSetState($recycleDefaultCheck, $GUI_CHECKED)
	EndIf

	$defaultHandlesList = GUICtrlCreateCombo("", 8, 212, 177, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
	$defaultHandlesDesc = GUICtrlCreateLabel("DEFAULT MEDIA HANDLES", 24, 236, 145, 17)

	$defaultTrimList = GUICtrlCreateCombo("", 192, 212, 193, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
	$defaultTrimDesc = GUICtrlCreateLabel("DEFAULT TRIM METHOD", 224, 236, 132, 17)

	$cancelButton = GUICtrlCreateButton("Cancel", 72, 262, 113, 25)
	$saveButton = GUICtrlCreateButton("Save Changes", 208, 262, 113, 25)

	#include "custom\GUI_prefsWindowCustom.au3" ; sets up the fonts and combo boxes

	_GUICtrlComboBox_SelectString($defaultHandlesList, $defaultHandles) ; select the current option for handles
	_GUICtrlComboBox_SelectString($defaultTrimList, $defaultTrim) ; select the current option for transcoding

	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()

		Switch $nMsg
			Case $pathFFButton
				$ffmpegPath = FileOpenDialog("Where is the ffmpeg executable file?", Default, "ffmpeg (ffmpeg.exe)", 1)

				If $ffmpegPath <> "" Then
					GUICtrlSetData($pathFFTF, $ffmpegPath)
				EndIf
			Case $pathTSButton
				$tsMuxeRPath = FileOpenDialog("Where is the tsMuxeR executable file?", Default, "tsMuxer (tsMuxeR.exe)", 1)

				If $tsMuxeRPath <> "" Then
					GUICtrlSetData($pathTSTF, $tsMuxeRPath)
				EndIf
			Case $saveButton
				If GUICtrlRead($pathFFTF) <> "" Then
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", GUICtrlRead($pathFFTF))
				Else
					IniDelete(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg")
				EndIf

				If GUICtrlRead($pathTSTF) <> "" Then
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR", GUICtrlRead($pathTSTF))
				Else
					IniDelete(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR")
				EndIf

				If GUICtrlRead($hideEncodingCheck) = 1 Then
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 1)
					$hideEncoding = 1
				Else
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 0)
					$hideEncoding = 0
				EndIf

				If GUICtrlRead($newLooperDefaultCheck) = 1 Then
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 1)
					GUICtrlSetState($newLooperRadio, $GUI_CHECKED)
				Else
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 0)
					GUICtrlSetState($newLooperRadio, $GUI_UNCHECKED)
				EndIf

				If GUICtrlRead($recycleDefaultCheck) = 1 Then
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 1)
					GUICtrlSetState($recycleMediaRadio, $GUI_CHECKED)
				Else
					IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 0)
					GUICtrlSetState($recycleMediaRadio, $GUI_UNCHECKED)
				EndIf

				IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultHandles", GUICtrlRead($defaultHandlesList))
				IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultTrim", GUICtrlRead($defaultTrimList))

				MsgBox(0, "Success!", "Your preferences have been saved.")
				GUIDelete($prefsWindow)
				ExitLoop
			Case $GUI_EVENT_CLOSE, $cancelButton
				GUIDelete($prefsWindow)
				ExitLoop
		EndSwitch
	WEnd

	Opt("GUIOnEventMode", 1)
	GUISetState(@SW_ENABLE, $mainWindow)
	WinActivate($mainWindow)
EndFunc
