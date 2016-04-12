; IMAGES
GUICtrlSetImage($currentLooperButton, "shell32.dll", -101, 0)
GUICtrlSetImage($destButton, "shell32.dll", -4, 0)

; FONTS
GUICtrlSetFont($currentLooperDesc, 10, 800, 0, "Segoe UI")
GUICtrlSetFont($currentLooperTF, 10, 400, 0, "Segoe UI")
GUICtrlSetFont($destDesc, 10, 800, 0, "Segoe UI")
GUICtrlSetFont($destTF, 10, 400, 0, "Segoe UI")
GUICtrlSetFont($eventsList, 9, 400, 0, "Segoe UI")
GUICtrlSetFont($newLooperRadio, 10, 400, 0, "Segoe UI")
GUICtrlSetFont($recycleMediaRadio, 10, 400, 0, "Segoe UI")
GUICtrlSetFont($prefsButton, 9, 400, 0, "Segoe UI")
GUICtrlSetFont($submitButton, 9, 400, 0, "Segoe UI")

; OTHER CUSTOMIZATIONS
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 0, 190) ; Event Name field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 1, 80) ; In Point field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 2, 80) ; Out Point field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 3, 80) ; Handles field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 4, 230) ; Media Filename field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 5, 150) ; Destination Codec field
GUICtrlSendMsg($eventsList, $LVM_SETCOLUMNWIDTH, 6, 155) ; Status field

; EVENT HANDLERS
GUICtrlSetOnEvent($currentLooperButton, "loadLooper")
GUICtrlSetOnEvent($destButton, "chooseDestination")
GUICtrlSetOnEvent($prefsButton, "loadPreferences")
GUICtrlSetOnEvent($submitButton, "submitJobButton")

GUISetOnEvent($GUI_EVENT_CLOSE, "quitMe")
GUISetOnEvent($GUI_EVENT_PRIMARYDOWN, "createContextMenu")