!a::
	WinSet,Transparent,220,A
return

^!a::
	WinSet,Transparent,OFF,A
return

+!a::
	WinGet, windows, List,
	Loop, 100
	{
		ID := windows%A_Index%
		WinGetTitle title, ahk_id %ID%
		WinSet, Transparent, 220, %title%
	}
return
+^!a::
	WinGet, windows, List,
	Loop, 100
	{
		ID := windows%A_Index%
		WinGetTitle title, ahk_id %ID%
		WinSet, Transparent, OFF, %title%
	}
return
