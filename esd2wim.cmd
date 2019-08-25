@ECHO off

SET SRC_PATH="install.esd"
SET DST_PATH="install.wim"

:CheckPermissions
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    GOTO IndexAnalyzer 
) ELSE (
	COLOR 4
	ECHO. ======================
	ECHO.
    ECHO. Please "Run as Admin"!
	ECHO.
	ECHO. ======================
    PAUSE
    EXIT 1
)

:IndexAnalyzer
setlocal EnableDelayedExpansion
SET /A count=0
FOR /F "tokens=2 delims=: " %%i IN ('DISM /Get-WimInfo /WimFile:"%SRC_PATH%" /English ^| findstr "Index"') DO SET images=%%i
FOR /L %%i in (1, 1, %images%) DO (CALL :IndexCounter %%i)
GOTO ExportSingleIndex

:IndexCounter
SET /A count+=1
FOR /f "tokens=1* delims=: " %%i IN ('DISM /Get-WimInfo /WimFile:"%SRC_PATH%" /Index:%1 /English ^| find /i "Name"') DO SET name%count%=%%j
EXIT /B

:ExportSingleIndex
CLS
ECHO Please enter the Index number you want to export.
ECHO.
FOR /L %%i IN (1, 1, %images%) DO (ECHO.  [%%i] !name%%i!)
ECHO.
ECHO.
SET /P INDEXCHOICE= Your choice:  
CLS

:DEL_DST_PATH
IF EXIST %DST_PATH% (
	DEL /F %DST_PATH%
)

:EXPORTING
ECHO Exporting Index %INDEXCHOICE% . . .
DISM /Export-Image /SourceImageFile:"%SRC_PATH%" /Sourceindex:%INDEXCHOICE% /DestinationImageFile:"%DST_PATH%" /Compress:max /CheckIntegrity

PAUSE
