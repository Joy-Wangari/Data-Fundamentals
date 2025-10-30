🎵 Music Streaming System Schema (schema.sql)
Project: Data Fundamentals - Admin Roles & Security Database
Database: PostgreSQL (Supabase)
##Users Table##
CREATE TABLE IF NOT EXISTS Music.Users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) CHECK (role IN ('admin', 'user')) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT NOW()
);

##Artists Table##

CREATE TABLE IF NOT EXISTS Music.Artists (
    artist_id SERIAL PRIMARY KEY,
    artist_name VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

 ##Songs Table##
CREATE TABLE IF NOT EXISTS Music.Songs (
    song_id SERIAL PRIMARY KEY,
    artist_id INT REFERENCES Music.Artists(artist_id) ON DELETE CASCADE,
    song_title VARCHAR(100) NOT NULL,
    genre VARCHAR(50),
    duration INTERVAL,
    release_date DATE,
    created_by UUID REFERENCES Music.Users(user_id) ON DELETE SET NULL
);

--SAMPLE DATA
-- Insert Users
INSERT INTO Music.Users (full_name, email, role)
VALUES
('Admin Joy', 'admin@musicstream.com', 'admin'),
('Kareh Njeri', 'kareh@musicstream.com', 'user'),
('Sam Mwaura', 'sam@musicstream.com', 'user'),
('Faith Wanjiku', 'faith@musicstream.com', 'user'),
('Dennis Mwangi', 'dennis@musicstream.com', 'user');

-- Insert Artists
INSERT INTO Music.Artists (artist_name, genre, country)
VALUES
('Kestin Mbogo', 'Gospel', 'Tanzania'),
('Ed Sheeran', 'Pop', 'UK'),
('Alice Kimanzi', 'Lingala', 'DR Congo'),
('Nyashinski', 'HipHop', 'Kenya'),
('Kanji Mbugua', 'Gospel', 'Kenya');

-- Insert Songs
INSERT INTO Music.Songs (artist_id, song_title, genre, duration, release_date)
VALUES
(1, 'Come to the Father', 'Gospel', '00:04:21', '2023-09-12'),
(2, 'Perfect', 'Pop', '00:04:23', '2017-11-10'),
(3, 'Yule Yule', 'Lingala', '00:05:12', '2015-08-21'),
(4, 'Naishi', 'HipHop', '00:03:54', '2022-04-19'),
(5, 'Mwema', 'Gospel', '00:06:02', '2020-01-25');

-- 4. ENABLE ROW LEVEL SECURITY (RLS)

ALTER TABLE Music.Users ENABLE ROW LEVEL SECURITY;
ALTER TABLE Music.Artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE Music.Songs ENABLE ROW LEVEL SECURITY;

-- 5. SECURITY POLICIES

-- USERS TABLE POLICIES

-- Admin Full Access
CREATE POLICY "Admins have full access to users"
ON Music.Users
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM Music.Users u
        WHERE u.user_id = auth.uid() AND u.role = 'admin'
    )
);

-- User can view only their own data
CREATE POLICY "Users can view own profile"
ON Music.Users
FOR SELECT
USING (auth.uid() = user_id);

-- User can update their own data
CREATE POLICY "Users can update own profile"
ON Music.Users
FOR UPDATE
USING (auth.uid() = user_id
    
-- ARTISTS TABLE POLICIES
-- Admin full access
CREATE POLICY "Admins have full access to artists"
ON Music.Artists
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM Music.Users u
        WHERE u.user_id = auth.uid() AND u.role = 'admin'
    )
);

-- Users can view all artists
CREATE POLICY "Users can view artists"
ON Music.Artists
FOR SELECT
USING (true);

-- SONGS TABLE POLICIES

-- Admin full access
CREATE POLICY "Admins have full access to songs"
ON Music.Songs
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM Music.Users u
        WHERE u.user_id = auth.uid() AND u.role = 'admin'
    )
);

-- Users can view songs
CREATE POLICY "Users can view songs"
ON Music.Songs
FOR SELECT
USING (true);

-- 6. SECURITY FUNCTIONS (ADMIN-ONLY)

-- Function: Get current user role
CREATE OR REPLACE FUNCTION Music.get_current_user_role()
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT role FROM Music.Users WHERE user_id = auth.uid();
$$;

-- Function: Delete a song (Admin only)
CREATE OR REPLACE FUNCTION Music.delete_song(song_id INT)
RETURNS VOID
LANGUAGE sql
SECURITY DEFINER
AS $$
  DELETE FROM Music.Songs WHERE Music.Songs.song_id = song_id;
$$;

-- Function: Get user statistics (Admin only)
CREATE OR REPLACE FUNCTION Music.get_user_statistics()
RETURNS TABLE (
  total_users INT,
  total_songs INT,
  total_artists INT
)
