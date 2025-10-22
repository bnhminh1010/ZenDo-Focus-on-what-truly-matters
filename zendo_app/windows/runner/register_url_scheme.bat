@echo off
echo Registering ZenDo custom URL scheme for development...

:: Get current directory
set CURRENT_DIR=%~dp0
set EXE_PATH=%CURRENT_DIR%..\..\build\windows\x64\runner\Debug\zendo_app.exe

:: Create registry entries for development
reg add "HKEY_CLASSES_ROOT\com.zendo.app" /ve /d "URL:ZenDo App Protocol" /f
reg add "HKEY_CLASSES_ROOT\com.zendo.app" /v "URL Protocol" /d "" /f
reg add "HKEY_CLASSES_ROOT\com.zendo.app\DefaultIcon" /ve /d "\"%EXE_PATH%\",1" /f
reg add "HKEY_CLASSES_ROOT\com.zendo.app\shell\open\command" /ve /d "\"%EXE_PATH%\" \"%%1\"" /f

echo Custom URL scheme registered successfully!
echo You can now use com.zendo.app:// URLs with this application.
pause