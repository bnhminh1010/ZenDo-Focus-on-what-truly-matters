# TÀI LIỆU DATABASE SCHEMA - ZENDO

## 📋 TỔNG QUAN

ZenDo là ứng dụng quản lý công việc và tập trung (task management & focus app) được xây dựng với Flutter và Supabase. Database được thiết kế để hỗ trợ đầy đủ các tính năng quản lý task, pomodoro timer, thống kê năng suất và nhiều tính năng nâng cao khác.

## 🏗️ KIẾN TRÚC DATABASE

### Công nghệ sử dụng:
- **Database**: PostgreSQL (thông qua Supabase)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime
- **Storage**: Supabase Storage (cho file đính kèm)

### Các Extension được sử dụng:
- `uuid-ossp`: Tạo UUID tự động
- `pg_trgm`: Tối ưu tìm kiếm văn bản

## 📊 CÁC ENUM TYPES

### 1. `task_priority` - Mức độ ưu tiên task
```sql
'low', 'medium', 'high', 'urgent'
```

### 2. `task_status` - Trạng thái task
```sql
'pending', 'in_progress', 'completed', 'cancelled'
```

### 3. `focus_session_status` - Trạng thái phiên tập trung
```sql
'active', 'paused', 'completed', 'cancelled'
```

### 4. `notification_type` - Loại thông báo
```sql
'task_reminder', 'focus_break', 'daily_summary', 'achievement'
```

### 5. `achievement_type` - Loại thành tích
```sql
'task_completion', 'focus_streak', 'productivity_milestone', 'consistency'
```

## 🗂️ CÁC BẢNG CHÍNH

### 1. `profiles` - Thông tin người dùng
**Mục đích**: Mở rộng thông tin từ `auth.users` của Supabase

**Các trường quan trọng**:
- `id`: Liên kết với `auth.users(id)`
- `email`: Email người dùng (unique)
- `full_name`, `name`: Tên đầy đủ và tên hiển thị
- `avatar_url`: URL ảnh đại diện
- `timezone`, `language`: Múi giờ và ngôn ngữ
- `is_premium`: Tài khoản premium hay không
- **Thống kê**:
  - `total_tasks_completed`: Tổng số task đã hoàn thành
  - `total_focus_minutes`: Tổng thời gian tập trung (phút)
  - `current_streak_days`: Chuỗi ngày liên tiếp hiện tại
  - `longest_streak_days`: Chuỗi ngày dài nhất

### 2. `categories` - Danh mục công việc
**Mục đích**: Phân loại và tổ chức các task

**Các trường quan trọng**:
- `user_id`: Liên kết với người dùng
- `name`: Tên danh mục (unique per user)
- `icon`: Icon emoji cho danh mục
- `color`: Màu sắc đại diện
- `is_default`: Danh mục mặc định hay không
- `sort_order`: Thứ tự sắp xếp
- `is_archived`: Đã lưu trữ hay chưa

**Danh mục mặc định**: Công việc 💼, Cá nhân 👤, Học tập 📚

### 3. `tasks` - Công việc chính
**Mục đích**: Lưu trữ tất cả thông tin về các task

**Thông tin cơ bản**:
- `title`: Tiêu đề task (bắt buộc, 1-500 ký tự)
- `description`: Mô tả chi tiết
- `notes`: Ghi chú thêm
- `category_id`: Liên kết với danh mục
- `parent_task_id`: Task cha (cho subtask)

**Phân loại và trạng thái**:
- `priority`: Mức độ ưu tiên (low/medium/high/urgent)
- `status`: Trạng thái (pending/in_progress/completed/cancelled)
- `is_important`, `is_urgent`: Cờ quan trọng/khẩn cấp
- `is_completed`: Đã hoàn thành hay chưa

**Thời gian**:
- `created_at`, `updated_at`: Thời gian tạo/cập nhật
- `due_date`: Hạn chót
- `start_date`: Ngày bắt đầu
- `completed_at`: Thời gian hoàn thành
- `estimated_minutes`: Thời gian ước tính (phút)
- `actual_minutes`: Thời gian thực tế (phút)

**Tính năng nâng cao**:
- `is_recurring`: Task lặp lại hay không
- `recurring_config`: Cấu hình lặp lại (JSON)
- `tags`: Mảng các tag
- `attachments`: File đính kèm (JSON)
- `external_links`: Liên kết ngoài

### 4. `subtasks` - Công việc con
**Mục đích**: Chia nhỏ task lớn thành các task nhỏ hơn

