-- Migration: Add focus_time_minutes column to tasks table
-- Date: 2025-01-11
-- Description: Thêm cột focus_time_minutes để lưu trữ thời gian focus cho task

-- Thêm cột focus_time_minutes vào bảng tasks
ALTER TABLE public.tasks 
ADD COLUMN focus_time_minutes INTEGER DEFAULT 25;

-- Thêm comment cho cột mới
COMMENT ON COLUMN public.tasks.focus_time_minutes IS 'Thời gian focus cho task tính bằng phút (mặc định 25 phút)';

-- Tạo index cho focus_time_minutes để tối ưu query
CREATE INDEX idx_tasks_focus_time ON public.tasks(focus_time_minutes);

-- Cập nhật trigger updated_at để bao gồm cột mới
-- (Trigger này đã tồn tại, chỉ cần đảm bảo nó hoạt động với cột mới)

-- Kiểm tra cấu trúc bảng sau khi thêm cột
-- SELECT column_name, data_type, is_nullable, column_default
-- FROM information_schema.columns 
-- WHERE table_name = 'tasks' AND table_schema = 'public'
-- ORDER BY ordinal_position;