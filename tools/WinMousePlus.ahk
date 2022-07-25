;win +  mouse
SetWinDelay 0
CoordMode "Mouse"
m_Step := 40

#SPACE::
{
    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    WinSetAlwaysOnTop -1, KDE_id
    ; ifIndex := hasValue(topWindow, KDE_id)	;
    ; if (ifIndex == -1) {
    ;     WinSetAlwaysOnTop 0, KDE_id
    ;     topWindow.Push(KDE_id)
    ; } else {
    ;     WinSetAlwaysOnTop 1, KDE_id
    ;     topWindow.Delete(ifIndex)
    ; }
}

#LButton::
{
    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    ; ToolTip ("KDE_X1:" KDE_X1 "KDE_Y1:" KDE_Y1 "KDE_id:" KDE_id)
    WinMaxed := WinGetMinMax(KDE_id) = 1
    if WinMaxed
        WinRestore(KDE_id)

    WinActivate(KDE_id)
    WinGetPos(&KDE_WinX1, &KDE_WinY1, &winw, &winh, KDE_id)
    Loop
    {
        if !GetKeyState("LButton", "P")
            break
        MouseGetPos(&KDE_X2, &KDE_Y2)	; Get the current mouse position.
        KDE_X2 -= KDE_X1	; Obtain an offset from the initial mouse position.
        KDE_Y2 -= KDE_Y1
        KDE_WinX2 := (KDE_WinX1 + KDE_X2)	; Apply this offset to the window position.
        KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
        ; ToolTip ("WinMove:KDE_WinX2=" KDE_WinX2 ";KDE_WinY2=" KDE_WinY2)
        WinMove(KDE_WinX2, KDE_WinY2, winw, winh, KDE_id)	; Move the window to the new position.
    }

    if WinMaxed
        WinMaximize(KDE_id)
}

#RButton::
{
    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    WinMaxed := WinGetMinMax(KDE_id) = 1
    if WinMaxed
        WinRestore(KDE_id)
    WinActivate(KDE_id)
    WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id)
    ; Define the window region the mouse is currently in.
    ; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
    If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
        KDE_WinLeft := 1
    Else
        KDE_WinLeft := -1
    If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
        KDE_WinUp := 1
    Else
        KDE_WinUp := -1
    Loop
    {
        if !GetKeyState("RButton", "P")
            break
        MouseGetPos(&KDE_X2, &KDE_Y2)
        WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id)
        KDE_X2 -= KDE_X1	; Obtain an offset from the initial mouse position.
        KDE_Y2 -= KDE_Y1
        ; Then, act according to the defined region.
        WinMove(KDE_WinX1 + (KDE_WinLeft + 1) / 2 * KDE_X2	; X of resized window
            , KDE_WinY1 + (KDE_WinUp + 1) / 2 * KDE_Y2	; Y of resized window
            , KDE_WinW - KDE_WinLeft * KDE_X2	; W of resized window
            , KDE_WinH - KDE_WinUp * KDE_Y2	; H of resized window
            , KDE_id)
        KDE_X1 := (KDE_X2 + KDE_X1)	; Reset the initial position for the next iteration.
        KDE_Y1 := (KDE_Y2 + KDE_Y1)
    }
}
#MButton::
{
    MouseGetPos(, , &KDE_id)
    WinClose(KDE_id)
}

; !WheelDown:: ResizeWindow(-m_Step)
; !WheelUp:: ResizeWindow(m_Step)

ResizeWindow(step)
{
    MouseGetPos(&KDE_X1, &KDE_Y1, &KDE_id)
    WinMaxed := WinGetMinMax(KDE_id) = 1
    if WinMaxed
        WinRestore(KDE_id)
    WinActivate(KDE_id)
    WinGetPos(&KDE_WinX1, &KDE_WinY1, &KDE_WinW, &KDE_WinH, KDE_id)

    ; Then, act according to the defined region.
    WinMove(KDE_WinX1 - step / 2	; X of resized window
        , KDE_WinY1 - step / 2	; Y of resized window
        , KDE_WinW + step	; W of resized window
        , KDE_WinH + step	; H of resized window
        , KDE_id)
}

; hasValue(haystack, needle) {
;     if (!isObject(haystack)) {
;         return -1
;     }
;     if (haystack.Length == 0)
;     {
;         return -1
;     }
;     for ix, val in haystack {
;         MsgBox ix "+" val
;         if (val == needle) {
;             return ix
;         }
;     }
;     return -1
; }

; topWindow := Array()

; #SingleInstance force
; ;#NoTrayIcon

; hChild := WinWait("计算器")
; hParent := WinExist()

; myGui := Gui()
; myGui.MarginX := "0", myGui.MarginY := "0"
; ogcButtonTest := myGui.Add("Button", , "pin")
; ogcButtonTest.OnEvent("Click", ButtonTest.Bind("Normal"))
; myGui.Opt("-Caption HWNDhChild")
; DllCall("SetParent", "Ptr", hChild, "Ptr", hParent)
; myGui.Show("x0 y0")
; WinWaitClose("计算器")
; Reload

; Return

; ButtonTest(A_GuiEvent, GuiCtrlObj, Info, *)
; {
;     MsgBox("I am here.")
;     Return
; }