**Các trường chính**:
- `task_id`: Liên kết với task cha
- `title`: Tiêu đề subtask
- `is_completed`: Trạng thái hoàn thành
- `sort_order`: Thứ tự sắp xếp

### 5. `focus_sessions` - Phiên tập trung
**Mục đích**: Theo dõi các phiên làm việc tập trung (Pomodoro)

**Thông tin phiên**:
- `task_id`: Task liên quan (có thể null)
- `title`: Tiêu đề phiên tập trung
- `planned_duration_minutes`: Thời gian dự kiến (mặc định 25 phút)
- `actual_duration_minutes`: Thời gian thực tế
- `break_duration_minutes`: Thời gian nghỉ

**Thời gian và trạng thái**:
- `started_at`: Thời gian bắt đầu
- `ended_at`: Thời gian kết thúc
- `paused_at`: Thời gian tạm dừng
- `total_pause_duration_minutes`: Tổng thời gian tạm dừng
- `status`: Trạng thái phiên
- `session_type`: Loại phiên (pomodoro/deep_work/break)

**Đánh giá năng suất**:
- `productivity_rating`: Đánh giá từ 1-5 sao
- `distraction_count`: Số lần bị phân tâm
- `notes`: Ghi chú về phiên
- `background_sound`: Âm thanh nền

### 6. `user_settings` - Cài đặt người dùng
**Mục đích**: Lưu trữ tất cả preferences của user

**Cài đặt ứng dụng**:
- `theme`: Giao diện (light/dark/system)
- `language`: Ngôn ngữ (mặc định 'vi')
- `timezone`: Múi giờ

**Cài đặt Pomodoro**:
- `pomodoro_work_duration`: Thời gian làm việc (mặc định 25 phút)
- `pomodoro_short_break`: Nghỉ ngắn (mặc định 5 phút)
- `pomodoro_long_break`: Nghỉ dài (mặc định 15 phút)
- `pomodoro_sessions_until_long_break`: Số phiên trước khi nghỉ dài

**Cài đặt thông báo**:
- `notifications_enabled`: Bật thông báo
- `task_reminders_enabled`: Nhắc nhở task
- `focus_break_reminders_enabled`: Nhắc nghỉ giải lao
- `daily_summary_enabled`: Tóm tắt hàng ngày
- `email_notifications_enabled`: Thông báo email

**Mặc định cho task**:
- `default_task_priority`: Mức độ ưu tiên mặc định
- `default_estimated_minutes`: Thời gian ước tính mặc định
- `auto_archive_completed_tasks_days`: Tự động lưu trữ task sau X ngày

**Giao diện**:
- `show_completed_tasks`: Hiển thị task đã hoàn thành
- `default_task_view`: Chế độ xem mặc định (list/kanban/calendar)
- `sidebar_collapsed`: Thu gọn sidebar

## 🚀 CÁC BẢNG TÍNH NĂNG NÂNG CAO

### 7. `tags` - Thẻ tag
**Mục đích**: Quản lý các tag để gắn cho task

- `name`: Tên tag (unique per user, 1-50 ký tự)
- `color`: Màu sắc tag
- `usage_count`: Số lần sử dụng (tự động cập nhật)

### 8. `task_tags` - Liên kết Task-Tag
**Mục đích**: Bảng junction để liên kết many-to-many giữa task và tag

### 9. `notifications` - Thông báo
**Mục đích**: Hệ thống thông báo và nhắc nhở

**Các trường chính**:
- `type`: Loại thông báo
- `title`, `message`: Tiêu đề và nội dung
- `scheduled_for`: Thời gian lên lịch
- `sent_at`: Thời gian đã gửi
- `is_read`, `is_sent`: Trạng thái đọc/gửi
- `metadata`: Dữ liệu bổ sung (JSON)

### 10. `achievements` - Thành tích
**Mục đích**: Hệ thống gamification và động lực

**Các trường chính**:
- `type`: Loại thành tích
- `title`, `description`: Tiêu đề và mô tả
- `icon`: Icon thành tích
- `target_value`: Giá trị mục tiêu
- `current_value`: Giá trị hiện tại
- `is_unlocked`: Đã mở khóa chưa
- `unlocked_at`: Thời gian mở khóa

### 11. `activity_logs` - Nhật ký hoạt động
**Mục đích**: Theo dõi và phân tích hành vi người dùng

**Các trường chính**:
- `action`: Hành động (task_created, task_completed, etc.)
- `entity_type`, `entity_id`: Loại và ID đối tượng
- `details`: Chi tiết (JSON)
- `ip_address`, `user_agent`: Thông tin kỹ thuật

