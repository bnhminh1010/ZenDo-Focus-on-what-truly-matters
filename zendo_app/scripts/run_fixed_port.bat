@echo off
echo ========================================
echo    ZenDo - Fixed Port 3000 Server
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

echo.
echo Starting ZenDo on FIXED PORT 3000...
echo URL: http://localhost:3000
echo.
echo ⚠️  IMPORTANT: Configure Supabase OAuth with:
echo    Site URL: http://localhost:3000
echo    Redirect URL: http://localhost:3000
echo.

REM Chạy với port cố định và các tham số đảm bảo ổn định
flutter run -d web-server ^
  --web-port 3000 ^
  --web-hostname localhost ^
  --hot ^
  --dart-define=ENVIRONMENT=development ^
  --web-renderer html

echo.
echo Server stopped.
pause