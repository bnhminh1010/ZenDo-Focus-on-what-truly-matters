@echo off
echo ========================================
echo    ZenDo Flutter Development Server
echo ========================================
echo.

REM Kiểm tra và kill process đang sử dụng port 3000
echo Checking if port 3000 is in use...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3000') do (
    echo Killing process %%a using port 3000...
    taskkill /PID %%a /F >nul 2>&1
)

REM Đợi 2 giây để đảm bảo port được giải phóng
timeout /t 2 /nobreak >nul

echo Starting ZenDo Flutter App...
echo Environment: Development
echo Base URL: http://localhost:3000
echo.

REM Kiểm tra Flutter có được cài đặt không
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter and add it to your PATH
    pause
    exit /b 1
)

REM Kiểm tra dependencies
echo Checking dependencies...
flutter pub get

REM Chạy ứng dụng web với cấu hình development
echo.
echo Starting web server on FIXED PORT 3000...
echo ⚠️  OAuth URLs: http://localhost:3000
echo Press Ctrl+C to stop the server
echo.

flutter run -d web-server --web-port 3000 --web-hostname localhost --hot --dart-define=ENVIRONMENT=development

echo.
echo Server stopped.
pause