Local $accelKeys[1][2] = [["^a", $selectAllDummy]]
GUISetAccelerators($accelKeys)

GUICtrlSetOnEvent($selectAllDummy, "selectAll")

Func selectAll()
	_GUICtrlListView_SetItemSelected($eventsList, -1, True, True)
EndFunc