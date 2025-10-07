-- =====================================================
-- ZENDO - COMPLETE DATABASE SCHEMA
-- Comprehensive SQL design for task management app
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search optimization

-- =====================================================
-- ENUMS AND CUSTOM TYPES
-- =====================================================

-- Task Priority Enum
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'urgent');

-- Task Status Enum  
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled');

-- Focus Session Status
CREATE TYPE focus_session_status AS ENUM ('active', 'paused', 'completed', 'cancelled');

-- Notification Type
CREATE TYPE notification_type AS ENUM ('task_reminder', 'focus_break', 'daily_summary', 'achievement');

-- Achievement Type
CREATE TYPE achievement_type AS ENUM ('task_completion', 'focus_streak', 'productivity_milestone', 'consistency');

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users Profile Table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    name TEXT, -- Display name
    avatar_url TEXT,
    timezone TEXT DEFAULT 'UTC',
    language TEXT DEFAULT 'vi',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    last_active_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Profile settings
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_expires_at TIMESTAMPTZ,
    
    -- Statistics
    total_tasks_completed INTEGER DEFAULT 0,
    total_focus_minutes INTEGER DEFAULT 0,
    current_streak_days INTEGER DEFAULT 0,
    longest_streak_days INTEGER DEFAULT 0
);

-- Categories Table
CREATE TABLE public.categories (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT NOT NULL DEFAULT '📝',
    color TEXT NOT NULL DEFAULT '#3B82F6',
    is_default BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    -- Constraints
    CONSTRAINT categories_name_length CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
    CONSTRAINT categories_unique_name_per_user UNIQUE (user_id, name)
);

-- Tasks Table (Enhanced)
CREATE TABLE public.tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    parent_task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE, -- For subtasks
    
    -- Basic Info
    title TEXT NOT NULL,
    description TEXT,
    notes TEXT,
    
    -- Classification
    priority task_priority DEFAULT 'medium',
    status task_status DEFAULT 'pending',
    category TEXT, -- Legacy field for backward compatibility
    
    -- Timing
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    due_date TIMESTAMPTZ,
    start_date TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    
    -- Time tracking
    estimated_minutes INTEGER DEFAULT 0,
    actual_minutes INTEGER DEFAULT 0,
    
    -- Flags
    is_completed BOOLEAN DEFAULT FALSE,
    is_important BOOLEAN DEFAULT FALSE,
    is_urgent BOOLEAN DEFAULT FALSE,
    is_recurring BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    
    -- Recurring settings (JSON for flexibility)
    recurring_config JSONB, -- {type: 'daily|weekly|monthly', interval: 1, days: [1,2,3], end_date: '...'}
    
    -- Tags (array of strings)
    tags TEXT[] DEFAULT '{}',
    
    -- Attachments and links
    attachments JSONB DEFAULT '[]', -- [{name: 'file.pdf', url: '...', type: 'pdf', size: 1024}]
    external_links TEXT[] DEFAULT '{}',
    
    -- Sorting and organization
    sort_order INTEGER DEFAULT 0,
    
    -- Constraints
    CONSTRAINT tasks_title_length CHECK (char_length(title) >= 1 AND char_length(title) <= 500),
    CONSTRAINT tasks_estimated_minutes_positive CHECK (estimated_minutes >= 0),
    CONSTRAINT tasks_actual_minutes_positive CHECK (actual_minutes >= 0),
    CONSTRAINT tasks_completed_logic CHECK (
        (is_completed = TRUE AND completed_at IS NOT NULL) OR 
        (is_completed = FALSE AND completed_at IS NULL)
    )
);

-- Subtasks Table (Alternative approach - can be used instead of parent_task_id)
CREATE TABLE public.subtasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    CONSTRAINT subtasks_title_length CHECK (char_length(title) >= 1 AND char_length(title) <= 200)
);

-- Focus Sessions Table (Enhanced)
CREATE TABLE public.focus_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
    
    -- Session details
    title TEXT,
    planned_duration_minutes INTEGER NOT NULL DEFAULT 25,
    actual_duration_minutes INTEGER DEFAULT 0,
    break_duration_minutes INTEGER DEFAULT 5,
    
    -- Timing
    started_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    ended_at TIMESTAMPTZ,
    paused_at TIMESTAMPTZ,
    total_pause_duration_minutes INTEGER DEFAULT 0,
    
    -- Status and type
    status focus_session_status DEFAULT 'active',
    session_type TEXT DEFAULT 'pomodoro', -- pomodoro, deep_work, break
    
    -- Productivity metrics
    productivity_rating INTEGER CHECK (productivity_rating >= 1 AND productivity_rating <= 5),
    distraction_count INTEGER DEFAULT 0,
    notes TEXT,
    
    -- Environment
    background_sound TEXT, -- nature, white_noise, music, silence
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    CONSTRAINT focus_sessions_duration_positive CHECK (planned_duration_minutes > 0),
    CONSTRAINT focus_sessions_actual_duration_positive CHECK (actual_duration_minutes >= 0)
);

