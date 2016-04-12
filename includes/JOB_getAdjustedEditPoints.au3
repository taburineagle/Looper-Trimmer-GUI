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