Func findFile($looperPath, $filePath)
	$currentLooperPath = StringLeft($looperPath, StringInStr($looperPath, "\", -1, -1))
	$fileName = StringTrimLeft($filePath, StringInStr($filePath, "\", -1, -1))

	If FileExists($currentLooperPath & $fileName) Then
		Return ($currentLooperPath & $fileName)
	Else
		Return "ERROR: File for this event not found"
	EndIf
EndFunc