# Data-Fundamentals
# 🎵 Music Streaming System Admin Roles & Security Database 

## 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
- [💻 Getting Started](#getting-started)
  - [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Usage](#usage)
  - [Run tests](#run-tests)
- [🔒 Security Implementation](#security-implementation)
- [🔒 Security Policies](#security-policies)
- [👥 Roles Implementation](#roles-implementation)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [❓ FAQ](#faq)

<!-- PROJECT DESCRIPTION -->

# 📖 Admin Roles & Security Database <a name="about-project"></a>

> A PostgreSQL database for a music streaming system implementing RLS and user roles in Supabase.

This project builds upon the existing  Music Streaming Database to implement advanced security features including user roles, admin privileges, and database-level security policies for a modern web application.

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

> Security-focused tech stack for database access control.

<details>
  <summary>Database</summary>
  <ul>
    <li><a href="https://www.postgresql.org/">PostgreSQL</a></li>
  </ul>
</details>

<details>
  <summary>Security</summary>
  <ul>
    <li><a href="https://www.postgresql.org/docs/current/ddl-rowsecurity.html">Row Level Security (RLS)</a></li>
    <li><a href="https://supabase.com/auth">Supabase Auth</a></li>
  </ul>
</details>

<details>
<summary>Platform</summary>
  <ul>
    <li><a href="https://supabase.com/">Supabase</a></li>
  </ul>
</details>

<!-- Features -->

### Key Features <a name="key-features"></a>

> Core security features implemented in this project.

- **Role-Based Access Control** - Admin with full access and Users with restricted access.
- **Row Level Security** - Data access restrictions at the database level
- **Admin Privileges** - Secure admin-only functions and operations
- **Authentication Integration** - Supabase authentication with role management

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## 💻 Getting Started <a name="getting-started"></a>

> Follow these steps to implement security features in your Supabase project.

### Prerequisites
-- In order to run this project you need:
1.A Supabase account on https://supabase.com/
2.Existing Supabase project with database tables
3.Basic SQL and database security knowledge
4. Understanding of role-based access control concepts

### Setup
1. Ensure you have the Music Streaming System Database setup in Supabase
2. Clone this repository:

```bash
git clone https://github.com/Joy-Wangari/Data-Fundamentals.git
cd Data-Fundamentals
```

### Install

> Install this project with:

1. Open your Supabase project
2. Navigate to the 3rd icon top left - SQL Editor
3. Execute the security setup scripts
4. Enable authentication in your Supabase project settings

### Usage

**For Regular Users**:
- Sign up through Supabase Auth
- Your user record will be created with role = 'user'
- You can view, create, update, and delete your own projects and tasks
- You cannot access other users' data

**For Administrators**:
- Users with role = 'admin' in the users table have full access
- Can view and manage all users, projects, and tasks

> To implement security policies, use the Supabase SQL editor:

sql
Enable Row Level Security on all tables
```
ALTER TABLE Music.Albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE Music.Artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE Music.Songs ENABLE ROW LEVEL SECURITY;
```
Create admin full-access policy
```
CREATE POLICY "Admins have full access to artists" ON Music.Artists
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM Music.Users 
        WHERE user_id = auth.uid() AND role = 'admin'
    )
);
```
Create user restricted policy
```
CREATE POLICY "Users can view own profile" ON music.users
FOR SELECT USING (auth.uid() = user_id);
```

### Run tests
> To run security tests, run the following commands
Test RLS policies
```
Regular user should only see their own data
SELECT * FROM music.users;

Admin should see all data
SELECT * FROM music.users WHERE role = 'admin';

Test admin functions
SELECT music.get_current_user_role();
SELECT music.get_user_statistics();

Verify policy enforcement
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'music';
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 🔒 Security Implementation <a name="security-implementation"></a>

### Security Architecture
> The security implementation follows a layered approach with Row Level Security at the database level, role-based access control at the application level and secure functions for administrative operations.

### Security Components
**Security Policies**: security policies implementing least privilege principle

**Role Management**: Admin and User roles with granular permissions

**Row Level Security**: Restricts row access per user

**Authentication**: Identifies user before granting access to database
  
**Authorization**: Determines what an authenticated user can do on the system

 ### Security Functions

- `get_current_user_role()` - Returns current user's role

- `delete_user()` - Admin-only user deletion

- `update_user_role()` - Admin-only role management

- `get_user_statistics()` - Admin-only analytics

 <p align="right">(<a href="#readme-top">back to top</a>)</p>

# 🔒 Security Policies <a name="security-policies"></a>

## Row Level Security (RLS) Overview

> Row Level Security is enabled on all three tables to enforce data access restrictions at the database level. This ensures security even if application-level checks are bypassed.

## Policy Implementation Details

### Users Table Policies

1. **Admin Full Access Policy**

- **Scope**: ALL operations (CREATE, READ, UPDATE, DELETE)

- **Access**: Complete access to all user records

- **Use Case**: System administrators managing user accounts

2. **User Self-View Policy**

- **Scope**: READ operations only

- **Access**: Users can only see their own record

- **Use Case**: Users viewing their profile page

3. **User Self-Update Policy**

- **Scope**: UPDATE operations only

- **Access**: Users can modify their own data

- **Use Case**: Users updating personal information eg; name, e-mail

### Artists Table Policies

4. **Admin Full Access to Artists**

- **Scope**: ALL operations

- **Access**: Complete artist catalog management

- **Use Case**: Adding new artists, updating information

5. **User Read-Only Access to Artists**
 
- **Scope**: SELECT operations only

- **Access**: All users can browse artists

- **Use Case**: Music discovery and browsing

### Songs Table Policies

6. **Admin Full Access to Songs**

- **Scope**: ALL operations

- **Access**: Complete song catalog management

- **Use Case**: Adding new songs, updating database

7. **User Read-Only Access to Songs**

- **Scope**: SELECT operations only

- **Access**: All users can browse songs

- **Use Case**: Music streaming and discovery

<p align="right">(<a href="#readme-top">back to top</a>)</p>

# 👥 Roles Implementation <a name="roles-implementation"></a>

## Role-Based Access Control System 

>This project implements a comprehensive role-based access control (RBAC) system with two primary roles:

###  Admin Role

**Purpose**: Full system administration with complete database access

**Permissions**:

✅ **Full CRUD** - Access on all tables (users, artists, songs)

✅ **User Management** - Create, read, update, delete any user

✅ **Role Assignment** - Promote/demote users between roles

###  User Role

**Purpose**: Regular platform users with restricted access

**Permissions**:

✅ **Read Own Profile** - View personal user information

✅ **Update Own Data** - Modify personal details

✅ **Browse Catalogue** - Read-only access to artists and songs


### Access Control Matrix

|Table	|Admin Access|	User Access|
|-------|------------|-------------|
|users	|Full CRUD|	Read/Update own data|
|artists| Full CRUD|	Read-only|
|songs	|Full CRUD	|Read-only|

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHORS -->

## 👥 Authors <a name="authors"></a>

> Data-Fundamentals - Security Implementation

👤 **Project Developer**

- GitHub: [Joy-Wangari(https://github.com/Joy-Wangari/)


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FUTURE FEATURES -->

## 🔭 Future Features <a name="future-features"></a>

> Planned security enhancements for the system.

- [1] **Password policy enforcement** - ensures a stronger password by requiring minimum length and special characters 

- [2] **Two-factor authentication** - adds an extra layer of verification during user login

- [3] **Database backups and recovery policies** - ensures data can be restored in case of accidental deletion 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues and feature requests are welcome!

Feel free to check the [issues page](https://github.com/Joy-Wangari/Data-Fundamentals/issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- SUPPORT -->

## ⭐️ Show your support <a name="support"></a>

> Support this database security implementation project!

If you like this project, please give it a star on GitHub and follow this user account.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FAQ (optional) -->

## ❓ FAQ (OPTIONAL) <a name="faq"></a>

> Common questions about the security implementation.

- **Why did you enable Row Level Security?**

  - Row Level Security (RLS) ensures that users can only access data that belongs to them

- **What is the difference between authentication and authorization in your system?**

   - Authentication verifies who the user is.
   - Authorization determines what the user can do.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
