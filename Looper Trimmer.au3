#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Comment=Looper Trimmer is an EDL-like editing program that takes .looper playlist files from MPC-HC Looper and trims each event into smaller independent files for editabilty, portability and to save disk space.
#AutoIt3Wrapper_Res_Description=Looper Trimmer by Zach Glenwright
#AutoIt3Wrapper_Res_Fileversion=6.7.16.3
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=2016 Zach Glenwright
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; LOOPER TRIMMER GUI
; � 2016 ZACH GLENWRIGHT
;
; Trimming program based on MPC-HC Looper (also by Zach Glenwright) and using FFMPEG to trim the files into smaller
; chunks - originally a batch program, but wanted to make a GUI version for more "user-friendliness"

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
#include <WinAPIEx.au3>
#include <Misc.au3>
#include <GuiMenu.au3>

If _Singleton("Looper_Trimmer", 1) = 0 Then
	Exit
EndIf

#include 'includes\GUI_IntroductionWindow.au3' ; welcome screen for the first time using the program
#include 'includes\SYS_Remove_CS_DBLCLKS.au3' ; remove double-clicking ability for static (label) controls so it doesn't change clipboard

Global $ffmpegPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", "")

While $ffmpegPath = ""
	loadIntroWindow() ; opens the "Welcome to Looper Trimmer!" window to get the ffmpeg path
	$ffmpegPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", "") ; loads the path from the .ini file to make sure it worked
WEnd

Global $tsMuxeRPath = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Paths", "tsMuxeR", "")
Global $hideEncoding = IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "hideEncoding", 0)

Global $isWorking = 0
Global $disableSubmit = False ; if you delete all of the source files in a job, this Global disables Submit in the main loop

Global Enum $handlesMenu_0 = 1000, $handlesMenu_1, $handlesMenu_2, $handlesMenu_3, $handlesMenu_4, $handlesMenu_5
Global Enum $transcodeMenu_LosslessTS = 2000, $transcodeMenu_Lossless, $transcodeMenu_LosslessMKV, $transcodeMenu_ProRes

Opt("GUIOnEventMode", 1)

$mainWindow = GUICreate("Looper Trimmer by Zach Glenwright BETA (2-28-17 version A)", 970, 440, (@DesktopWidth - 988), 18, BitOR($WS_SIZEBOX, $WS_MINIMIZEBOX))

$currentLooperButton = GUICtrlCreateButton("", 8, 6, 26, 26, BitOR($BS_ICON, $BS_CENTER)) ; GUI Element 3
$currentLooperDesc = GUICtrlCreateLabel("Current Looper file:", 45, 11, 125, 21) ; GUI Element 4
_Remove_CS_DBLCLKS(-1) ; remove double-click ability from static controls (but not from buttons or list views!)
$currentLooperTF = GUICtrlCreateLabel("", 176, 11, 700, 21) ; GUI Element 5

$destButton = GUICtrlCreateButton("", 8, 36, 26, 26, BitOR($BS_ICON, $BS_CENTER)) ; GUI Element 6
$destDesc = GUICtrlCreateLabel("Destination path:", 45, 40, 112, 21) ; GUI Element 7
$destTF = GUICtrlCreateLabel("", 160, 40, 700, 21) ; GUI Element 8

; GUI Element 9
$eventsList = GUICtrlCreateListView("Event Name|In Point|Out Point|Handles|Media Filename|Destination Codec|Status", 0, 70, 969, 313, BitOR($LVS_REPORT,$LVS_SHOWSELALWAYS), BitOR($WS_EX_CLIENTEDGE,$LVS_EX_FULLROWSELECT))

$newLooperRadio = GUICtrlCreateCheckbox(" Create new Looper file with the trimmed events", 8, 392, 297, 17) ; GUI Element 10

If IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "newLooper", 1) = 1 Then
	GUICtrlSetState($newLooperRadio, $GUI_CHECKED)
EndIf

$recycleMediaRadio = GUICtrlCreateCheckbox(" Recycle the original media file(s) when trimming is done", 320, 392, 353, 17) ; GUI Element 11

