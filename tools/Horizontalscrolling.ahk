; Helper WinAPI constants
global dbg := 1	; Level of debug verbosity
  , msgScrollH := 0x0114	; WM_HSCROLL (=scrollbar button press, by line very slow, by page fast, might need to be sent to the control, not just the window), docs.microsoft.com/en-us/windows/win32/controls/wm-hscroll
, scroll←Ln := 0	; SB_LINELEFT ; by one unit = click ←
, scroll←Pg := 2	; SB_PAGELEFT ; by window's width = click on the scroll bar
, scroll→Ln := 1	; SB_LINERIGHT
, scroll→Pg := 3	; SB_PAGERIGHT

; The scrolling function
FExpScrollH(FExpID := 0, Direction := "", ScrollUnit := "Ln", Rep := 1) {
  global msgScrollH, scroll←Ln, scroll←Pg, scroll→Ln, scroll→Pg

  RepMax := 20
  ; Delete these dbg helpers or copy the dbgTT/TT functions from a spoiler at the bottom of the post
  dbgTxt := FExpID " = FExpID`n" Direction " = Direction" "`n" ScrollUnit " = ScrollUnit`n" Rep " = Rep"
  errDir := "WARNING! Wrong Direction parameter" "`n" Direction " given, but should be" "`nL or" "`nR"
  errUnit := "WARNING! Wrong ScrollUnit parameter" "`n" ScrollUnit " given, but should be" "`nLn or" "`nPg"
  dbgTT(dbgMin := 1, Text := dbgTxt, Time := 2, id := 3, X := 1550, Y := 850)
  if (Direction != "L") and (Direction != "R")
    dbgTT(dbgMin := 1, Text := errDir, Time := 4, id := 2, x := -1, y := -1)
  if (ScrollUnit != "Ln") and (ScrollUnit != "Pg")
    dbgTT(dbgMin := 1, Text := errUnit, Time := 4, id := 2, x := -1, y := -1)

  if not IsInteger(Rep) or (Rep < 1) {
    Rep := 1
  } else if (Rep > RepMax) {
    Rep := RepMax
  }
  dir := Direction = "L" ? "←" : "→"
  by := ScrollUnit = "Ln" ? "Ln" : "Pg"

  MouseGetPos(&mX, &mY, &mWinID, &mCtrlClassNN)
  FExpScrollBarClass := "ScrollBar1"
  if (FExpID = 0)	; No File Explorer Active
    Return
  scrollBarID := ControlGetHwnd(FExpScrollBarClass, FExpID)
  if (scrollBarID = 0)	; No horizontal scrollbar
    Return

  Loop Rep {
    PostMessage(msgScrollH, scroll%dir%%by%, 0, scrollBarID, FExpID)
    ;        (Msg       , wParam         , lParam, Control     , WinTitle, WinText, ExcludeTitle, ExcludeText)
    ; wParam (word is 16 bytes, so HIWORD can be set as 'x << 16')
    ; HIWORD: (only if LOWORD is SB_THUMBPOSITION/SB_THUMBTRACK) current position
    ; LOWORD: user's scrolling request
    ; lParam: scroll bar control's handle (if used); NULL if sent by a standard scroll bar
  }
}

; Not sure whether ~ and & are useful here, see my question here https://www.autohotkey.com/boards/viewtopic.php?f=82&t=97264

; you can make these work only in File Explorers' windows or the function above could also work in a more generic LShift+WheelUp combo that allows passing scroll events on hover if mouse is hovering over File Explorer
#HotIf WinActive("ahk_class CabinetWClass")	; only in File Explorer's windows
~Shift & WheelUp::{	; Scroll left in File Explorer
    FExpID := WinActive("ahk_exe explorer.exe")
    ; comment out one of the two below
    Direction := "L", ScrollUnit := "Ln", Rep := 6	; scroll by line, slow, but can adjust the number of lines in the Rep variable to make it faster
    ; Direction := "L", ScrollUnit := "Pg", Rep := 1	; scroll by page, fast, but might be too fast
    FExpScrollH(FExpID, Direction, ScrollUnit, Rep)
  }
  ~Shift & WheelDown::{	; Scroll right in File Explorer
    FExpID := WinActive("ahk_exe explorer.exe")
    ; comment out one of the two below
    Direction := "R", ScrollUnit := "Ln", Rep := 6
    ; Direction := "R", ScrollUnit := "Pg", Rep := 1
    FExpScrollH(FExpID, Direction, ScrollUnit, Rep)
  }
#HotIf

dbgTT(dbgMin := 0, Text := "", Time := 0.5, idTT := 1, X := -1, Y := -1) {
  if (dbg >= dbgMin) {
    TT(Text, Time, idTT, X, Y)
  }
}
TT(Text := "", Time := 0.5, idTT := 1, X := -1, Y := -1) {
  MouseGetPos & mX, &mY, &mWin, &mControl
  ; mWin This optional parameter is the name of the variable in which to store the unique ID number of the window under the mouse cursor. If the window cannot be determined, this variable will be made blank.
  ; mControl This optional parameter is the name of the variable in which to store the name (ClassNN) of the control under the mouse cursor. If the control cannot be determined, this variable will be made blank.
  stepX := 0, stepY := 50	; offset each subsequent ToolTip # from mouse cursor
  xFlag := SubStr(X, 1, 1), yFlag := SubStr(Y, 1, 1)
  if (xFlag = "o") {
    stepX := SubStr(X, 2), X := -1
  }
  if (yFlag = "o") {
    stepY := SubStr(Y, 2), Y := -1
  }
  if (dbg > 2) {
    msgbox("X=" X " | xFlag=" xFlag " | stepX=" stepX "`n"
      "Y=" Y " | yFlag=" yFlag " | stepY=" stepY "`n"
      "SubStr:" SubStr("o200", 2))	;
  }

  if (X >= 0 && Y >= 0) {
    ToolTip(Text, X, Y, idTT)
  } else if (X >= 0) {
    ToolTip(Text, X, mY + stepY * (idTT - 1), idTT)
  } else if (Y >= 0) {
    ToolTip(Text, mX + stepX * (idTT - 1), Y, idTT)
  } else {
    ToolTip(Text, mX + stepX * (idTT - 1), mY + stepY * (idTT - 1), idTT)
  }
  SetTimer () => ToolTip(, , , idTT), -Time * 1000
}