-- User Settings Table (Enhanced)
CREATE TABLE public.user_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE NOT NULL,
    
    -- App preferences
    theme TEXT DEFAULT 'system', -- light, dark, system
    language TEXT DEFAULT 'vi',
    timezone TEXT DEFAULT 'Asia/Ho_Chi_Minh',
    
    -- Pomodoro settings
    pomodoro_work_duration INTEGER DEFAULT 25,
    pomodoro_short_break INTEGER DEFAULT 5,
    pomodoro_long_break INTEGER DEFAULT 15,
    pomodoro_sessions_until_long_break INTEGER DEFAULT 4,
    
    -- Notification settings
    notifications_enabled BOOLEAN DEFAULT TRUE,
    task_reminders_enabled BOOLEAN DEFAULT TRUE,
    focus_break_reminders_enabled BOOLEAN DEFAULT TRUE,
    daily_summary_enabled BOOLEAN DEFAULT TRUE,
    email_notifications_enabled BOOLEAN DEFAULT FALSE,
    
    -- Task defaults
    default_task_priority task_priority DEFAULT 'medium',
    default_estimated_minutes INTEGER DEFAULT 30,
    auto_archive_completed_tasks_days INTEGER DEFAULT 30,
    
    -- UI preferences
    show_completed_tasks BOOLEAN DEFAULT TRUE,
    default_task_view TEXT DEFAULT 'list', -- list, kanban, calendar
    sidebar_collapsed BOOLEAN DEFAULT FALSE,
    
    -- Privacy settings
    analytics_enabled BOOLEAN DEFAULT TRUE,
    data_sharing_enabled BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- =====================================================
-- ADVANCED FEATURES TABLES
-- =====================================================

-- Tags Table (for better tag management)
CREATE TABLE public.tags (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    color TEXT DEFAULT '#6B7280',
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    CONSTRAINT tags_name_length CHECK (char_length(name) >= 1 AND char_length(name) <= 50),
    CONSTRAINT tags_unique_name_per_user UNIQUE (user_id, name)
);

-- Task Tags Junction Table
CREATE TABLE public.task_tags (
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES public.tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    PRIMARY KEY (task_id, tag_id)
);

-- Notifications Table
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    task_id UUID REFERENCES public.tasks(id) ON DELETE CASCADE,
    
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    
    -- Scheduling
    scheduled_for TIMESTAMPTZ NOT NULL,
    sent_at TIMESTAMPTZ,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Achievements Table
CREATE TABLE public.achievements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    type achievement_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT DEFAULT '🏆',
    
    -- Requirements and progress
    target_value INTEGER,
    current_value INTEGER DEFAULT 0,
    is_unlocked BOOLEAN DEFAULT FALSE,
    unlocked_at TIMESTAMPTZ,
    
    -- Metadata
    metadata JSONB DEFAULT '{}',
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Activity Log Table (for analytics and history)
CREATE TABLE public.activity_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    action TEXT NOT NULL, -- task_created, task_completed, focus_session_started, etc.
    entity_type TEXT, -- task, category, focus_session
    entity_id UUID,
    
    -- Details
    details JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Templates Table (for recurring tasks and task templates)
