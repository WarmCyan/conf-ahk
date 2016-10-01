insertMode := false

; make ctrl backspace available in notepad and in ahk input boxes
#IfWinActive ahk_class Notepad
#IfWinActive ahk_class #32770
	^Backspace::
		Send ^+{Left}{Backspace}
	return
#IfWinActive

; ---- TRANSPARENCY ----
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

; ---- OTHER CNC ----

$j:: ; down
	if (CheckCommandMode())
	{
		WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
		NewX := CurX
		NewY := CurY + 100
		WinMove, A,, %NewX%, %NewY%
	}
	else
	{
		send j
	}
return

$k:: ; up
	if (CheckCommandMode())
	{
		WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
		NewX := CurX
		NewY := CurY - 100
		WinMove, A,, %NewX%, %NewY%
	}
	else
	{
		send k
	}
return

$h:: ; left
	if (CheckCommandMode())
	{
		WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
		NewX := CurX - 100
		NewY := CurY 
		WinMove, A,, %NewX%, %NewY%
	}
	else
	{
		send h
	}
return

$l:: ; right
	if (CheckCommandMode())
	{
		WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
		NewX := CurX + 100
		NewY := CurY 
		WinMove, A,, %NewX%, %NewY%
	}
	else
	{
		send l
	}
return

$`;::
global insertMode
	if (CheckCommandMode())
	{
		SysGet, monitorInfo, Monitor
		x := monitorInfoRight
		y := monitorInfoBottom
		x -= 400
		y -= 100
		
		insertMode := true
		SetCapsLockState off
		InputBox, UserInput, command,,, 400,100, %x%, %y%
		;SetCapsLockState on
		insertMode := false

		; handle user input here
		StringGetPos, posFirstSpace, UserInput, %A_Space%
		StringLeft, cmdWord1, UserInput, posFirstSpace

		posFirstSpace += 1

		if (cmdWord1 = "echo")
		{
			contents := SubStr(UserInput, posFirstSpace)
			MsgBox, %contents%
		}
		
		;if (UserInput == "echo
	}
	else
	{
		send `;
	}
return

$/::
global insertMode
	if (CheckCommandMode())
	{
		SysGet, monitorInfo, Monitor
		x := monitorInfoRight
		y := monitorInfoBottom
		x -= 400
		y -= 100
		
		insertMode := true
		SetCapsLockState off
		InputBox, UserInput, search,,, 400,100, %x%, %y%
		;SetCapsLockState on
		insertMode := false

		if (UserInput = "" OR ErrorLevel = 1)
			return

		; take out spaces and replace with %20
		StringReplace, UserInput, UserInput, %A_Space%, `%20, All

		Run, chrome.exe `"http://google.com/search?q=%UserInput%`" --disable-plugins --disable-extensions --enable-fast-unload --new-window --start-maximized
	}
	else
	{
		send /
	}
return



CheckCommandMode() 
{ 
	global insertMode
	caps := GetKeyState("CapsLock", "T") 
	scroll := GetKeyState("ScrollLock", "T")
	if (caps AND not scroll AND not insertMode) 
	{ 
		return true 
	}
	else 
	{ 
		return false 
	}
}
