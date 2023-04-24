Menu, MenuName, UseErrorLevel ; Prevent Menu command errors from stopping script.
i := 0
j := "    "
WinGet, OpenWindow, List ; Get all windows.
Loop, %OpenWindow% ; For each one...
{
	WinGetTitle, Title, % "ahk_id " OpenWindow%A_Index% ; Get the window title, save as %Title%.
	WinGetClass, Class, % "ahk_id " OpenWindow%A_Index% ; For making sure [Class != "BasicWindow"] later.
	WinGet, WindowPath, ProcessPath, %Title% ; Get the full path to the process running the window, save as %WindowPath% to get the icon later.
	
	If (Title != "" and Class != "BasicWindow" and Title != "Start" and Title != "Program Manager" and Title != "BBar") ; If the window doesn't match any of these "system" window conditions, add it to the list.
	{
		i++
		If i > 9
			j := "  " ; format spacing
		; Generate the text for the menu item with the number i, spacing j, the window title with any pipelines removed, a pipeline, and the process ID.
		; The Process ID is required to handle different windows with the same name, such as multiple 'Untitled - Notepad's.
		MenuItemText := % i j RegExReplace(Title,"\|", Replacement := "") . " | " . OpenWindow%A_Index% 
		Menu, WindowMenu, Insert,, %MenuItemText%, MenuHandler ; Append the new menu item. Activate MenuHandler if the item is clicked.
		Menu, WindowMenu, Icon, %MenuItemText%, %WindowPath% ; Add the matching icon to the menu item.
	}
}
CoordMode, Mouse
CoordMode, Menu
MouseGetPos, xpos, ypos
Menu, WindowMenu, Show, % xpos-150, % ypos-75 ; Display the menu of running apps near the mouse pointer.

MenuHandler:
ProcessID := "ahk_id " RegExReplace(A_ThisMenuItem, ".*\| ", Replacement := "") ; Create variable %ProcessID% using the literal text "ahk_id " plus the Process ID (regex removing everything else in the string).

; For the chosen window: activate it, restore it (because maximized/minimized windows don't move), get its dimensions, center the title bar on the mouse.
WinActivate, %ProcessID%
WinGetTitle, Title, %ProcessID%
If Title contains Remote Desktop Connection ; Maximized RDP windows don't respond to WinRestore properly. AHK documentation says to use this command instead.
	PostMessage, 0x0112, 0xF120,,, %ProcessID%  ; 0x0112 = WM_SYSCOMMAND, 0xF120 = SC_RESTORE 
else
	WinRestore, %ProcessID%
Sleep 10
MouseGetPos, xpos, ypos
WinGetPos,,, Width, Height, %ProcessID%
WinMove, %ProcessID%,, % xpos-Width/2, % ypos-15