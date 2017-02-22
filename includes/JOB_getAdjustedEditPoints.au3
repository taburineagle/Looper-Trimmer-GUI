Func getAdjustedEditPoints($inPoint, $outPoint, $clipHandles)
	$clipHandles = returnHandles($clipHandles)

	If $clipHandles <> 0 Then
		$newInPoint = TimeStringToNumber($inPoint) - $clipHandles
	Else
		$newInPoint = TimeStringToNumber($inPoint) - 0.55 ; if there are no handles, then push the in back just a little bit
	EndIf

	If $newInPoint < 0 Then
		$newInPoint = "0:00"
	Else
		$newInPoint = NumberToTimeString($newInPoint)
	EndIf

	If $clipHandles <> 0 Then
		$newOutPoint = NumberToTimeString(TimeStringToNumber($outPoint) + $clipHandles)
	Else
		$newOutPoint = NumberToTimeString(TimeStringToNumber($outPoint) - 0.55) ; if there are no handles, then push the out back just a little bit
	EndIf

	Dim $returnArray[2] = [$newInPoint, $newOutPoint]
	Return $returnArray
EndFunc