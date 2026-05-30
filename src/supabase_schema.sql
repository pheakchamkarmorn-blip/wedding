-- =========================================================================
-- SUPABASE DATABASE SCHEMA FOR WEDDING GUEST MANAGER
-- រចនាសម្ព័ន្ធទិន្នន័យ Supabase សម្រាប់កម្មវិធីគ្រប់គ្រងភ្ញៀវមង្គលការ
-- =========================================================================
-- 
-- ណែនាំការប្រើប្រាស់ (Instructions For Use):
-- 1. Copy both lines and scripts below (ចម្លងកូដខាងក្រោមទាំងអស់)
-- 2. Go to your Supabase Dashboard -> SQL Editor (ទៅកាន់ទំព័រគ្រប់គ្រង Supabase រួចចូល SQL Editor)
-- 3. Paste and run this script (ផាសកូដរួចចុច Run)
-- 4. Enable Realtime on the tables if needed (បើកដំណើរការ Realtime លើតារាងប្រសិនបើចង់បាន)
--
-- =========================================================================

-- 1. ENABLE EXTENSIONS (បើកដំណើរការមធ្យោបាយជំនួយសម្រាប់ Generate IDs)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. CLEANUP TABLES (ជម្រះតារាងចាស់ៗ បើសិនជាចង់ Reset)
DROP TABLE IF EXISTS guests CASCADE;
DROP TABLE IF EXISTS weddings CASCADE;
DROP TABLE IF EXISTS admins CASCADE;

