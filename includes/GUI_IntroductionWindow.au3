Func loadIntroWindow()
	$IntroWindow = GUICreate("Welcome!", 259, 468, -1, -1)
	$_WT1 = GUICtrlCreateLabel("Welcome to Looper Trimmer!", 38, 8, 186, 21)
	_Remove_CS_DBLCLKS(-1) ; remove double-click ability from static controls (but not from buttons or list views!)
	$_WT2 = GUICtrlCreateEdit("", 16, 32, 225, 49, $ES_READONLY, 0)
	$_WT3 = GUICtrlCreateEdit("", 16, 85, 225, 97, $ES_READONLY, 0)
	$_FFMPEGURL = GUICtrlCreateLabel("https://ffmpeg.zeranoe.com/builds/", 20, 184, 200, 19)
	$_WT4 = GUICtrlCreateEdit("", 16, 208, 225, 65, $ES_READONLY, 0)
	$IntroPathFFTF = GUICtrlCreateInput("", 16, 280, 193, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
	$IntroPathFFButton = GUICtrlCreateButton("...", 216, 280, 25, 21)
	$_WT5 = GUICtrlCreateEdit("", 16, 312, 225, 113, $ES_READONLY, 0)
	$IntroCancelButton = GUICtrlCreateButton("Quit", 40, 432, 81, 25)
	$IntroOKButton = GUICtrlCreateButton("OK", 136, 432, 81, 25)

	#include "custom\GUI_introWindowCustom.au3"

	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()

		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $IntroCancelButton
				Exit
			Case $_FFMPEGURL
				ShellExecute("https://ffmpeg.zeranoe.com/builds/")
			Case $IntroPathFFButton
				$ffmpegPath = FileOpenDialog("Where is the ffmpeg executable file?", Default, "ffmpeg (ffmpeg.exe)", 1)

				If $ffmpegPath <> "" Then
					GUICtrlSetData($IntroPathFFTF, $ffmpegPath)
					GUICtrlSetTip($IntroPathFFTF, $ffmpegPath)
				EndIf
			Case $IntroOKButton
				IniWrite(@ScriptDir & "/LooperTrimmer.ini", "Paths", "ffmpeg", GUICtrlRead($IntroPathFFTF))
				GUIDelete($IntroWindow)
				ExitLoop
		EndSwitch

		If GUICtrlRead($IntroPathFFTF) = "" Then
			If GUICtrlGetState($IntroOKButton) = 80 Then
				GUICtrlSetState($IntroOKButton, $GUI_DISABLE)
			EndIf
		Else
			If GUICtrlGetState($IntroOKButton) = 144 Then
				GUICtrlSetState($IntroOKButton, $GUI_ENABLE)
			EndIf
		EndIf

		Sleep(50)
	WEnd
EndFunc
