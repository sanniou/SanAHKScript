PrintScreen:: {
   try
      Run "D:\scoop\apps\snipaste-beta\current\Snipaste.exe snip"
   catch
      MsgBox "Run command failed."
}

^PrintScreen:: {
   try
      Run "D:\scoop\apps\snipaste-beta\current\Snipaste.exe paste"
   catch
      MsgBox "Run command failed."
}

+PrintScreen:: {
   try
      Run "D:\scoop\apps\snipaste-beta\current\Snipaste.exe snip -o quick-save"
   catch
      MsgBox "Run command failed."
}