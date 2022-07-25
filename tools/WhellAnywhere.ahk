CoordMode "Mouse", "Screen"

MonitorCount := MonitorGetCount()

MonitorPositionArray := Array()
Loop MonitorCount
{
	MonitorGet A_Index, &Left, &Top, &Right, &Bottom
	grid := MonitorPosition(Left, Top, Right, Bottom)
	MonitorPositionArray.Push grid
}

Offset := 10

; < lower for a more granular change, higher for larger jump in brightness
Increments := 5

#HotIf MouseIsPosition(MonitorPositionArray, "Left", "Top")
WheelUp:: send "{Volume_Up}"
WheelDown:: send "{Volume_Down}"
MButton:: SoundSetMute -1
/* ~LControl & N:: {
	ToolTip("dfd")
	title := WinGetTitle("ahk_exe lx-music-desktop.exe ahk_class Chrome_WidgetWin_1")
	ToolTip(title)
	SetTimer () => ToolTip(), -5000
} */

#HotIf MouseIsPosition(MonitorPositionArray, "Right", "Top")
WheelUp:: send "{Media_Prev}"
WheelDown:: send "{Media_Next}"
MButton:: send "{Media_Play_Pause}"

; 在任务栏上滚动滚轮: 增加/减小音量.
#HotIf MouseIsOver("ahk_class Shell_TrayWnd") or MouseIsOver("ahk_class Shell_SecondaryTrayWnd")
WheelUp:: Send "{Volume_Up}"
WheelDown:: Send "{Volume_Down}"

#HotIf MouseIsPosition(MonitorPositionArray, "Left", "Top")
~LControl & WheelUp::ChangeBrightness(GetCurrentBrightNess() + Increments)
	~LControl & WheelDown::ChangeBrightness(GetCurrentBrightNess() - Increments)
	~LControl & MButton::ChangeBrightness(50)	; default

MouseIsOver(WinTitle) {
	MouseGetPos , , &Win
	return WinExist(WinTitle " ahk_id " Win)
}

MouseIsPosition(MonitorArray, Expression, Expression2)
{
	MouseGetPos & xpos, &ypos
	IsPosition := false
	Loop MonitorArray.Length {
		MonitorPositionI := MonitorArray[A_Index]
		FirstCheck := abs(xpos - MonitorPositionI.%Expression%) < Offset
		SecondCheck := abs(ypos - MonitorPositionI.%Expression2%) < Offset
		IsPosition := IsPosition or (FirstCheck and SecondCheck)
		; TrayTip "IsPosition=" IsPosition " Expression = "  MonitorPositionI.%Expression% " Expression2 = "  MonitorPositionI.%Expression2% "First " FirstCheck  "Seconds" SecondCheck
	}
	return IsPosition	;
}

ChangeBrightness(brightness, timeout := 1)
{
	if (brightness > 100)
	{
		brightness := 100
	} else if (brightness < 0)
	{
		brightness := 0
	}
	For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods")
		property.WmiSetBrightness(timeout, brightness)
}

GetCurrentBrightNess()
{
	For property in ComObjGet("winmgmts:\\.\root\WMI").ExecQuery("SELECT * FROM WmiMonitorBrightness")
		currentBrightness := property.CurrentBrightness

	return currentBrightness
}

class MonitorPosition
{
	Left := 0
	Top := 0
	Right := 0
	Bottom := 0

	__new(l, t, r, b) {
		this.Left := l
		this.Top := t
		this.Right := r
		this.Bottom := b
	}

}