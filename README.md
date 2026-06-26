# RSMS - Research Supervision Management System

A production-ready SaaS platform for universities and pharmaceutical research laboratories to manage the full research lifecycle.

## Features

- **Role-Based Access Control**: Administrator, Supervisor, Student
- **Complete Research Workspace**: Multi-module pipelines with progress tracking
- **Real-time Communication**: Supervisor Inbox + Ask Supervisor with live updates
- **Document Management**: Drag & drop uploads with versioning via Supabase Storage
- **Project Creation Wizard**: 7-step guided creation with automatic module generation
- **Admin Panel**: Full institutional control (users, universities, approvals, analytics)
- **Knowledge Repository**: Searchable protocols, templates, and guides
- **Live Notifications**: Real-time activity across the platform

## Tech Stack

- React 19 + TypeScript + Vite
- Tailwind CSS + shadcn/ui + Framer Motion
- Supabase (Auth, PostgreSQL, Storage, Realtime)
- React Router, Recharts, Sonner

## Getting Started

### 1. Environment Variables

Create a `.env` file:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

### 2. Run Supabase Schema

Run `supabase-schema.sql` in your Supabase SQL Editor.

### 3. Configure Storage

Create a private bucket named `research-documents`.

### 4. Enable Email Auth

In Supabase Dashboard → Authentication → Providers → Email:
- Enable Email Confirmation
- Set up Password Reset redirect URL

### 5. Development

```bash
npm install
npm run dev
```

## Production Deployment

### Vercel / Netlify

1. Connect your GitHub repository
2. Add environment variables
3. Deploy

### Supabase Production Checklist

- [ ] Enable Row Level Security (already in schema)
- [ ] Set up email templates
- [ ] Configure storage bucket policies
- [ ] Add domain to allowed origins

## Demo Accounts (Development Only)

- `admin@rsms.edu` — Administrator
- `supervisor@rsms.edu` — Supervisor
- `student@rsms.edu` — Student

All accounts use password `demo123` in mock mode.

## Architecture

- `src/hooks/useAuth.ts` — Authentication + role management
- `src/hooks/useRSMSData.ts` — Centralized reactive data layer
- `src/lib/supabase.ts` — Service layer for all CRUD operations
- `src/features/` — Role-specific and shared modules

## End-to-End Workflow

The platform supports the complete research lifecycle:

**Student Registration → Admin Approval → Supervisor Assignment → Project Creation → Research Modules → File Uploads → Ask Supervisor → Supervisor Review → Revision → Approval → Progress Tracking → Publication → Thesis Completion**

All actions propagate in real time across dashboards, notifications, and timelines.

## License

Proprietary — For institutional use only.

---

**RSMS v1.0** — Ready for production deployment in universities and research institutions.