CREATE TABLE public.task_templates (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    
    name TEXT NOT NULL,
    description TEXT,
    title_template TEXT NOT NULL,
    description_template TEXT,
    
    -- Default values
    default_priority task_priority DEFAULT 'medium',
    default_estimated_minutes INTEGER DEFAULT 30,
    default_tags TEXT[] DEFAULT '{}',
    
    -- Template settings
    is_public BOOLEAN DEFAULT FALSE,
    usage_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    
    CONSTRAINT task_templates_name_length CHECK (char_length(name) >= 1 AND char_length(name) <= 100)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Profiles indexes
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_last_active ON public.profiles(last_active_at);

-- Categories indexes
CREATE INDEX idx_categories_user_id ON public.categories(user_id);
CREATE INDEX idx_categories_user_name ON public.categories(user_id, name);
CREATE INDEX idx_categories_sort_order ON public.categories(user_id, sort_order);

-- Tasks indexes (Critical for performance)
CREATE INDEX idx_tasks_user_id ON public.tasks(user_id);
CREATE INDEX idx_tasks_category_id ON public.tasks(category_id);
CREATE INDEX idx_tasks_parent_task_id ON public.tasks(parent_task_id);
CREATE INDEX idx_tasks_status ON public.tasks(user_id, status);
CREATE INDEX idx_tasks_priority ON public.tasks(user_id, priority);
CREATE INDEX idx_tasks_due_date ON public.tasks(user_id, due_date) WHERE due_date IS NOT NULL;
CREATE INDEX idx_tasks_completed ON public.tasks(user_id, is_completed);
CREATE INDEX idx_tasks_created_at ON public.tasks(user_id, created_at);
CREATE INDEX idx_tasks_updated_at ON public.tasks(updated_at);
CREATE INDEX idx_tasks_important_urgent ON public.tasks(user_id, is_important, is_urgent);

-- Text search indexes
CREATE INDEX idx_tasks_title_search ON public.tasks USING gin(to_tsvector('english', title));
CREATE INDEX idx_tasks_description_search ON public.tasks USING gin(to_tsvector('english', description));
CREATE INDEX idx_tasks_tags ON public.tasks USING gin(tags);

-- Focus sessions indexes
CREATE INDEX idx_focus_sessions_user_id ON public.focus_sessions(user_id);
CREATE INDEX idx_focus_sessions_task_id ON public.focus_sessions(task_id);
CREATE INDEX idx_focus_sessions_started_at ON public.focus_sessions(user_id, started_at);
CREATE INDEX idx_focus_sessions_status ON public.focus_sessions(user_id, status);

-- Subtasks indexes
CREATE INDEX idx_subtasks_task_id ON public.subtasks(task_id);
CREATE INDEX idx_subtasks_user_id ON public.subtasks(user_id);

-- Tags indexes
CREATE INDEX idx_tags_user_id ON public.tags(user_id);
CREATE INDEX idx_tags_name ON public.tags(user_id, name);
CREATE INDEX idx_task_tags_task_id ON public.task_tags(task_id);
CREATE INDEX idx_task_tags_tag_id ON public.task_tags(tag_id);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_scheduled ON public.notifications(scheduled_for) WHERE is_sent = FALSE;
CREATE INDEX idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;

-- Activity logs indexes
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_activity_logs_created_at ON public.activity_logs(created_at);
CREATE INDEX idx_activity_logs_action ON public.activity_logs(user_id, action);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle new user registration
-- Drop existing function and trigger first to avoid conflicts
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Create profile (bypass RLS by using SECURITY DEFINER)
    INSERT INTO public.profiles (id, email, full_name, name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1))
    );
    
    -- Create default user settings
    INSERT INTO public.user_settings (user_id)
    VALUES (NEW.id);
    
    -- Create default categories
    INSERT INTO public.categories (user_id, name, icon, color, is_default, sort_order)
    VALUES 
        (NEW.id, 'Công việc', '💼', '#3B82F6', TRUE, 1),
        (NEW.id, 'Cá nhân', '👤', '#10B981', TRUE, 2),
        (NEW.id, 'Học tập', '📚', '#F59E0B', TRUE, 3);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Function to update task completion statistics
CREATE OR REPLACE FUNCTION public.update_task_completion_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- If task is being completed
    IF NEW.is_completed = TRUE AND OLD.is_completed = FALSE THEN
        UPDATE public.profiles 
        SET 
            total_tasks_completed = total_tasks_completed + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
        
        -- Update actual minutes if not set
        IF NEW.actual_minutes = 0 AND OLD.actual_minutes = 0 THEN
            NEW.actual_minutes = COALESCE(NEW.estimated_minutes, 30);
        END IF;
        
        -- Set completed_at if not set
        IF NEW.completed_at IS NULL THEN
            NEW.completed_at = NOW();
        END IF;
    END IF;
    
    -- If task is being uncompleted
    IF NEW.is_completed = FALSE AND OLD.is_completed = TRUE THEN
        UPDATE public.profiles 
        SET 
            total_tasks_completed = GREATEST(total_tasks_completed - 1, 0),
            updated_at = NOW()
        WHERE id = NEW.user_id;
        
        NEW.completed_at = NULL;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update focus session statistics
