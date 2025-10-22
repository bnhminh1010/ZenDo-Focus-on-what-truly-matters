# 🔐 Cấu hình OAuth Supabase với Port Cố định

## 🎯 Vấn đề
Mỗi lần chạy Flutter web development server, port có thể thay đổi ngẫu nhiên, gây ra lỗi OAuth redirect vì Supabase yêu cầu URL cố định.

## ✅ Giải pháp: Port Cố định 3000

### 1. 🚀 Chạy ứng dụng với port cố định
```bash
# Sử dụng script đã tạo
./run_fixed_port.bat

# Hoặc chạy trực tiếp
flutter run -d web-server --web-port 3000 --web-hostname localhost
```

### 2. ⚙️ Cấu hình Supabase Dashboard

Truy cập: https://supabase.com/dashboard/project/ewfjqvatkzeyccilxzne/auth/url-configuration

#### Site URL
```
http://localhost:3000
```

#### Redirect URLs
```
http://localhost:3000
http://localhost:3000/auth/callback
http://localhost:3000/#/auth/callback
```

### 3. 🔧 Cấu hình OAuth Providers

#### Google OAuth
- **Authorized JavaScript origins**: `http://localhost:3000`
- **Authorized redirect URIs**: 
  - `https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback`
  - `http://localhost:3000`

#### GitHub OAuth
- **Homepage URL**: `http://localhost:3000`
- **Authorization callback URL**: `https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback`

### 4. 📱 Cấu hình trong code

File: `lib/config/flutter_config.dart`
```dart
static const Map<String, dynamic> webConfig = {
  'port': 3000,  // Port cố định
  'hostname': 'localhost',
  'sourceMaps': true,
  'pwaStrategy': 'offline-first',
};
```

### 5. 🛠️ VS Code Launch Configuration

File: `.vscode/launch.json`
```json
{
  "name": "ZenDo Web (Development)",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": [
    "-d", "web-server",
    "--web-port", "3000",
    "--web-hostname", "localhost"
  ]
}
```

## 🔍 Kiểm tra Port

### Xem process đang sử dụng port 3000
```bash
netstat -ano | findstr :3000
```

### Kill process nếu cần
```bash
taskkill /PID <PID_NUMBER> /F
```

## 📋 Checklist

- [ ] Port 3000 được cấu hình trong `flutter_config.dart`
- [ ] Script `run_fixed_port.bat` được tạo
- [ ] Supabase Site URL: `http://localhost:3000`
- [ ] Supabase Redirect URLs được thêm
- [ ] Google OAuth được cấu hình
- [ ] GitHub OAuth được cấu hình
- [ ] VS Code launch config được cập nhật

## 🚨 Lưu ý quan trọng

1. **Luôn sử dụng port 3000** cho development
2. **Không thay đổi port** khi đã cấu hình OAuth
3. **Kill process cũ** nếu port bị chiếm dụng
4. **Kiểm tra firewall** nếu có vấn đề kết nối

## 🔗 URLs quan trọng

- **Development**: http://localhost:3000
- **Supabase Dashboard**: https://supabase.com/dashboard/project/ewfjqvatkzeyccilxzne
- **OAuth Config**: https://supabase.com/dashboard/project/ewfjqvatkzeyccilxzne/auth/url-configuration