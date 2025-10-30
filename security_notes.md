**🛡️SECURITY NOTES - ADMIN ROLES AND SECURITY**

**MUSIC STREAMING SERVICE**

**Overview**

This document hightlights the implementation of security control features for an educational music streaming service crreated using Supabase (PostgreSQL).
Security is enforced using 
1. Role level security
2. Role based access controls
3. SQL policies
4. Supabase Auth

**Defined roles**

| Role      | Description                                                                                    | Access Level                                             |
| --------- | ---------------------------------------------------------------------------------------------- | -------------------------------------------------------  |
| **Admin** | Can create, read, update, and delete records across all tables (`artists`, `albums`, `songs`). | Full Access (CREATE, READ, UPDATE, DELETE)               |
| **User**  | Can only view or add data associated with their user ID.                                       | Restricted Access (READ own data, INSERT new owned data) |


**Row Level Security**
*Row Level Security* is a PostgreSQL feature that allows you to control which rows users can access in a table. When RLS is enabled on a table, all queries are filtered through policies that determine access.
Enabled on all tables to restrict access based on authorized user access
```
sql
alter table artists enable row level security;
alter table albums enable row level security;
alter table songs enable row level security;
```

**Policies**
1. *Admin policies*

Have unrestricted access to all tables
```
sql
create policy "Admins have full access to all music data"
on artists, albums, songs
for all
using (exists (
  select 1 from users where id = auth.uid() and role = 'admin'
));
```
2. *User policies*

Can only access and manage records linkeed to their own personal accounts eg, name, email
```
sql
create policy "Users can view their own artists"
on artists
for select
using (auth.uid() = user_id);

create policy "Users can insert their own albums"
on albums
for insert
with check (auth.uid() = user_id);

create policy "Users can view their own songs"
on songs
for select
using (auth.uid() = user_id);
```

**Authentication**
1. Implemented using Supabase Auth with email/password sign-in.

2. Only authenticated users can access the database.

3. Public (anonymous) access is disabled.

**Admin Only Function**
Admins can remove songs or albums from the database through a unique SQL query
```
sql
create or replace function delete_song(song_id uuid)
returns void
language sql
security definer
as $$
  delete from songs where id = song_id;
$$;
```
**Security Best Practiced Followed**

✅ Principle of Least Privilege – Users only access their own data.

✅ RLS Enabled – Enforces per-user row access.

✅ Role Separation – Admin vs Regular User privileges.

✅ Secure Function Execution – Admin-only actions are restricted.

✅ Authenticated Access – No anonymous read/write operations.

**Planned Security Enhancements**

1. Add an audit log to record every insert, update, or delete.

2. Introduce multi-factor authentication (MFA) for admins.

3. Create a “last_updated_by” field for accountability.

4. Set up email alerts for admin-level deletions.

**Conclusion**

This security setup provides a foundation for the Music streaming system database, ensuring data privacy, access control and compliance with security best practices while maintaining usability for legitimate users.