CREATE OR REPLACE FUNCTION public.update_focus_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- If focus session is completed
    IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE public.profiles 
        SET 
            total_focus_minutes = total_focus_minutes + COALESCE(NEW.actual_duration_minutes, 0),
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update tag usage count
CREATE OR REPLACE FUNCTION public.update_tag_usage()
RETURNS TRIGGER AS $$
BEGIN
    -- Update usage count for tags
    IF TG_OP = 'INSERT' THEN
        UPDATE public.tags 
        SET usage_count = usage_count + 1 
        WHERE id = NEW.tag_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.tags 
        SET usage_count = GREATEST(usage_count - 1, 0) 
        WHERE id = OLD.tag_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Updated at triggers
CREATE TRIGGER trigger_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_tasks_updated_at
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_subtasks_updated_at
    BEFORE UPDATE ON public.subtasks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_focus_sessions_updated_at
    BEFORE UPDATE ON public.focus_sessions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_user_settings_updated_at
    BEFORE UPDATE ON public.user_settings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_tags_updated_at
    BEFORE UPDATE ON public.tags
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_task_templates_updated_at
    BEFORE UPDATE ON public.task_templates
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- New user trigger
-- Drop existing trigger first to avoid conflicts
DROP TRIGGER IF EXISTS trigger_handle_new_user ON auth.users;

CREATE TRIGGER trigger_handle_new_user
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Task completion statistics trigger
CREATE TRIGGER trigger_task_completion_stats
    BEFORE UPDATE ON public.tasks
    FOR EACH ROW EXECUTE FUNCTION public.update_task_completion_stats();

-- Focus session statistics trigger
CREATE TRIGGER trigger_focus_stats
    AFTER UPDATE ON public.focus_sessions
    FOR EACH ROW EXECUTE FUNCTION public.update_focus_stats();

-- Tag usage triggers
CREATE TRIGGER trigger_tag_usage_insert
    AFTER INSERT ON public.task_tags
    FOR EACH ROW EXECUTE FUNCTION public.update_tag_usage();

CREATE TRIGGER trigger_tag_usage_delete
    AFTER DELETE ON public.task_tags
    FOR EACH ROW EXECUTE FUNCTION public.update_tag_usage();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subtasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_templates ENABLE ROW LEVEL SECURITY;

-- Profiles policies (Allow service role to bypass RLS for user creation)
-- Drop existing policies first to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id OR auth.role() = 'service_role');

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

-- Categories policies
CREATE POLICY "Users can view own categories" ON public.categories
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own categories" ON public.categories
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own categories" ON public.categories
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own categories" ON public.categories
    FOR DELETE USING (auth.uid() = user_id);

-- Tasks policies
CREATE POLICY "Users can view own tasks" ON public.tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" ON public.tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON public.tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tasks" ON public.tasks
    FOR DELETE USING (auth.uid() = user_id);

-- Subtasks policies
CREATE POLICY "Users can view own subtasks" ON public.subtasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subtasks" ON public.subtasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subtasks" ON public.subtasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own subtasks" ON public.subtasks
    FOR DELETE USING (auth.uid() = user_id);

-- Focus sessions policies
CREATE POLICY "Users can view own focus sessions" ON public.focus_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own focus sessions" ON public.focus_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own focus sessions" ON public.focus_sessions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own focus sessions" ON public.focus_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- User settings policies
CREATE POLICY "Users can view own settings" ON public.user_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own settings" ON public.user_settings
    FOR UPDATE USING (auth.uid() = user_id);

-- Tags policies
CREATE POLICY "Users can view own tags" ON public.tags
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tags" ON public.tags
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tags" ON public.tags
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tags" ON public.tags
    FOR DELETE USING (auth.uid() = user_id);

-- Task tags policies
CREATE POLICY "Users can view own task tags" ON public.task_tags
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.tasks 
            WHERE tasks.id = task_tags.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own task tags" ON public.task_tags
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.tasks 
            WHERE tasks.id = task_tags.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete own task tags" ON public.task_tags
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM public.tasks 
            WHERE tasks.id = task_tags.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- Achievements policies
CREATE POLICY "Users can view own achievements" ON public.achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements" ON public.achievements
    FOR UPDATE USING (auth.uid() = user_id);

-- Activity logs policies
CREATE POLICY "Users can view own activity logs" ON public.activity_logs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activity logs" ON public.activity_logs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Task templates policies
CREATE POLICY "Users can view own templates" ON public.task_templates
    FOR SELECT USING (auth.uid() = user_id OR is_public = TRUE);

