insertMode := false

#If CheckCommandMode()
	$h:: WindowLeft()
	$j:: WindowDown()
	$k:: WindowUp()
	$l:: WindowRight()

	$/:: SearchWindow()
	$`;:: CommandWindow()
	
	$i:: VimInsert()
	$e:: VimEditAll()
	$v:: VimEditSelected()
#If

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


; ---- VIM TEXT ----


; ---- OTHER CNC ----

; - t(op) - toggles always on top 
; - a(lpha) - window transparency 

$p:: 
	if (CheckCommandMode())
	{
		run powershell
	}
	else
	{
		send p
	}
return

; -- WINDOW MOVEMENT KEYS --
; -- COMMAND AND SEARCH --


; cmdWord1 - the first word of the command string
; cmdRight - everything after the first word
; fullCommand - the entire command string for manual parsing
HandleCommand(cmdWord1, cmdRight, fullCommand)
{
	if (cmdWord1 = "echo")
	{
		MsgBox, %cmdRight%
	}
	else if (cmdWord1 = "web")
	{
		Run, chrome.exe `"%cmdRight%"
	}
}

RunFullCommand(fullCommand)
{
	StringGetPos, posFirstSpace, fullCommand, %A_Space%
	StringLeft, cmdWord1, fullCommand, posFirstSpace
	posFirstSpace += 1
	contents := SubStr(fullCommand, posFirstSpace)
	HandleCommand(cmdWord1, contents, fullCommand)
}

VimInsert()
{
	global insertMode
	
	;insertmode := true
	setcapslockstate off
	
	winId := WinExist("A")
	fileName := "c:\dwl\tmp\i" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName% 
	runwait, gvim.exe -c "startinsert" %fileName%, c:\
	FileRead, contents, %fileName% 
	StringRight, ending, contents, 2
	if ending = `r`n
		StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
	Clipboard := contents 
	WinActivate ahk_id %winId% 
	Send +{ins}
	contents = 
	FileDelete, %fileName%
	
	;insertMode := false
}

VimEditAll()
{
	global insertMode
	
	;insertmode := true
	setcapslockstate off
	
	winId := WinExist("A")
	Send ^{home}
	Send ^+{end}
	Send ^{ins}
	fileName := "c:\dwl\tmp\ea" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName% 
	FileAppend, %Clipboard%, %fileName%
	runwait, gvim.exe -c "call foreground()" %fileName%, c:\
	;runwait, gvim.exe %fileName%, c:\
	FileRead, contents, %fileName%
	StringRight, ending, contents, 2
		if ending = `r`n
	StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
	Clipboard := contents
	WinActivate ahk_id %winId% 
	Send +{ins}
	Send ^{home}
	contents = 
	FileDelete, %fileName%
	
	;insertMode := false
}

VimEditSelected()
{
	global insertMode
	
	insertMode := true
	SetCapsLockState off
	
	winId := WinExist("A")
	Send ^{ins}
	fileName := "c:\dwl\tmp\es" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName%
	FileAppend, %Clipboard%, %fileName%
	runwait, gvim.exe %fileName%, c:\
	FileRead, contents, %fileName%
	StringRight, ending, contents, 2
	if ending = `r`n
		StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
	Clipboard := contents 
	WinActivate ahk_id %winId% 
	Send +{ins}
	contents = 
	FileDelete, %fileName%
	
	insertMode := false
}

CommandWindow()
{
	global insertMode
	x := A_ScreenWidth - 400 * (A_ScreenDPI / 96)
	y := A_ScreenHeight - 100 * (A_ScreenDPI / 96)
	
	insertMode := true
	SetCapsLockState off
	InputBox, UserInput, command,,, 400,100, %x%, %y%
	
	insertMode := false

	; handle user input here
	RunFullCommand(UserInput)
}

SearchWindow()
{
	global insertMode
	x := A_ScreenWidth - 400 * (A_ScreenDPI / 96)
	y := A_ScreenHeight - 100 * (A_ScreenDPI / 96)
	
	insertMode := true
	SetCapsLockState off
	InputBox, UserInput, search,,, 400,100, %x%, %y%
	
	insertMode := false

	if (UserInput = "" OR ErrorLevel = 1)
		return

	; take out spaces and replace with + TODO: eventually make this ACTUALLY do URL encoding 
	StringReplace, UserInput, UserInput, %A_Space%, +, All

	Run, chrome.exe `"http://google.com/search?q=%UserInput%`" --disable-plugins --disable-extensions --enable-fast-unload --new-window --start-maximized
}

WindowLeft()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX - 100
	NewY := CurY 
	WinMove, A,, %NewX%, %NewY%
}

WindowDown()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX
	NewY := CurY + 100
	WinMove, A,, %NewX%, %NewY%
}

WindowUp()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX
	NewY := CurY - 100
	WinMove, A,, %NewX%, %NewY%
}

WindowRight()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX + 100
	NewY := CurY 
	WinMove, A,, %NewX%, %NewY%
}

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
