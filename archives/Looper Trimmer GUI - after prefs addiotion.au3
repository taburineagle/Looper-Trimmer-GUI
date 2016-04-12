; LOOPER TRIMMER GUI
; © 2016 ZACH GLENWRIGHT
;
; Trimming program based on MPC-HC Looper (also by Zach Glenwright) and using FFMPEG to trim the files into smaller
; chunks - originally a batch program, but wanted to make a GUI version for more "user-friendliness" - and I also
; want a lemur, but that's not happening any time soon!

#include <File.au3>
#include <GuiListView.au3>
#include <GuiComboBox.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ListViewConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

#include "includes\SYS_TimeConversion.au3"

Global $ffmpegPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", "")
Global $tsMuxeRPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR", "")
Global $hideEncoding = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 0)

Global $eventsListContextMenu, $handlesMenu_1, $handlesMenu_2, $handlesMenu_3, $handlesMenu_4, $handlesMenu_5, $transcodeMenu_Lossless, $transcodeMenu_ProRes
Global $menuCreated = False

$mainWindow = GUICreate("Looper Trimmer 0.1.030616 by Zach Glenwright", 970, 419, 192, 124)

$currentLooperButton = GUICtrlCreateButton("", 8, 6, 26, 26, BitOR($BS_ICON, $BS_CENTER))
GUICtrlSetImage(-1, "shell32.dll", -101, 0)

$currentLooperDesc = GUICtrlCreateLabel("Current Looper file:", 45, 11, 125, 21)
GUICtrlSetFont(-1, 10, 800, 0, "Segoe UI")
$currentLooperTF = GUICtrlCreateLabel("", 176, 11, 700, 21)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$destButton = GUICtrlCreateButton("", 8, 36, 26, 26, BitOR($BS_ICON, $BS_CENTER))
GUICtrlSetImage(-1, "shell32.dll", -4, 0)

$destDesc = GUICtrlCreateLabel("Destination path:", 45, 40, 112, 21)
GUICtrlSetFont(-1, 10, 800, 0, "Segoe UI")
$destTF = GUICtrlCreateLabel("", 160, 40, 700, 21)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

$eventsList = GUICtrlCreateListView("Event Name|In Point|Out Point|Handles|Media Filename|Destination Codec|Status", 0, 70, 969, 313, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 190)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 80)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 80)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 80)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 245)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 5, 135)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 6, 155)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

$newLooperRadio = GUICtrlCreateCheckbox(" Create new Looper file with the trimmed events", 8, 392, 297, 17)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

If IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 1) = 1 Then
	GUICtrlSetState($newLooperRadio, $GUI_CHECKED)
EndIf

$recycleMediaRadio = GUICtrlCreateCheckbox(" Recycle the original media file(s) when trimming is done", 320, 392, 353, 17)
GUICtrlSetFont(-1, 10, 400, 0, "Segoe UI")

If IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 0) = 1 Then
	GUICtrlSetState($recycleMediaRadio, $GUI_CHECKED)
EndIf

