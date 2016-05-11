Func testEncoderPaths($encoder)
	If $encoder = "ffmpeg" Then
		If $ffmpegPath <> "" Then ; if the path for ffmpeg is filled in
			If FileExists($ffmpegPath) <> 0 Then ; if the path specified for ffmpeg is valid
				Return 1 ; yes, we are good to go
			Else
				Return 0 ; the file doesn't exist where you say it does... hmmmm...
			EndIf
		Else
			Return 0 ; somehow we don't have an ffmpeg path - which should be *impossible*, but need to be prepared!
		EndIf
	ElseIf $encoder = "tsMuxeR" Then
		If $tsMuxeRPath <> "" Then ; if the path for tsMuxeR is filled in
			If FileExists($tsMuxeRPath) <> 0 Then ; if the path specified for tsMuxeR is valid
				Return 1 ; yes, we are good to go
			Else
				Return 0 ; noooooooooooooo...ooo, the file isn't where it's supposed to be!
			EndIf
		Else
			Return 0 ; somehow we don't have a tsMuxeR path - which makes more sense than above, but still good to check!
		EndIf
	EndIf
EndFunc