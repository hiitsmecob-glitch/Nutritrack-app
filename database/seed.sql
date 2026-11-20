-- =============================================================================
-- NutriTrack: seed.sql
-- Sample data for Barangay Pugay. Run AFTER schema.sql
-- =============================================================================
USE nutritrack;

-- Barangay (single record: the deployment scope of NutriTrack)
INSERT INTO barangay (barangay_id, barangay_name, municipality, province) VALUES
('b1111111-1111-1111-1111-111111111111', 'Pugay', 'San Jose', 'Camarines Sur');

-- Users (all belong to Barangay Pugay)
INSERT INTO user_account (user_id, barangay_id, username, email, password_hash, role) VALUES
('u1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111',
 'bns_pugay1', 'bns.pugay1@example.org', 'sample_hash_bns1', 'BNS'),
('u2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111',
 'hw_pugay', 'hw.pugay@example.org', 'sample_hash_hw1', 'HEALTH_WORKER'),
('u3333333-3333-3333-3333-333333333333', 'b1111111-1111-1111-1111-111111111111',
 'bns_pugay2', 'bns.pugay2@example.org', 'sample_hash_bns2', 'BNS');

-- Children (all residents of Barangay Pugay)
INSERT INTO child (child_id, barangay_id, first_name, middle_name, last_name, birth_date, sex, address) VALUES
('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111',
 'Juan', 'Dela', 'Cruz', '2023-04-10', 'M', 'Purok 1, Pugay, San Jose, Camarines Sur'),
('c2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111',
 'Maria', 'Santos', 'Reyes', '2022-08-15', 'F', 'Purok 2, Pugay, San Jose, Camarines Sur'),
('c3333333-3333-3333-3333-333333333333', 'b1111111-1111-1111-1111-111111111111',
 'Pedro', NULL, 'Garcia', '2024-01-20', 'M', 'Purok 3, Pugay, San Jose, Camarines Sur'),
('c4444444-4444-4444-4444-444444444444', 'b1111111-1111-1111-1111-111111111111',
 'Ana', 'Lopez', 'Mendoza', '2023-11-05', 'F', 'Purok 4, Pugay, San Jose, Camarines Sur');

-- Guardians
INSERT INTO guardian (guardian_id, first_name, last_name, contact_number, address) VALUES
('g1111111-1111-1111-1111-111111111111', 'Maria', 'Dela Cruz', '09123456789', 'Purok 1, Pugay, San Jose, Camarines Sur'),
('g2222222-2222-2222-2222-222222222222', 'Jose', 'Reyes', '09187654321', 'Purok 2, Pugay, San Jose, Camarines Sur'),
('g3333333-3333-3333-3333-333333333333', 'Elena', 'Garcia', '09234567890', 'Purok 3, Pugay, San Jose, Camarines Sur'),
('g4444444-4444-4444-4444-444444444444', 'Rosa', 'Mendoza', '09345678901', 'Purok 4, Pugay, San Jose, Camarines Sur');

-- Child-Guardian relationships
INSERT INTO child_guardian (child_id, guardian_id, relationship_type, is_primary) VALUES
('c1111111-1111-1111-1111-111111111111', 'g1111111-1111-1111-1111-111111111111', 'MOTHER', TRUE),
('c2222222-2222-2222-2222-222222222222', 'g2222222-2222-2222-2222-222222222222', 'FATHER', TRUE),
('c3333333-3333-3333-3333-333333333333', 'g3333333-3333-3333-3333-333333333333', 'MOTHER', TRUE),
('c4444444-4444-4444-4444-444444444444', 'g4444444-4444-4444-4444-444444444444', 'MOTHER', TRUE),
('c1111111-1111-1111-1111-111111111111', 'g2222222-2222-2222-2222-222222222222', 'RELATIVE', FALSE);

-- Nutrition Statuses
INSERT INTO nutrition_status (status_name, description) VALUES
('NORMAL', 'Within the expected nutrition classification'),
('UNDERWEIGHT', 'Weight-for-age below normal range'),
('STUNTED', 'Height-for-age below normal range'),
('WASTED', 'Weight-for-height below normal range'),
('OVERWEIGHT', 'Weight-for-height above normal range');

