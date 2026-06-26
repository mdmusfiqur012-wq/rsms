# RSMS Production Deployment Checklist

## 1. Supabase Setup

### Create Project
- Go to https://supabase.com
- Create new project

### Run Schema
```bash
# In Supabase SQL Editor, paste and run:
# supabase-schema.sql
```

### Configure Authentication
- Authentication → Providers → Email
  - [x] Enable Email Confirmation
  - [x] Enable Password Reset
- Set redirect URLs:
  - `https://yourdomain.com/auth/callback`

### Storage
- Storage → Create bucket: `research-documents`
- Make bucket **private**
- Add policy:
  ```sql
  CREATE POLICY "Project participants can manage documents"
  ON storage.objects FOR ALL
  USING (bucket_id = 'research-documents');
  ```

### Row Level Security
- Already included in `supabase-schema.sql`
- Verify policies are active

## 2. Environment Variables

Create `.env` in project root:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

## 3. Build & Deploy

### Build
```bash
npm run build
```

### Deploy to Vercel
1. Connect GitHub repo
2. Add environment variables
3. Deploy

### Deploy to Netlify
1. Connect repo
2. Add environment variables
3. Build command: `npm run build`
4. Publish directory: `dist`

## 4. Post-Deployment

- [ ] Test user registration flow
- [ ] Test admin approval
- [ ] Test project creation with workflow templates
- [ ] Test file uploads
- [ ] Test real-time discussions
- [ ] Verify notifications appear across roles

## 5. Security Hardening

- Enable RLS on all tables
- Set up email rate limits
- Configure CORS properly
- Enable audit logs (optional)

## 6. Monitoring

- Set up error tracking (Sentry recommended)
- Monitor Supabase usage limits
- Set up uptime monitoring

---

**Status**: Ready for production deployment.