### 12. `task_templates` - Mẫu task
**Mục đích**: Tạo template cho các task thường xuyên

**Các trường chính**:
- `name`: Tên template
- `title_template`, `description_template`: Mẫu tiêu đề và mô tả
- `default_priority`: Mức độ ưu tiên mặc định
- `default_estimated_minutes`: Thời gian ước tính mặc định
- `default_tags`: Tags mặc định
- `is_public`: Công khai hay riêng tư
- `usage_count`: Số lần sử dụng

## 🔍 INDEXES VÀ TỐI ƯU HIỆU SUẤT

### Indexes quan trọng:
1. **Tasks**: user_id, category_id, status, priority, due_date, completed
2. **Text Search**: title và description sử dụng GIN index
3. **Tags**: GIN index cho mảng tags
4. **Focus Sessions**: user_id, task_id, started_at, status
5. **Notifications**: user_id, scheduled_for, is_read

### Tối ưu tìm kiếm:
- Full-text search cho title và description
- Trigram search cho tìm kiếm gần đúng
- Array search cho tags

## ⚡ FUNCTIONS VÀ TRIGGERS

### 1. `handle_updated_at()`
**Mục đích**: Tự động cập nhật trường `updated_at` khi record thay đổi

### 2. `handle_new_user()` ⚡ **[CẬP NHẬT MỚI]**
**Mục đích**: Tự động tạo profile và dữ liệu mặc định khi user đăng ký

**Trigger**: `AFTER INSERT ON auth.users`

**Chức năng**:
- Tạo record trong `profiles` (bypass RLS)
- Tạo `user_settings` mặc định
- Tạo 3 categories mặc định: "Công việc", "Cá nhân", "Học tập"

**Đặc điểm quan trọng**:
- `SECURITY DEFINER SET search_path = public`: Chạy với quyền cao để bypass RLS
- Giải quyết vấn đề RLS khi tạo profile mới cho user vừa đăng ký
- Đảm bảo tính nhất quán dữ liệu khi khởi tạo user mới

### 3. `update_task_completion_stats()`
**Mục đích**: Cập nhật thống kê khi task được hoàn thành/bỏ hoàn thành

**Logic**:
- Tăng `total_tasks_completed` khi task hoàn thành
- Giảm `total_tasks_completed` khi bỏ hoàn thành
- Tự động set `actual_minutes` nếu chưa có
- Tự động set `completed_at`

### 4. `update_focus_stats()`
**Mục đích**: Cập nhật thống kê thời gian tập trung

**Logic**:
- Cộng `actual_duration_minutes` vào `total_focus_minutes` khi session completed

### 5. `update_tag_usage()`
**Mục đích**: Cập nhật số lần sử dụng tag

**Logic**:
- Tăng `usage_count` khi thêm tag vào task
- Giảm `usage_count` khi xóa tag khỏi task

## 🔒 BẢO MẬT - ROW LEVEL SECURITY (RLS)

### Nguyên tắc bảo mật:
1. **Isolation**: Mỗi user chỉ truy cập được dữ liệu của mình
2. **Authentication**: Tất cả operations yêu cầu đăng nhập
3. **Authorization**: Kiểm tra quyền trên từng record

### RLS Policies cho từng bảng:

#### `profiles` ⚡ **[CẬP NHẬT MỚI]**
- **SELECT**: User chỉ xem được profile của mình (`auth.uid() = id`)
- **INSERT**: User tạo profile của mình HOẶC service_role bypass RLS (`auth.uid() = id OR auth.role() = 'service_role'`)
- **UPDATE**: User chỉ sửa được profile của mình (`auth.uid() = id`)

**Lý do cập nhật**: Cho phép `service_role` bypass RLS khi function `handle_new_user()` tạo profile mới, giải quyết lỗi "new row violates row-level security policy".

#### `categories`, `tasks`, `subtasks`, `focus_sessions`, `user_settings`, `tags`, `notifications`, `achievements`, `activity_logs`, `task_templates`
- **SELECT/INSERT/UPDATE/DELETE**: Chỉ truy cập records có `user_id` = `auth.uid()`

#### `task_tags`
- **SELECT/INSERT/DELETE**: Chỉ truy cập qua `task_id` thuộc về user

## 📈 VIEWS VÀ BÁO CÁO

