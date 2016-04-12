Func findDestFile($destPath, $filePath, $fileExtension, $currentIteration)
	$exportFile = StringTrimLeft($filePath, StringInStr($filePath, "\", 2, -1))
	$exportExtension = StringTrimLeft($exportFile, StringInStr($exportFile, ".", 2, -1) - 1)
	$exportFile = StringTrimRight($exportFile, StringLen($exportExtension))

	If $fileExtension = - 1 Then
		$fileExtension = $exportExtension ; set the current output extension to the original file extension
	Else
		; $fileExtension is already set to .mov due to ProRes encoding
	EndIf

	$destFile = ($destPath & "EV_" & StringFormat("%03d", ($currentIteration + 1)) & "_" & $exportFile & $fileExtension)

	$deleteFile = 1

	If FileExists($destFile) Then
		$deleteFile = MsgBox(52, "File already exists!", 'A file named ' & $destFile & ' already exists in the destination directory.  Do you want to recycle it?  If you choose "No", then this event will be skipped, and Trimmer will process the next event.')

		If $deleteFile = 6 Then
			FileRecycle($destFile)
			$deleteFile = 1
		Else
			$deleteFile = 0
		EndIf
	EndIf

	Dim $returnArray[2] = [$deleteFile, $destFile]
	Return $returnArray
EndFunc