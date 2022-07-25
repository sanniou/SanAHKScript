#SingleInstance Force
Persistent

option := 2
/*
option -> 0 = off
          1 = gradient    (+color)
          2 = transparent (+color)
          3 = blur
 */
gradient := "0x3f3f3f3f"
;gradient  -> ABGR (alpha | blue | green | red) 0xffd7a78f

TaskBar_SetAttr(option, gradient)
CLSID_AppVisibility := "{7E5FE3D9-985F-4908-91F9-EE19F9FD1514}"
IID_IAppVisibility := "{2246EA2D-CAEA-4444-A3C4-6DE827E44313}"
AppVisibility := ComObject(CLSID_AppVisibility, IID_IAppVisibility)

If (AppVisibility) {
   OnExit(AtExit)
   ; Advise - point AppVisibility to a COM object that has a function that will receive the notifications
   ComCall(5, AppVisibility, "Ptr", IAppVisibilityEvents_createSingleInstance(), "UInt*", &Cookie := 0)
} Else {
   MsgBox("Couldn't create the interface!")
   ExitApp
}

IAppVisibilityEvents_createSingleInstance() {
   Static IAppVisibilityEvents, VTable
   If !IsSet(IAppVisibilityEvents) {
      IUnknownFuncs := ["QueryInterface", "AddRef", "Release"]
      IAppVisibilityEventsFuncs := ["AppVisibilityOnMonitorChanged", "LauncherVisibilityChange"]
      VTableEntries := IUnknownFuncs.Length + IAppVisibilityEventsFuncs.Length
      VTable := Buffer(VTableEntries * A_PtrSize, 0)
      VTablePtr := VTable.Ptr
      ; I leave freeing these callback pointers, and IAppVisibilityEvents itself, to you. But I wouldn't bother, personally
      For Name in IUnknownFuncs
         VTablePtr := NumPut("UPtr", CallbackCreate(IAppVisibilityEvents_%Name%), VTablePtr)
      For Name in IAppVisibilityEventsFuncs
         VTablePtr := NumPut("UPtr", CallbackCreate(IAppVisibilityEvents_%Name%), VTablePtr)
      IAppVisibilityEvents := Buffer(A_PtrSize, 0)
      NumPut("UPtr", VTable.Ptr, IAppVisibilityEvents)
   }
   Return IAppVisibilityEvents.Ptr
}

IAppVisibilityEvents_QueryInterface(this_, riid, ppvObject) {
   Static IID_IUnknown, IID_IAppVisibilityEvents
   If !IsSet(IID_IUnknown) {
      IID_IUnknown := Buffer(16, 0)
      IID_IAppVisibilityEvents := Buffer(16, 0)
      DllCall("ole32\CLSIDFromString", "WStr", "{00000000-0000-0000-C000-000000000046}", "Ptr", IID_IUnknown)
      DllCall("ole32\CLSIDFromString", "WStr", "{6584CE6B-7D82-49C2-89C9-C6BC02BA8C38}", "Ptr", IID_IAppVisibilityEvents)
   }
   If (DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", IID_IAppVisibilityEvents) || DllCall("ole32\IsEqualGUID", "Ptr", riid, "Ptr", IID_IUnknown)) {
      NumPut("UPtr", this_, ppvObject, "Ptr")
      Return 0	; S_OK
   }
   NumPut("Ptr", 0, ppvObject)
   Return 0x80004002	; E_NOINTERFACE
}
IAppVisibilityEvents_AddRef(this_) => 1
IAppVisibilityEvents_Release(this_) => 1
IAppVisibilityEvents_AppVisibilityOnMonitorChanged(this_, hMonitor, previousMode, currentMode) => 0

IAppVisibilityEvents_LauncherVisibilityChange(this_, currentVisibleState) {
   Loop 10
   {
      TaskBar_SetAttr(option, gradient)
      Sleep 10
   }
   Return 0
}

AtExit(*) {
   global AppVisibility, Cookie
   OnExit(AtExit, 0)
   If (AppVisibility) {
      If (Cookie) {
         ComCall(6, AppVisibility, "UInt", Cookie)
         Cookie := 0
      }
      AppVisibility := 0
   }
   Return 0
}

TaskBar_SetAttr(accent_state := 0, gradient_color := "0x01000000")
{
   static init := 0, hTrayWnd := "", ver := DllCall("GetVersion") & 0xff < 10
   static pad := A_PtrSize = 8 ? 4 : 0, WCA_ACCENT_POLICY := 19

   if (!init) {
      if (ver)
         throw Error("Minimum support client: Windows 10", -1)
      if (!hTrayWnd := DllCall("user32\FindWindow", "str", "Shell_TrayWnd", "ptr", 0, "ptr"))
         throw Error("Failed to get the handle", -1)
      init := 1
   }
   ACCENT_POLICY := Buffer(16, 0)
   NumPut("int", (accent_state > 0 && accent_state < 4) ? accent_state : 0, ACCENT_POLICY, 0)

   if (accent_state >= 1) && (accent_state <= 2) && (RegExMatch(gradient_color, "0x[[:xdigit:]]{8}"))
      NumPut("int", gradient_color, ACCENT_POLICY, 8)

   WINCOMPATTRDATA := Buffer(4 + pad + A_PtrSize + 4 + pad, 0)
   NumPut("int", WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0)
   NumPut("ptr", ACCENT_POLICY.ptr, WINCOMPATTRDATA, 4 + pad)
   NumPut("uint", ACCENT_POLICY.Size, WINCOMPATTRDATA, 4 + pad + A_PtrSize)
   if !(DllCall("user32\SetWindowCompositionAttribute", "ptr", hTrayWnd, "ptr", WINCOMPATTRDATA))
      throw Error("Failed to set transparency / blur", -1)
   return true
}