CREATE POLICY "Users can insert own templates" ON public.task_templates
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own templates" ON public.task_templates
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own templates" ON public.task_templates
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- Task statistics view
CREATE OR REPLACE VIEW public.task_statistics AS
SELECT 
    user_id,
    COUNT(*) as total_tasks,
    COUNT(*) FILTER (WHERE is_completed = TRUE) as completed_tasks,
    COUNT(*) FILTER (WHERE is_completed = FALSE) as pending_tasks,
    COUNT(*) FILTER (WHERE due_date < NOW() AND is_completed = FALSE) as overdue_tasks,
    COUNT(*) FILTER (WHERE DATE(due_date) = CURRENT_DATE AND is_completed = FALSE) as today_tasks,
    COUNT(*) FILTER (WHERE priority = 'high' AND is_completed = FALSE) as high_priority_tasks,
    AVG(actual_minutes) FILTER (WHERE is_completed = TRUE AND actual_minutes > 0) as avg_completion_time
FROM public.tasks
WHERE is_archived = FALSE
GROUP BY user_id;

-- Daily productivity view
CREATE OR REPLACE VIEW public.daily_productivity AS
SELECT 
    user_id,
    DATE(created_at) as date,
    COUNT(*) as tasks_created,
    COUNT(*) FILTER (WHERE is_completed = TRUE) as tasks_completed,
    SUM(actual_minutes) FILTER (WHERE is_completed = TRUE) as minutes_worked,
    COUNT(DISTINCT category_id) as categories_used
FROM public.tasks
GROUP BY user_id, DATE(created_at)
ORDER BY user_id, date DESC;

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- This section would be executed after user registration
-- Sample categories are already handled in handle_new_user() function

-- =====================================================
-- MAINTENANCE AND CLEANUP PROCEDURES
-- =====================================================

-- Function to archive old completed tasks
CREATE OR REPLACE FUNCTION public.archive_old_completed_tasks()
RETURNS INTEGER AS $$
DECLARE
    archived_count INTEGER;
BEGIN
    UPDATE public.tasks 
    SET is_archived = TRUE
    WHERE is_completed = TRUE 
    AND completed_at < NOW() - INTERVAL '90 days'
    AND is_archived = FALSE;
    
    GET DIAGNOSTICS archived_count = ROW_COUNT;
    RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old activity logs
CREATE OR REPLACE FUNCTION public.cleanup_old_activity_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.activity_logs 
    WHERE created_at < NOW() - INTERVAL '1 year';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update user streaks (should be called daily)
CREATE OR REPLACE FUNCTION public.update_user_streaks()
RETURNS VOID AS $$
BEGIN
    -- Update current streaks based on daily task completion
    UPDATE public.profiles 
    SET 
        current_streak_days = CASE 
            WHEN EXISTS (
                SELECT 1 FROM public.tasks 
                WHERE tasks.user_id = profiles.id 
                AND DATE(completed_at) = CURRENT_DATE - INTERVAL '1 day'
                AND is_completed = TRUE
            ) THEN current_streak_days + 1
            ELSE 0
        END,
        longest_streak_days = GREATEST(longest_streak_days, current_streak_days + 1),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERFORMANCE MONITORING
-- =====================================================

-- View to monitor table sizes and statistics
CREATE OR REPLACE VIEW public.table_sizes AS
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation,
    most_common_freqs,
    -- Convert most_common_vals to text to avoid anyarray type issues
    most_common_vals::text as most_common_vals_text
FROM pg_stats 
WHERE schemaname = 'public'
ORDER BY tablename, attname;

-- =====================================================
-- BACKUP AND RECOVERY NOTES
-- =====================================================

/*
BACKUP STRATEGY:
1. Daily automated backups of the entire database
2. Point-in-time recovery enabled
3. Regular testing of backup restoration
4. Separate backups for user data and system data

RECOVERY PROCEDURES:
1. For data corruption: Restore from latest backup
2. For accidental deletion: Use point-in-time recovery
3. For performance issues: Check indexes and query plans
4. For schema changes: Use migration scripts

MONITORING:
1. Set up alerts for failed queries
2. Monitor table growth and index usage
3. Track slow queries and optimize them
4. Regular VACUUM and ANALYZE operations
*/

-- =====================================================
-- END OF SCHEMA
-- =====================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Final message
SELECT 'ZenDo database schema created successfully!' as status;