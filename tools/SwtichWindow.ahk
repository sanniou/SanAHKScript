/*
swtich window of same application
 */

windows := Menu()
; OnMessage(0x02A1, WM_MENURBUTTONUP)
OnMessage(0x0122, WM_MENURBUTTONUP)
OnMessage(0x211, WM_ENTERMENULOOP)
RButton_Click := false
max_menu_label_len := 64

; #HotIf
#WheelUp::	; All window
{
    AltTabMenu(false)
}
; not work
#WheelUp Up:: {
    WinClose(windows)
    MsgBox	; "Press OK to continue."
}
#WheelDown::	; window of Current exe
{
    AltTabMenu()
}

WM_MENURBUTTONUP(wparam, lparam, msg, hwnd) {
    Global RButton_Click
    RButton_Click := true
    MouseGetPos(, , &w)
    ControlSend("{enter}", , "ahk_id " w)
    return
}
WM_ENTERMENULOOP(wParam, lParam, *) {	; Notifies an application's main window procedure that a menu modal loop has been entered.
    ; by returning true, the AHK doesn't halt processing Messages, timers, hotkeys... (the default behavior)
    return true
}

; AltTabMenu-replacement for Windows 8:
AltTabMenu(currentExe := true) {
    ; WinClose(windows.Handle)
    windows.Delete()
    if (currentExe) {
        MouseGetPos(, , &positionWindow)
        ActiveExe := WinGetProcessName(positionWindow)
        winList := WinGetList("ahk_exe" ActiveExe)
        oid := winList
    } else {
        oid := WinGetlist(, , , )
    }
    aid := Array()
    id := oid.Length
    For v in oid
    {
        aid.Push(v)
    }
    Loop aid.Length
    {
        this_ID := aid[A_Index]
        title := WinGetTitle("ahk_id " this_ID)
        If (title = "")
            continue
        If (!IsWindow(WinExist("ahk_id" . this_ID)))
            continue
        if (StrLen(title) > max_menu_label_len) {
            title := SubStr(title, 1, max_menu_label_len) "..."
        }
        title := title " |" this_ID
        windows.Add(title, ActivateTitle)
        Path := WinGetProcessPath("ahk_id " this_ID)
        Try
            windows.SetIcon(title, Path)
        Catch
            windows.SetIcon(title, A_WinDir . "\System32\SHELL32.dll", "3")
    }
    windows.Show()
}

ActivateTitle(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
    ProcessID := StrSplit(A_ThisMenuItem, "|")
    Global RButton_Click
    if (RButton_Click) {
        WinClose("ahk_id " ProcessID[2])
    } else {
        WinActivate("ahk_id " ProcessID[2])
    }
    RButton_Click := false	; always do this, so that you can differentiate between normal or right click
    return
}

IsWindow(hWnd) {
    dwStyle := WinGetStyle("ahk_id " hWnd)
    if ((dwStyle & 0x08000000) || !(dwStyle & 0x10000000)) {
        return false
    }
    dwExStyle := WinGetExStyle("ahk_id " hWnd)
    if (dwExStyle & 0x00000080) {
        return false
    }
    szClass := WinGetClass("ahk_id " hWnd)
    if (szClass = "TApplication") {
        return false
    }
    return true
}