$prefsButton = GUICtrlCreateButton("Preferences...", 680, 388, 129, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

$submitButton = GUICtrlCreateButton("Submit Job", 816, 388, 145, 25)
GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")
GUICtrlSetState($submitButton, $GUI_DISABLE)

GUISetState(@SW_SHOW)

Func loadLooper($looperFile)
	_GUICtrlListView_DeleteAllItems($eventsList)

	$eventCount = _FileCountLines($looperFile)

	$currentLooperTFString = StringTrimLeft($looperFile, StringInStr($looperFile, "\", -1, -1))
	$currentLooperTFString = $currentLooperTFString & " (" & $eventCount & " events)"

	GUICtrlSetData($currentLooperTF, $currentLooperTFString)
	GUICtrlSetTip($currentLooperTF, $looperFile)

	$readingFile = FileOpen($looperFile)

	For $i = 1 to $eventCount
		$currentItem = FileReadLine($readingFile, $i)
		$currentItemArray = StringSplit($currentItem, "|")

		$newEvent = $currentItemArray[1] & "|" & $currentItemArray[2] & "|" & $currentItemArray[3]

		$defaultHandles = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultHandles", "2 seconds")
		$newEvent = $newEvent & "|" & $defaultHandles

		If FileExists($currentItemArray[4]) = 0 Then
			$currentItemArray[4] = findFile($looperFile, $currentItemArray[4])
		EndIf

		$newEvent = $newEvent & "|" & $currentItemArray[4]

		$defaultTrim = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultTrim", "Trim Losslessly (ffmpeg)")
		$newEvent = $newEvent & "|" & $defaultTrim

		$newEvent = $newEvent & "|" & ""

		GUICtrlCreateListViewItem($newEvent, $eventsList)
	Next

	FileClose($readingFile)
EndFunc

Func findFile($looperPath, $filePath)
	$currentLooperPath = StringLeft($looperPath, StringInStr($looperPath, "\", -1, -1))
	$fileName = StringTrimLeft($filePath, StringInStr($filePath, "\", -1, -1))

	If FileExists($currentLooperPath & $fileName) Then
		Return ($currentLooperPath & $fileName)
	Else
		Return "ERROR: File for this event not found"
	EndIf
EndFunc

While 1
	$nMsg = GUIGetMsg()

	If _GUICtrlListView_GetSelectedIndices($eventsList) = "" Then
		GUICtrlDelete($eventsListContextMenu)
		$menuCreated = 0
	Else
		If $menuCreated <> 1 Then
			createContextMenu()
			$menuCreated = 1
		EndIf
	EndIf

	If GUICtrlRead($currentLooperTF) <> "" And GUICtrlRead($destTF) <> "" Then
		If GUICtrlGetState($submitButton) <> 80 Then
			GUICtrlSetState($submitButton, $GUI_ENABLE)
		EndIf
	Else
		If GUICtrlGetState($submitButton) <> 144 Then
			GUICtrlSetState($submitButton, $GUI_DISABLE)
		EndIf
	EndIf

	Switch $nMsg
		Case $currentLooperButton
			$fileToOpen = FileOpenDialog("Where is the loop events file you want to trim?", @DesktopDir, "Loop Events File (*.looper)")

			If $fileToOpen <> "" Then
				loadLooper($fileToOpen)
			EndIf
		Case $destButton
			$exportFolder = FileSelectFolder("Where do you want to save the trimmed loop files?", @DesktopDir, 1)

			If $exportFolder <> "" Then
				GUICtrlSetData($destTF, $exportFolder)
			EndIf
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
		Case $transcodeMenu_Lossless
			changeItems("Trim Losslessly (ffmpeg)")
		Case $transcodeMenu_ProRes
			changeItems("Transcode to ProRes")
		Case $prefsButton
			loadPreferences()
		Case $submitButton
			submitJob()
		Case $GUI_EVENT_CLOSE
			Exit
	EndSwitch
WEnd

Func loadPreferences()
	GUISetState(@SW_DISABLE, $mainWindow) ; disable the main window when the prefs window is open

	$prefsWindow = GUICreate("Looper Trimmer Preferences", 399, 295, -1, -1)

	$ffmpegPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", "")
	$tsMuxeRPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR", "")
	$hideEncoding = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 0)
	$newLooperDefault = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 1)
	$recycleDefault = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 0)
	$defaultHandles = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultHandles", "2 seconds")
	$defaultTrim = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "defaultTrim", "Trim Losslessly (ffmpeg)")

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

	$hideEncodingCheck = GUICtrlCreateCheckbox(" Hide ffmpeg/tsMuxeR encoding windows", 8, 96, 249, 25)
	GUICtrlSetFont(-1, 9, 400, 0, "Segoe UI")

	If $hideEncoding = 1 Then
		GUICtrlSetState($hideEncodingCheck, $GUI_CHECKED)
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
			Case $pathFFButton
				$ffmpegPath = FileOpenDialog("Where is the ffmpeg executable file?", Default, "Executable files (*.exe)", 1, "ffmpeg.exe")

				If $ffmpegPath <> "" Then
					GUICtrlSetData($pathFFTF, $ffmpegPath)
				EndIf
			Case $pathTSButton
				$tsMuxeRPath = FileOpenDialog("Where is the tsMuxeR executable file?", Default, "Executable files (*.exe)", 1, "tsMuxeR.exe")

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

	GUISetState(@SW_ENABLE, $mainWindow)
	WinActivate($mainWindow)
EndFunc

Func createContextMenu()
	$eventsListContextMenu = GUICtrlCreateContextMenu($eventsList)

	$handlesMenu = GUICtrlCreateMenu("Media Handles", $eventsListContextMenu)
	$handlesMenu_1 = GUICtrlCreateMenuItem("1 second", $handlesMenu)
	$handlesMenu_2 = GUICtrlCreateMenuItem("2 seconds", $handlesMenu)
	$handlesMenu_3 = GUICtrlCreateMenuItem("3 seconds", $handlesMenu)
	$handlesMenu_4 = GUICtrlCreateMenuItem("4 seconds", $handlesMenu)
	$handlesMenu_5 = GUICtrlCreateMenuItem("5 seconds", $handlesMenu)

	$transcodeMenu = GUICtrlCreateMenu("Transcode Settings", $eventsListContextMenu)
	$transcodeMenu_Lossless = GUICtrlCreateMenuItem("Trim Losslessly (ffmpeg)", $transcodeMenu)
	$transcodeMenu_ProRes = GUICtrlCreateMenuItem("Transcode to ProRes", $transcodeMenu)
EndFunc

Func changeItems($statusChange)
	$selectedItems = _GUICtrlListView_GetSelectedIndices($eventsList, true)

	If IsArray($selectedItems) Then
		For $a = 1 to $selectedItems[0]
			Switch $statusChange
				Case "1 second", "2 seconds", "3 seconds", "4 seconds", "5 seconds"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 3)
				Case "Trim Losslessly (ffmpeg)", "Transcode to ProRes"
					_GUICtrlListView_SetItem($eventsList, $statusChange, $selectedItems[$a], 5)
			EndSwitch
		Next
	EndIf
EndFunc

Func submitJob()
	$totalCount = _GUICtrlListView_GetItemCount($eventsList)

	For $i = 0 to $totalCount - 1
		_GUICtrlListView_SetItem($eventsList, "Waiting to trim...", $i, 6)
	Next

	For $i = 0 to $totalCount - 1
		_GUICtrlListView_EnsureVisible($eventsList, $i, True)

		$currentJobName = _GUICtrlListView_GetItemText($eventsList, $i, 0)
		$currentJobINPoint = _GUICtrlListView_GetItemText($eventsList, $i, 1)
		$currentJobOUTPoint =  _GUICtrlListView_GetItemText($eventsList, $i, 2)
		$currentJobHandles = _GUICtrlListView_GetItemText($eventsList, $i, 3)
		$currentJobSourcefile = _GUICtrlListView_GetItemText($eventsList, $i, 4)
		$currentJobTranscode = _GUICtrlListView_GetItemText($eventsList, $i, 5)

		$adjustedEditPoints = getAdjustedEditPoints($currentJobINPoint, $currentJobOUTPoint, $currentJobHandles)

		$params = '-i "' & $currentJobSourcefile & '" '

		If $adjustedEditPoints[0] <> "0:00" Then
			$params = $params & '-ss ' & $adjustedEditPoints[0] & ' '
		EndIf

		$params = $params & '-to ' & $adjustedEditPoints[1] & ' '

		If $currentJobTranscode = "Transcode to ProRes" Then
			$params = $params & ' -c:v prores -c:a pcm_s16le '
			$destFile = findDestFile(GUICtrlRead($destTF), $currentJobSourcefile, ".mov", $i)
		Else
			$params = $params & ' -c copy '
			$destFile = findDestFile(GUICtrlRead($destTF), $currentJobSourcefile, -1, $i)
		EndIf

		$params = $params & '"' & $destFile & '"'

		_GUICtrlListView_SetItem($eventsList, "Trimming...", $i, 6)

		If $hideEncoding = 1 Then
			ShellExecuteWait($ffmpegPath, $params, Default, Default, @SW_HIDE)
		Else
			ShellExecuteWait($ffmpegPath, $params)
		EndIf

		If GUICtrlRead($newLooperRadio) = 1 Then
			_GUICtrlListView_SetItem($eventsList, "Adding event to new file...", $i, 6)

			$newLooper = GUICtrlRead($destTF) & "\Trimmed.looper"
			$writingFile = FileOpen($newLooper, 35)

			$writingLine = $currentJobName

			If $adjustedEditPoints[0] = "0:00" Then
				$writingLine = $writingLine & "|" & $currentJobINPoint
				$writingLine = $writingLine & "|" & $currentJobOUTPoint
			Else
				$writingLine = $writingLine & "|" & NumberToTimeString($currentJobHandles)
				$writingLine = $writingLine & "|" & NumberToTimeString(TimeStringToNumber($currentJobOUTPoint) - TimeStringToNumber($currentJobINPoint) + $currentJobHandles)

			EndIf

			$writingLine = $writingLine & "|" & $destFile

			FileWriteLine($writingFile, $writingLine)
			FileClose($writingFile)
		EndIf

		_GUICtrlListView_SetItem($eventsList, "Done", $i, 6)
	Next
EndFunc

Func findDestFile($destPath, $filePath, $fileExtension, $currentIteration)
	$exportFile = StringTrimLeft($filePath, StringInStr($filePath, "\", 2, -1))
	$exportExtension = StringTrimLeft($exportFile, StringInStr($exportFile, ".", 2, -1) - 1)
	$exportFile = StringTrimRight($exportFile, StringLen($exportExtension))

	If $fileExtension = - 1 Then
		$fileExtension = $exportExtension ; set the current output extension to the original file extension
	Else
		; $fileExtension is already set to .mov due to ProRes encoding
	EndIf

	Return ($destPath & "\" & "EV_" & StringFormat("%03d", ($currentIteration + 1)) & "_" & $exportFile & $fileExtension)
EndFunc

Func returnHandles($clipHandles)
	If $clipHandles = "1 second" Then
		Return 1
	ElseIf $clipHandles = "2 seconds" Then
		Return 2
	ElseIf $clipHandles = "3 seconds" Then
		Return 3
	ElseIf $clipHandles = "4 seconds" Then
		Return 4
	ElseIf $clipHandles = "5 seconds" Then
		Return 5
	EndIf
EndFunc

Func getAdjustedEditPoints($inPoint, $outPoint, $clipHandles)
	$clipHandles = returnHandles($clipHandles)

	$newInPoint = TimeStringToNumber($inPoint) - $clipHandles

	If $newInPoint < 0 Then
		$newInPoint = "0:00"
	Else
		$newInPoint = NumberToTimeString($newInPoint)
	EndIf

	$newOutPoint = NumberToTimeString(TimeStringToNumber($outPoint) + $clipHandles)

	Dim $returnArray[2] = [$newInPoint, $newOutPoint]
	Return $returnArray
EndFunc