-- -------------------------------------------------------------
-- 3. CREATE TABLE: admins
-- តារាង គណៈកម្មការ / អ្នកគ្រប់គ្រងប្រព័ន្ធ
-- -------------------------------------------------------------
CREATE TABLE admins (
    id TEXT PRIMARY KEY DEFAULT ('adm-' || substr(md5(random()::text), 1, 9)),
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL, -- សម្រាប់ប្រព័ន្ធសាមញ្ញ (For simplified login) 
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comment
COMMENT ON TABLE admins IS 'លម្អិតគណនីគណៈកម្មការសម្របសម្រួលមង្គលការ';

-- -------------------------------------------------------------
-- 4. CREATE TABLE: weddings
-- តារាង ព័ត៌មានអំពីព្រឹត្តិការណ៍រៀបអាពាហ៍ពិពាហ៍ (ម្ចាស់ដើមការ)
-- -------------------------------------------------------------
CREATE TABLE weddings (
    id TEXT PRIMARY KEY DEFAULT ('event-' || substr(md5(random()::text), 1, 9)),
    title TEXT NOT NULL,
    host_username TEXT NOT NULL UNIQUE,
    host_password TEXT NOT NULL,
    khqr_img_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE weddings IS 'លម្អិតអំពីកម្មវិធីមង្គលការនីមួយៗ និងគណនីម្ចាស់ដើមការ';

-- -------------------------------------------------------------
-- 5. CREATE TABLE: guests
-- តារាង បញ្ជីឈ្មោះភ្ញៀវកិត្តិយស
-- -------------------------------------------------------------
CREATE TABLE guests (
    id TEXT PRIMARY KEY DEFAULT ('gst-' || substr(md5(random()::text), 1, 9)),
    wedding_id TEXT NOT NULL REFERENCES weddings(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    companions INTEGER NOT NULL DEFAULT 0 CHECK (companions >= 0),
    relation_type TEXT NOT NULL, -- ឧ. 'ខាងកូនកំលោះ', 'ខាងកូនក្រមុំ', 'មិត្តភក្តិ'
    amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
    note TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

COMMENT ON TABLE guests IS 'បញ្ជីឈ្មោះភ្ញៀវកិត្តិយស និង ចំនួនថវិការចងដៃ';

-- -------------------------------------------------------------
-- 6. CREATE INDEXES FOR FAST PERFORMANCE (ការចង្អុលបង្ហាញបង្កើនល្បឿនស្វែងរក)
-- -------------------------------------------------------------
CREATE INDEX idx_guests_wedding_id ON guests(wedding_id);
CREATE INDEX idx_guests_status ON guests(status);
CREATE INDEX idx_guests_name_phone ON guests(name, phone);
CREATE INDEX idx_weddings_host_auth ON weddings(host_username, host_password);

-- -------------------------------------------------------------
-- 7. INSERT SEED DATA (បន្ថែមទិន្នន័យគំរូ សមស្របនឹង Local Storage)
-- -------------------------------------------------------------

-- Core Admin Account/ គណនីគណៈកម្មការសាកល្បង
INSERT INTO admins (id, username, password) 
VALUES ('adm-f7d928', 'admin123', 'password123')
ON CONFLICT (username) DO NOTHING;

-- Wedding Event Seeding/ បញ្ជីកម្មវិធីមង្គលការសាកល្បង
INSERT INTO weddings (id, title, host_username, host_password, khqr_img_url, created_at)
VALUES 
(
    'event-09ae48a2', 
    'ពិធីការមង្គលការ ដេវីដ & គីមហុង 🌸', 
    'host123', 
    'password123', 
    'https://i.ibb.co/6P0Sff3/khqr-demo.png', 
    '2026-05-25T00:00:00Z'
),
(
    'event-d68a2bf1', 
    'មង្គលការកូនប្រុសស្រី សំណាង & រចនា 🎉', 
    'host456', 
    'password123', 
    'https://i.ibb.co/6P0Sff3/khqr-demo.png', 
    '2026-05-26T00:00:00Z'
)
ON CONFLICT (id) DO NOTHING;

-- Guests Seeding/ បញ្ជីភ្ញៀវមកជាមួយស្រាប់សម្រាប់បង្ហាញ
INSERT INTO guests (id, wedding_id, name, phone, companions, relation_type, amount, note, status, created_at)
VALUES
(
    'gst-11', 
    'event-09ae48a2', 
    'ឧកញ៉ា សុខ សារ៉ាវ៉ាន់', 
    '012999888', 
    2, 
    'ខាងកូនកំលោះ', 
    150.00, 
    'សូមជូនពរក្មួយទាំងពីរជួបតែសុភមង្គលត្រជាក់ត្រជុំ!', 
    'approved', 
    '2026-05-28T10:00:00Z'
),
(
    'gst-12', 
    'event-09ae48a2', 
    'ម៉ៅ ដានីល', 
    '098445566', 
    1, 
    'ខាងកូនក្រមុំ', 
    50.00, 
    'ជូនពរឱ្យស្រលាញ់គ្នាដល់ចាស់កោងខ្នងណា៎!', 
    'pending', 
    '2026-05-28T12:05:00Z'
),
(
    'gst-13', 
    'event-09ae48a2', 
    'ជា សំណាង', 
    '097887766', 
    0, 
    'មិត្តភក្តិ', 
    30.00, 
    'ជូនពរមានសុភមង្គលកូនច្រើនៗ!', 
    'approved', 
    '2026-05-28T13:40:00Z'
),
(
    'gst-21', 
    'event-d68a2bf1', 
    'គង់ វីរៈ', 
    '085443322', 
    3, 
    'ខាងកូនកំលោះ', 
    100.00, 
    'អបអរសាទរថ្ងៃមង្គលជ័យ!', 
    'approved', 
    '2026-05-28T11:15:00Z'
)
ON CONFLICT (id) DO NOTHING;

-- -------------------------------------------------------------
-- 8. ROW LEVEL SECURITY (RLS) CONTROL CONFIGURATIONS
-- ការកំណត់ទម្រង់សន្តិសុខទិន្នន័យ (Row Level Security)
-- -------------------------------------------------------------
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE weddings ENABLE ROW LEVEL SECURITY;
ALTER TABLE guests ENABLE ROW LEVEL SECURITY;

-- Note: In Supabase, the public anon role accesses tables via select/insert/update/delete.
-- Creating standard Permissive Policies to support seamless integrations:

-- Weddings Access:
CREATE POLICY "Enable read access for all users on weddings" 
ON weddings FOR SELECT USING (true);

CREATE POLICY "Enable full access for and admins on weddings"
ON weddings FOR ALL USING (true) WITH CHECK (true);

-- Guests Access:
CREATE POLICY "Enable read access for everyone on guests" 
ON guests FOR SELECT USING (true);

CREATE POLICY "Enable guest registrations from anywhere" 
ON guests FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable updates or approvals" 
ON guests FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Enable deletion of guests" 
ON guests FOR DELETE USING (true);

-- Admins Access:
CREATE POLICY "Enable read of admin authentication" 
ON admins FOR SELECT USING (true);

CREATE POLICY "Enable full management on admin configurations" 
ON admins FOR ALL USING (true) WITH CHECK (true);
