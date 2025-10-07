
# ZenDo Flutter Starter (Aligned to your Figma)

Screens included: **Đăng nhập**, **Đăng ký**, **Home (Work/Family/Healthy/Social + Calendar + Pomodoro 25:00 + Task list)**, **Cài đặt**.

## Quick start

1. Create a new Flutter project (or unzip this into a folder).
2. Replace the `lib/` and `pubspec.yaml` with the ones here.
3. Run:
   ```bash
   flutter pub get
   flutter run
   ```

Packages used: `google_fonts`, `provider`, `shared_preferences`, `table_calendar`.

> Mapping Figma → Code:
> - "Đăng nhập/Đăng ký với Google/Apple" → buttons on SignIn/SignUp
> - "Work/Family/Healthy/Social" → FilterChips on Home
> - Calendar (September 2021 style) → `TableCalendar`
> - Timer "60:00" → PomodoroTimer (25:00 by default)
> - Settings texts (ngôn ngữ, phiên bản, đồng ý điều khoản) → SettingsPage

You can customize colors in `lib/theme.dart` (Material 3).