If IniRead(@ScriptDir & "/LooperTrimmer.ini", "Defaults", "recycleOriginals", 0) = 1 Then
	GUICtrlSetState($recycleMediaRadio, $GUI_CHECKED)
EndIf

$prefsButton = GUICtrlCreateButton("Preferences...", 680, 388, 129, 25) ; GUI Element 12

$submitButton = GUICtrlCreateButton("Submit Job", 816, 388, 145, 25) ; GUI Element 13
GUICtrlSetState($submitButton, $GUI_DISABLE) ; disable Submit button in the beginning, because there's nothing to do yet!

$selectAllDummy = GUICtrlCreateDummy() ; GUI Element 14

For $i = 3 To 8 ; set resizing of every single element to "don't move", the resize procedure sizes things as needed
	GUICtrlSetResizing($i, 802)
Next

GUICtrlSetResizing(9, $GUI_DOCKLEFT + $GUI_DOCKTOP + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH) ; resize the event list in a different way

For $i = 10 to 13 ; set resizing of every element below the event list to don't move
	GUICtrlSetResizing($i, $GUI_DOCKLEFT + $GUI_DOCKBOTTOM + $GUI_DOCKWIDTH + $GUI_DOCKHEIGHT)
Next

; SYSTEM INCLUDES
#include "includes\SYS_TimeConversion.au3" ; converts between time strings and numbers

; FILE SYSTEM INCLUDES
#include "includes\FILE_loadLooper.au3" ; load a looper file into the events list
#include "includes\FILE_chooseDestination.au3" ; choose the destination path to export new clipped files to
#include "includes\FILE_findFile.au3" ; find the media file in the current Looper path, if it doesn't exist, then return "poo"
#include "includes\FILE_findDestFile.au3" ; find the destination file for the current trim operation
#include "includes\FILE_deleteFiles.au3" ; function to delete files after batch processing is complete

; GUI INCLUDES
#include "includes\custom\GUI_mainWindowCustom.au3" ; sets up the main window fonts and parameters
#include "includes\PREFS_loadPreferences.au3" ; loads the preferences window and handles all of that
#include "includes\SYS_WM_GETMINMAXINFO.au3" ; determines maximum and minimum size for the GUI
#include "includes\GUI_contextMenu.au3" ; creates the context menu (changed 2-28-17 with brand new method for triggering context menu)
#include "includes\GUI_changeItems.au3" ; change the items in the events list
#include "includes\GUI_selectAll.au3" ; selects all with CTRL-A and makes the menu for those items

; JOB INCLUDES
#include "includes\JOB_testEncoderPaths.au3" ; test whether the paths specified for ffmpeg and/or tsMuxeR are filled and correct
#include "includes\JOB_submitJob.au3" ; submit the job to the trimmer
#include "includes\JOB_getAdjustedEditPoints.au3" ; get adjusted IN and OUT points according to the handles
#include "includes\JOB_returnHandles.au3" ; get how many seconds of handle adjustment you need
#include "includes\JOB_type_ffmpegJob.au3" ; ffmpeg instructions for trimming
#include "includes\JOB_type_tsMuxeRJob.au3" ; ffmpeg instructions for trimming

GUISetState(@SW_SHOW) ; show the freakin' window!

Func submitJobButton()
	If GUICtrlRead($submitButton) = "Submit Job" Then
		GUICtrlSetData($submitButton, "Cancel Job")
		$isWorking = 1
	Else
		GUICtrlSetData($submitButton, "Cancelling...")
		$isWorking = 2
	EndIf
EndFunc

While 1
	If GUICtrlRead($currentLooperTF) <> "" And GUICtrlRead($destTF) <> "" And $disableSubmit = False Then
		If GUICtrlGetState($submitButton) <> 80 Then
			GUICtrlSetState($submitButton, $GUI_ENABLE)
		EndIf
	Else
		If GUICtrlGetState($submitButton) <> 144 Then
			GUICtrlSetState($submitButton, $GUI_DISABLE)
		EndIf
	EndIf

	If $isWorking <> 0 Then
		submitJob()
	EndIf

	Sleep(10)
WEnd

Func quitMe()
	Exit
EndFunc