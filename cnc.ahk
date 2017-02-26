insertMode := false

windowAdjustedX := 6
windowAdjustedWidth := 12
windowAdjustedHeight := 5

#If CheckCommandMode()
	$h:: MoveWindowLeft()
	$j:: MoveWindowDown()
	$k:: MoveWindowUp()
	$l:: MoveWindowRight()

	$+h:: SetWindowLeft()
	
	$W:: WindowModifier()

	$/:: SearchWindow()
	$`;:: CommandWindow()
	
	$i:: VimInsert()
	$e:: VimEditAll()
	$v:: VimEditSelected()
#If

; make ctrl backspace available in notepad and in ahk input boxes
#IfWinActive ahk_class #32770
	^Backspace::
		Send ^+{Left}{Backspace}
	return
#IfWinActive
#IfWinActive ahk_class Notepad
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
		setcapslockstate off
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
	else if (fullCommand = "")
	{
		run, conemu.exe
	}
	else if (fullCommand  = "py35")
	{
		run, conemu.exe "{REPL::Python3.5}"
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

	Clipsaved := clipboardall

	
	fileName := "c:\dwl\tmp\i" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName% 
	runwait, gvim.exe -c "startinsert" %fileName%, c:\
	
	FileRead, contents, %fileName% 
	StringRight, ending, contents, 2
	if ending = `r`n
		StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
		
	Clipboard := contents 
	Clipwait, 1
	
	WinActivate ahk_id %winId% 
	Send +{ins}
	
	FileDelete, %fileName%
	Sleep, 100

	Clipboard := clipsaved
	Clipwait, 1
	
	;insertMode := false
}

VimEditAll()
{
	global insertMode
	
	;insertmode := true
	setcapslockstate off
	
	winId := WinExist("A")

	Clipsaved := clipboardall

	Clipboard = 
	Send ^{home}
	Send ^+{end}
	Send ^{ins}	
	Clipwait, 1
	
	fileName := "c:\dwl\tmp\ea" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName% 
	;FileAppend, %Clipboard%, %fileName%
	FileAppend, %Clipboard%, %fileName%

	runwait, gvim.exe -c "call foreground()" %fileName%, c:\
	
	FileRead, contents, %fileName%
	StringRight, ending, contents, 2
		if ending = `r`n
	StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
	
	Clipboard := contents
	Clipwait, 1
	
	WinActivate ahk_id %winId% 
	Send +{ins}
	Send ^{home}	
	
	FileDelete, %fileName%
	Sleep, 100

	Clipboard := clipsaved
	Clipwait, 1
	
	;insertMode := false
}

VimEditSelected()
{
	global insertMode
	
	;insertMode := true
	SetCapsLockState off
	
	winId := WinExist("A")
	
	Clipsaved := clipboardall

	Clipboard = 
	Send ^{ins}
	Clipwait, 1

	fileName := "c:\dwl\tmp\es" . A_YYYY . A_MM . A_DD . A_Hour . A_Min . A_Sec . A_MSec
	FileDelete, %fileName%
	FileAppend, %Clipboard%, %fileName%
	runwait, gvim.exe %fileName%, c:\
	FileRead, contents, %fileName%
	StringRight, ending, contents, 2
	if ending = `r`n
		StringTrimRight, contents, contents, 2 ; remove last crlf from clipboard
		
	Clipboard := contents 
	Clipwait, 1
	
	WinActivate ahk_id %winId% 
	Send +{ins}
	
	FileDelete, %fileName%
	Sleep, 100

	Clipboard := clipsaved
	Clipwait, 1
	
	;insertMode := false
}

CommandWindow()
{
	global insertMode
	x := A_ScreenWidth - Screenify(400)
	y := A_ScreenHeight - Screenify(100)
	
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
	x := A_ScreenWidth - Screenify(400)
	y := A_ScreenHeight - Screenify(100)
	
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

SetWindowLeft()
{
	x := Screenify(-6)
	y := Screenify(0)
	WinMove, A,, x, y
}

SetWindowStarter()
{
	global windowAdjustedX
	global windowAdjustedWidth
	global windowAdjustedHeight

	Width := CalculateWindowWidthFraction(2)
	Height := CalculateWindowHeightFraction(1)
	;MsgBox, Width: %Width% Height: %Height%
	x := CalculateWindowXPosFraction(0, Width)
	y := CalculateWindowYPosFraction(0, Height)
	;MsgBox, x: %x% y: %y%

	; FIX 
	x := x - Screenify(windowAdjustedX)
	Width := Width + Screenify(windowAdjustedWidth)
	height := Height + Screenify(windowAdjustedHeight)
	; /FIX
	
	WinMove, A,, x, y, Width, Height
}

SetWindowFractionLeft()
{
	global windowAdjustedX
	global windowAdjustedWidth
	global windowAdjustedHeight
	
	; get num pos before changing width so can adjust to same num afterwards? (avoid bugs)
	WinGetPos, ,, CurWidth, , A

	; FIX
	CurWidth := CurWidth - Screenify(windowAdjustedWidth)
	; /FIX

	
	widthDenom := GetWindowWidthFraction(CurWidth)
	;MsgBox, current widthdenom: "%widthDenom%"
	widthDenom := widthDenom + 1
	;MsgBox, now: "%widthDenom%"
	Width := CalculateWindowWidthFraction(widthDenom)
	;MsgBox, %Width%

	; FIX
	Width := Width + Screenify(windowAdjustedWidth)
	; /FIX
	
	WinMove, A,,,, Width
}
SetWindowFractionRight()
{
	global windowAdjustedX
	global windowAdjustedWidth
	global windowAdjustedHeight
	
	; get num pos before changing width so can adjust to same num afterwards? (avoid bugs)
	WinGetPos, ,, CurWidth, , A

	; FIX
	CurWidth := CurWidth - Screenify(windowAdjustedWidth)
	; /FIX

	
	widthDenom := GetWindowWidthFraction(CurWidth)
	;MsgBox, current widthdenom: "%widthDenom%"
	widthDenom := widthDenom - 1
	;MsgBox, now: "%widthDenom%"
	Width := CalculateWindowWidthFraction(widthDenom)
	;MsgBox, %Width%

	; FIX
	Width := Width + Screenify(windowAdjustedWidth)
	; /FIX
	
	WinMove, A,,,, Width
}


ShiftWindowRight()
{
	global windowAdjustedX
	global windowAdjustedWidth
	global windowAdjustedHeight
	
	WinGetPos, CurX, , CurWidth, , A

	; FIX
	CurX := CurX + Screenify(windowAdjustedX)
	CurWidth := CurWidth - Screenify(windowAdjustedWidth)
	; /FIX

	;CurWidth := CurWidth + Screenify(6)
	num := GetWindowXPosFraction(CurX, CurWidth)
	;MsgBox, current widthdenom: "%num%"
	num := num + 1

	x := CalculateWindowXPosFraction(num, CurWidth)
	;MsgBox, %x%

	; FIX
	x := x - Screenify(windowAdjustedX)
	; /FIX
	
	WinMove, A, , x, ,
}
ShiftWindowLeft()
{
	global windowAdjustedX
	global windowAdjustedWidth
	global windowAdjustedHeight
	
	WinGetPos, CurX, , CurWidth, , A

	; FIX
	CurX := CurX + Screenify(windowAdjustedX)
	CurWidth := CurWidth - Screenify(windowAdjustedWidth)
	; /FIX

	;CurWidth := CurWidth + Screenify(6)
	num := GetWindowXPosFraction(CurX, CurWidth)
	num := num - 1

	x := CalculateWindowXPosFraction(num, CurWidth)
	;MsgBox, %x%

	; FIX
	x := x - Screenify(windowAdjustedX)
	; /FIX
	
	WinMove, A, , x, ,
}

MoveWindowLeft()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX - Screenify(100)
	NewY := CurY 
	WinMove, A,, %NewX%, %NewY%
}

MoveWindowDown()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX
	NewY := CurY + Screenify(100)
	WinMove, A,, %NewX%, %NewY%
}

MoveWindowUp()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX
	NewY := CurY - Screenify(100)
	WinMove, A,, %NewX%, %NewY%
}

MoveWindowRight()
{
	WinGetPos, CurX, CurY, , , A  ; "A" to get the active window's pos.
	NewX := CurX + Screenify(100)
	NewY := CurY 
	WinMove, A,, %NewX%, %NewY%
}

; TODO: with shift down, that changes location, without shift down, change sizing
WindowModifier()
{
	global insertMode
	
	insertMode := true

	while (true)
	{
		Input, keyInput, L1 T2, {Enter}{CapsLock}{Tab}
		if (ErrorLevel = "EndKey:Enter" or ErrorLevel = "EndKey:CapsLock")
		{
			;MsgBox, "Should break out now"
			Break
		}


		GetKeyState, shiftState, Shift, P
		GetKeyState, stateh, h, P
		GetKeyState, statej, j, P
		GetKeyState, statek, k, P
		GetKeyState, statel, l, P
		GetKeyState, stateSpace, Space, P
		GetKeyState, stateTab, Tab, P
		;stateh := GetKeyState(h)
		;statej := GetKeyState("j")
		;statek := GetKeyState("k")
		;statel := GetKeyState("l")
		;stateSpace := GetKeyState("Space")
		;shiftState := GetKeyState("Shift", "T")
		if (stateSpace = "D")
		{
			SetWindowStarter()
		}
		if (stateTab = "D")
		{
			Send !{Tab}
		}
		if (shiftState = "U" and statel = "D")
		{
			;SetWindowLeft()
			ShiftWindowRight()
		}
		if (shiftState = "U" and stateh = "D")
		{
			ShiftWindowLeft()
		}
		if (shiftState = "D" and stateh = "D")
		{
			SetWindowFractionLeft()
		}
		if (shiftState = "D" and statel = "D")
		{
			SetWindowFractionRight()
		}
	}

	;MsgBox, "finished"
	SetCapsLockState off

	insertMode := false
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

CalculateWindowWidthFraction(denom)
{
	pixels := A_ScreenWidth / denom
	;return round(pixels + Screenify(12))
	;return round(pixels + Screenify(12))
	return round(pixels)
}
CalculateWindowHeightFraction(denom)
{
	pixels := A_ScreenHeight / denom
	;return round(pixels + Screenify(5))
	return round(pixels)
}

GetWindowWidthFraction(width)
{
	;denom := A_ScreenWidth / Screenify(width)
	denom := A_ScreenWidth / width
	return round(denom)
}

GetWindowHeightFraction(height)
{
	;denom := A_Screeneight / Screenify(height)
	denom := A_ScreenHeight / height
	return round(denom)
}

CalculateWindowXPosFraction(num, width)
{
	;return round(num * width) - Screenify(6)
	;return round(num * width) - Screenify(18)
	return round(num * width)
}
CalculateWindowYPosFraction(num, height)
{
	return round(num * height)
}

; gives you the "numerator"?
GetWindowXPosFraction(x, width)
{
;	denom := GetWindowWidthFraction(width)
	return round(x / width)
}
GetWindowYPosFraction(y, height)
{
	return round(y / height)
}

Screenify(pixels)
{
	return pixels * (A_ScreenDPI / 96)
}

