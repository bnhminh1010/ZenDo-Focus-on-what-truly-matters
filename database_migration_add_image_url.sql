-- Migration: Add image_url column to tasks table
-- Date: 2025-01-08
-- Description: Thêm cột image_url để lưu trữ đường dẫn hình ảnh cho task

-- Thêm cột image_url vào bảng tasks
ALTER TABLE public.tasks 
ADD COLUMN image_url TEXT;

-- Thêm comment cho cột mới
COMMENT ON COLUMN public.tasks.image_url IS 'URL của hình ảnh đính kèm với task (có thể là local path hoặc cloud storage URL)';

-- Tạo index cho image_url để tối ưu query
CREATE INDEX idx_tasks_image_url ON public.tasks(image_url) WHERE image_url IS NOT NULL;

-- Cập nhật trigger updated_at để bao gồm cột mới
-- (Trigger này đã tồn tại, chỉ cần đảm bảo nó hoạt động với cột mới)

-- Kiểm tra cấu trúc bảng sau khi thêm cột
-- SELECT column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'tasks' AND table_schema = 'public'
-- ORDER BY ordinal_position;