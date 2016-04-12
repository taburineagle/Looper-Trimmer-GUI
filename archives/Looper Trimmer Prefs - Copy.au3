#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>

$prefsWindow = GUICreate("Looper Trimmer Preferences", 399, 295, 204, 139)

$ffmpegPath = IniRead("LooperTrimmer.ini", "Paths", "ffmpeg", "")
$tsMuxeRPath = IniRead("LooperTrimmer.ini", "Paths", "tsMuxeR", "")
$ffmpegHide = IniRead("LooperTrimmer.ini", "Defaults", "hideEncoding", 0)
$newLooperDefault = IniRead("LooperTrimmer.ini", "Defaults", "newLooper", 1)
$recycleDefault = IniRead("LooperTrimmer.ini", "Defaults", "recycleOriginals", 0)
$defaultHandles = IniRead("LooperTrimmer.ini", "Defaults", "defaultHandles", 2)
$defaultTrim = IniRead("LooperTrimmer.ini", "Defaults", "defaultTrim", "Trim Losslessly (ffmpeg)")

$pathFFButton = GUICtrlCreateButton("...", 8, 10, 33, 25)
GUICtrlSetFont(-1, 10, 800, 0, "Segoe UI")
$pathFFDesc = GUICtrlCreateLabel("Path to ffmpeg", 48, 8, 89, 19)
GUICtrlSetFont(-1, 9, 800, 0, "Segoe UI")
$pathFFTF = GUICtrlCreateInput($ffmpegPath, 48, 26, 337, 23, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

$pathTSButton = GUICtrlCreateButton("...", 8, 50, 33, 25)
GUICtrlSetFont(-1, 10, 800, 0, "Segoe UI")
$pathTSDesc = GUICtrlCreateLabel("Path to tsMuxeR (optional - useful for trimming AVCHD files)", 48, 56, 343, 19)
GUICtrlSetFont(-1, 9, 800, 0, "Segoe UI")
$pathTSTF = GUICtrlCreateInput($tsMuxeRPath, 48, 74, 337, 23, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

$ffmpegHideCheck = GUICtrlCreateCheckbox(" Hide ffmpeg/tsMuxeR encoding windows", 8, 96, 249, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

If $ffmpegHide = 1 Then
	GUICtrlSetState($ffmpegHideCheck, $GUI_CHECKED)
EndIf

$defaultsDesc = GUICtrlCreateLabel("Defaults", 8, 132, 51, 19)
GUICtrlSetFont(-1, 9, 800, 0, "Segoe UI")

$newLooperDefaultCheck = GUICtrlCreateCheckbox(" Create new Looper file with the trimmed events", 8, 152, 289, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

If $newLooperDefault = 1 Then
	GUICtrlSetState($newLooperDefaultCheck, $GUI_CHECKED)
EndIf

$recycleDefaultCheck = GUICtrlCreateCheckbox(" Recycle the original media file(s) when trimming is done", 8, 176, 329, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

If $recycleDefault = 1 Then
	GUICtrlSetState($recycleDefaultCheck, $GUI_CHECKED)
EndIf

$defaultHandlesList = GUICtrlCreateCombo("", 8, 212, 177, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "1 second|2 seconds|3 seconds|4 seconds|5 seconds")
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

_GUICtrlComboBox_SelectString($defaultHandlesList, $defaultHandles)

$defaultHandlesDesc = GUICtrlCreateLabel("DEFAULT MEDIA HANDLES", 24, 236, 145, 17)
GUICtrlSetFont(-1, 8, 800, 0, "Segoe UI")

$defaultTrimList = GUICtrlCreateCombo("", 192, 212, 193, 25, BitOR($CBS_DROPDOWNLIST,$CBS_AUTOHSCROLL))
GUICtrlSetData(-1, "Trim Losslessly (ffmpeg)|Trim Losslessly (tsMuxeR)|Transcode to ProRes")
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

_GUICtrlComboBox_SelectString($defaultTrimList, $defaultTrim)

$defaultTrimDesc = GUICtrlCreateLabel("DEFAULT TRIM METHOD", 224, 236, 132, 17)
GUICtrlSetFont(-1, 8, 800, 0, "Segoe UI")

$cancelButton = GUICtrlCreateButton("Cancel", 72, 262, 113, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
$saveButton = GUICtrlCreateButton("Save Changes", 208, 262, 113, 25)
GUICtrlSetFont(-1, 9, 800, 0, "Segoe UI")

GUISetState(@SW_SHOW)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $saveButton
			If GUICtrlRead($pathFFTF) <> "" Then
				IniWrite("LooperTrimmer.ini", "Paths", "ffmpeg", GUICtrlRead($pathFFTF))
			Else
				IniDelete("LooperTrimmer.ini", "Paths", "ffmpeg")
			EndIf

			If GUICtrlRead($pathTSTF) <> "" Then
				IniWrite("LooperTrimmer.ini", "Paths", "tsMuxeR", GUICtrlRead($pathTSTF))
			Else
				IniDelete("LooperTrimmer.ini", "Paths", "tsMuxeR")
			EndIf

			If GUICtrlRead($ffmpegHideCheck) = 1 Then
				IniWrite("LooperTrimmer.ini", "Defaults", "hideEncoding", 1)
			Else
				IniWrite("LooperTrimmer.ini", "Defaults", "hideEncoding", 0)
			EndIf


			If GUICtrlRead($newLooperDefaultCheck) = 1 Then
				IniWrite("LooperTrimmer.ini", "Defaults", "newLooper", 1)
			Else
				IniWrite("LooperTrimmer.ini", "Defaults", "newLooper", 0)
			EndIf

			If GUICtrlRead($recycleDefaultCheck) = 1 Then
				IniWrite("LooperTrimmer.ini", "Defaults", "recycleOriginals", 1)
			Else
				IniWrite("LooperTrimmer.ini", "Defaults", "recycleOriginals", 0)
			EndIf

			IniWrite("LooperTrimmer.ini", "Defaults", "defaultHandles", GUICtrlRead($defaultHandlesList))
			IniWrite("LooperTrimmer.ini", "Defaults", "defaultTrim", GUICtrlRead($defaultTrimList))
		Case $GUI_EVENT_CLOSE, $cancelButton
			Exit
	EndSwitch
WEnd