### 1. `task_statistics` - Thống kê task
```sql
SELECT 
    user_id,
    COUNT(*) as total_tasks,
    COUNT(*) FILTER (WHERE is_completed) as completed_tasks,
    COUNT(*) FILTER (WHERE NOT is_completed) as pending_tasks,
    COUNT(*) FILTER (WHERE priority = 'high') as high_priority_tasks,
    COUNT(*) FILTER (WHERE due_date < NOW()) as overdue_tasks
FROM tasks 
GROUP BY user_id;
```

### 2. `daily_productivity` - Năng suất hàng ngày
```sql
SELECT 
    user_id,
    DATE(created_at) as date,
    COUNT(*) as tasks_created,
    COUNT(*) FILTER (WHERE is_completed) as tasks_completed,
    SUM(actual_minutes) as total_minutes_worked
FROM tasks 
GROUP BY user_id, DATE(created_at);
```

### 3. `table_sizes` - Monitoring kích thước bảng
Theo dõi thống kê và kích thước các bảng để tối ưu hiệu suất.

## 🛠️ MAINTENANCE VÀ CLEANUP

### 1. `archive_old_completed_tasks()`
**Mục đích**: Lưu trữ các task đã hoàn thành lâu

### 2. `cleanup_old_activity_logs()`
**Mục đích**: Xóa logs cũ để tiết kiệm dung lượng

### 3. `update_user_streaks()`
**Mục đích**: Cập nhật chuỗi ngày liên tiếp của user

## 🔧 TROUBLESHOOTING & GIẢI QUYẾT VẤN ĐỀ

### ⚠️ Vấn đề RLS Policy (Đã giải quyết)

**Lỗi**: `PostgrestException: new row violates row-level security policy for table "profiles"`

**Nguyên nhân**: 
- RLS policy quá strict cho INSERT operation
- Function `handle_new_user()` không thể bypass RLS khi tạo profile mới

**Giải pháp đã áp dụng**:
1. **Cập nhật INSERT Policy**:
   ```sql
   CREATE POLICY "Users can insert own profile" ON public.profiles
       FOR INSERT WITH CHECK (auth.uid() = id OR auth.role() = 'service_role');
   ```

2. **Cải thiện Function Security**:
   ```sql
   CREATE OR REPLACE FUNCTION public.handle_new_user()
   RETURNS TRIGGER AS $$
   -- ... logic
   $$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
   ```

**Kết quả**: User registration hoạt động bình thường, không còn lỗi RLS.

### 🛠️ Các lỗi thường gặp khác:

#### 1. `column "most_common_vals" has pseudo-type anyarray`
- **Nguyên nhân**: View `table_sizes` sử dụng type `anyarray` không hỗ trợ
- **Giải pháp**: Convert sang `text` type trong view definition

#### 2. `User not authenticated` errors
- **Nguyên nhân**: Profile creation failed → subsequent operations fail
- **Giải pháp**: Fix RLS policy như trên

#### 3. Realtime subscription errors
- **Nguyên nhân**: RLS blocking realtime updates
- **Giải pháp**: Ensure proper RLS policies cho tất cả tables

## 🚀 MIGRATION VÀ DEPLOYMENT

### Chạy schema lần đầu:
1. Sử dụng file `zendo_complete_database_schema.sql`
2. Chạy trong Supabase SQL Editor
3. Kiểm tra tất cả bảng, functions, triggers đã được tạo

### Migration an toàn:
1. Sử dụng file `zendo_migration_safe.sql` cho database đã có sẵn
2. Script sẽ kiểm tra và chỉ tạo những gì chưa có
3. Không gây mất dữ liệu

## 📱 TÍCH HỢP VỚI FLUTTER

### Supabase Client Setup:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### Realtime Subscriptions:
- Tasks: Lắng nghe thay đổi real-time
- Categories: Cập nhật danh mục ngay lập tức
- Focus Sessions: Đồng bộ trạng thái timer

### Offline Support:
- Cache dữ liệu quan trọng locally
- Sync khi có kết nối internet
- Conflict resolution cho concurrent updates

## 🎯 KẾT LUẬN

Database schema của ZenDo được thiết kế để:
- **Scalable**: Hỗ trợ hàng triệu users và tasks
- **Performant**: Indexes tối ưu cho các query thường dùng
- **Secure**: RLS đảm bảo data isolation
- **Flexible**: JSON fields cho tính năng mở rộng
- **Maintainable**: Functions và triggers tự động hóa logic

Schema này cung cấp nền tảng vững chắc cho một ứng dụng quản lý công việc hiện đại với đầy đủ tính năng từ cơ bản đến nâng cao.