-- Assessments
INSERT INTO assessment (assessment_id, child_id, recorded_by, status_id, assessment_date, notes) VALUES
('a1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111',
 'u1111111-1111-1111-1111-111111111111', 1, '2025-06-15', 'Routine nutrition assessment'),
('a2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222',
 'u1111111-1111-1111-1111-111111111111', 2, '2025-06-20', 'Initial assessment - underweight noted'),
('a3333333-3333-3333-3333-333333333333', 'c3333333-3333-3333-3333-333333333333',
 'u2222222-2222-2222-2222-222222222222', 1, '2025-07-01', 'Well-nourished infant'),
('a4444444-4444-4444-4444-444444444444', 'c2222222-2222-2222-2222-222222222222',
 'u1111111-1111-1111-1111-111111111111', 2, '2025-09-10', 'Follow-up assessment still underweight'),
('a5555555-5555-5555-5555-555555555555', 'c4444444-4444-4444-4444-444444444444',
 'u3333333-3333-3333-3333-333333333333', 3, '2025-08-05', 'Stunting observed');

-- Measurements
INSERT INTO measurement (assessment_id, weight_kg, height_cm, muac_cm) VALUES
('a1111111-1111-1111-1111-111111111111', 12.50, 88.40, 15.20),
('a2222222-2222-2222-2222-222222222222',  9.80, 85.00, 12.50),
('a3333333-3333-3333-3333-333333333333',  8.20, 72.00, 14.00),
('a4444444-4444-4444-4444-444444444444', 10.10, 87.50, 12.80),
('a5555555-5555-5555-5555-555555555555', 11.00, 82.00, 13.50);

-- Feeding Programs
INSERT INTO feeding_program (program_id, barangay_id, program_name, start_date, end_date, program_status) VALUES
('p1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111',
 'Supplementary Feeding Program 2025', '2025-07-01', '2025-12-31', 'ONGOING'),
('p2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111',
 'Hot Meal Program Q3', '2025-07-15', '2025-09-30', 'COMPLETED');

-- Feeding Attendance
INSERT INTO feeding_attendance (program_id, child_id, attendance_date, attendance_status, remarks) VALUES
('p1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', '2025-07-05', 'PRESENT', NULL),
('p1111111-1111-1111-1111-111111111111', 'c1111111-1111-1111-1111-111111111111', '2025-07-12', 'PRESENT', NULL),
('p1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222', '2025-07-05', 'PRESENT', 'Priority underweight'),
('p1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222', '2025-07-12', 'ABSENT', 'Sick'),
('p1111111-1111-1111-1111-111111111111', 'c3333333-3333-3333-3333-333333333333', '2025-07-05', 'PRESENT', NULL),
('p2222222-2222-2222-2222-222222222222', 'c4444444-4444-4444-4444-444444444444', '2025-08-01', 'PRESENT', NULL),
('p2222222-2222-2222-2222-222222222222', 'c4444444-4444-4444-4444-444444444444', '2025-08-08', 'EXCUSED', 'Family emergency');

-- Follow-ups
INSERT INTO follow_up (follow_up_id, child_id, assessment_id, recorded_by, follow_up_date, action_type, outcome) VALUES
('f1111111-1111-1111-1111-111111111111', 'c2222222-2222-2222-2222-222222222222',
 'a2222222-2222-2222-2222-222222222222', 'u1111111-1111-1111-1111-111111111111',
 '2025-07-05', 'HOME_VISIT', 'Counseled mother on complementary feeding'),
('f2222222-2222-2222-2222-222222222222', 'c2222222-2222-2222-2222-222222222222',
 'a4444444-4444-4444-4444-444444444444', 'u2222222-2222-2222-2222-222222222222',
 '2025-09-15', 'FEEDING_SUPPORT', 'Enrolled in supplementary feeding'),
('f3333333-3333-3333-3333-333333333333', 'c4444444-4444-4444-4444-444444444444',
 'a5555555-5555-5555-5555-555555555555', 'u3333333-3333-3333-3333-333333333333',
 '2025-08-20', 'REFERRAL', 'Referred to RHU for further evaluation');
