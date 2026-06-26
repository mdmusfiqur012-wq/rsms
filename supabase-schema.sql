-- RSMS Production Schema
-- Run this in Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== PROFILES ====================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT CHECK (role IN ('admin', 'supervisor', 'student')) NOT NULL,
  avatar_url TEXT,
  university_id TEXT,
  department_id TEXT,
  status TEXT CHECK (status IN ('pending', 'active', 'suspended')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== UNIVERSITIES ====================
CREATE TABLE IF NOT EXISTS universities (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  short_name TEXT,
  country TEXT,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== DEPARTMENTS ====================
CREATE TABLE IF NOT EXISTS departments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  university_id TEXT REFERENCES universities(id),
  head TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== PROJECTS ====================
CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  supervisor_id UUID REFERENCES profiles(id),
  student_id UUID REFERENCES profiles(id),
  university_id TEXT REFERENCES universities(id),
  department_id TEXT REFERENCES departments(id),
  status TEXT DEFAULT 'planning',
  start_date DATE,
  expected_end_date DATE,
  progress INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== RESEARCH MODULES ====================
CREATE TABLE IF NOT EXISTS research_modules (
  id TEXT PRIMARY KEY,
  project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  status TEXT DEFAULT 'not_started',
  progress INTEGER DEFAULT 0,
  deadline DATE,
  estimated_duration INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== DOCUMENTS ====================
CREATE TABLE IF NOT EXISTS documents (
  id TEXT PRIMARY KEY,
  project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  url TEXT NOT NULL,
  type TEXT,
  size BIGINT,
  version INTEGER DEFAULT 1,
  uploaded_by UUID REFERENCES profiles(id),
  status TEXT DEFAULT 'pending',
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== DISCUSSIONS ====================
CREATE TABLE IF NOT EXISTS discussions (
  id TEXT PRIMARY KEY,
  project_id TEXT REFERENCES projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  student_id UUID REFERENCES profiles(id),
  status TEXT DEFAULT 'open',
  priority TEXT DEFAULT 'medium',
  pinned BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS discussion_messages (
  id TEXT PRIMARY KEY,
  discussion_id TEXT REFERENCES discussions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id),
  message TEXT NOT NULL,
  attachments TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== NOTIFICATIONS ====================
CREATE TABLE IF NOT EXISTS notifications (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  type TEXT,
  title TEXT,
  message TEXT,
  project_id TEXT,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==================== STORAGE BUCKET ====================
-- Create storage bucket for research documents (run in Supabase dashboard or via API)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('research-documents', 'research-documents', false);

-- ==================== ROW LEVEL SECURITY ====================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE research_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE discussion_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" 
  ON profiles FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" 
  ON profiles FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users can update their own profile" 
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Projects policies
CREATE POLICY "Students can view their own projects" 
  ON projects FOR SELECT USING (student_id = auth.uid());

CREATE POLICY "Supervisors can view assigned projects" 
  ON projects FOR SELECT USING (supervisor_id = auth.uid());

CREATE POLICY "Admins have full access to projects" 
  ON projects FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Research modules policies
CREATE POLICY "Project participants can view modules" 
  ON research_modules FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE id = research_modules.project_id 
      AND (student_id = auth.uid() OR supervisor_id = auth.uid())
    )
  );

-- Documents policies
CREATE POLICY "Project participants can manage documents" 
  ON documents FOR ALL USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE id = documents.project_id 
      AND (student_id = auth.uid() OR supervisor_id = auth.uid())
    )
  );

-- Discussions policies
CREATE POLICY "Project participants can manage discussions" 
  ON discussions FOR ALL USING (
    EXISTS (
      SELECT 1 FROM projects 
      WHERE id = discussions.project_id 
      AND (student_id = auth.uid() OR supervisor_id = auth.uid())
    )
  );

-- Discussion messages policies
CREATE POLICY "Project participants can view and send messages" 
  ON discussion_messages FOR ALL USING (
    EXISTS (
      SELECT 1 FROM discussions 
      WHERE id = discussion_messages.discussion_id 
      AND EXISTS (
        SELECT 1 FROM projects 
        WHERE id = discussions.project_id 
        AND (student_id = auth.uid() OR supervisor_id = auth.uid())
      )
    )
  );

-- Notifications policies
CREATE POLICY "Users can only see their own notifications" 
  ON notifications FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications" 
  ON notifications FOR UPDATE USING (user_id = auth.uid());

-- ==================== INDEXES FOR PERFORMANCE ====================
CREATE INDEX IF NOT EXISTS idx_projects_student ON projects(student_id);
CREATE INDEX IF NOT EXISTS idx_projects_supervisor ON projects(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_modules_project ON research_modules(project_id);
CREATE INDEX IF NOT EXISTS idx_documents_project ON documents(project_id);
CREATE INDEX IF NOT EXISTS idx_discussions_project ON discussions(project_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);

-- ==================== TRIGGERS ====================
-- Auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
