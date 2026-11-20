-- =============================================================================
-- NutriTrack: schema.sql
-- Barangay Pugay, San Jose, Camarines Sur | MySQL 8.0.16+ (InnoDB)
-- Run this first, then seed.sql
-- =============================================================================
CREATE DATABASE IF NOT EXISTS nutritrack
  CHARACTER SET UTF8MB4
  COLLATE utf8mb4_unicode_ci;

USE nutritrack;

-- Drop tables in reverse dependency order (for clean re-runs)
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS follow_up;
DROP TABLE IF EXISTS feeding_attendance;
DROP TABLE IF EXISTS feeding_program;
DROP TABLE IF EXISTS measurement;
DROP TABLE IF EXISTS assessment;
DROP TABLE IF EXISTS nutrition_status;
DROP TABLE IF EXISTS child_guardian;
DROP TABLE IF EXISTS guardian;
DROP TABLE IF EXISTS child;
DROP TABLE IF EXISTS user_account;
DROP TABLE IF EXISTS barangay;
SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- 3.1 DATABASE AND TABLE CREATION (BCNF Schema)
-- NOTE: The barangay table is retained to preserve normalization (3NF/BCNF)
-- and to allow future expansion, but the current deployment contains exactly
-- one row: Barangay Pugay, San Jose, Camarines Sur.
-- =============================================================================

CREATE TABLE barangay (
  barangay_id   CHAR(36)     PRIMARY KEY,
  barangay_name VARCHAR(100) NOT NULL,
  municipality  VARCHAR(100) NOT NULL,
  province      VARCHAR(100) NOT NULL,
  CONSTRAINT uq_barangay_location
    UNIQUE (barangay_name, municipality, province)
) ENGINE = InnoDB;

CREATE TABLE user_account (
  user_id       CHAR(36)     PRIMARY KEY,
  barangay_id   CHAR(36)     NOT NULL,
  username      VARCHAR(50)  NOT NULL,
  email         VARCHAR(150) NOT NULL,
  password_hash TEXT         NOT NULL,
  role          VARCHAR(30)  NOT NULL,
  is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_user_username UNIQUE (username),
  CONSTRAINT uq_user_email    UNIQUE (email),
  CONSTRAINT fk_user_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangay(barangay_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_user_role
    CHECK (role IN ('BNS', 'HEALTH_WORKER', 'ADMIN'))
) ENGINE = InnoDB;

CREATE TABLE child (
  child_id    CHAR(36)     PRIMARY KEY,
  barangay_id CHAR(36)     NOT NULL,
  first_name  VARCHAR(80)  NOT NULL,
  middle_name VARCHAR(80),
  last_name   VARCHAR(80)  NOT NULL,
  birth_date  DATE         NOT NULL,
  sex         CHAR(1)      NOT NULL,
  address     VARCHAR(255) NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_child_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangay(barangay_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_child_sex
    CHECK (sex IN ('M', 'F')),
  CONSTRAINT chk_child_birth_date
CHECK (birth_date IS NOT NULL)
) ENGINE = InnoDB;

CREATE TABLE guardian (
  guardian_id    CHAR(36)     PRIMARY KEY,
  first_name     VARCHAR(80)  NOT NULL,
  last_name      VARCHAR(80)  NOT NULL,
  contact_number VARCHAR(30),
  address        VARCHAR(255) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE child_guardian (
  child_id          CHAR(36)    NOT NULL,
  guardian_id       CHAR(36)    NOT NULL,
  relationship_type VARCHAR(40) NOT NULL,
  is_primary        BOOLEAN     NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_child_guardian PRIMARY KEY (child_id, guardian_id),
  CONSTRAINT fk_child_guardian_child
    FOREIGN KEY (child_id) REFERENCES child(child_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_child_guardian_guardian
    FOREIGN KEY (guardian_id) REFERENCES guardian(guardian_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_guardian_relationship
    CHECK (relationship_type IN (
      'MOTHER', 'FATHER', 'GRANDPARENT', 'RELATIVE', 'FOSTER_PARENT', 'OTHER'
    ))
) ENGINE = InnoDB;

CREATE TABLE nutrition_status (
  status_id   SMALLINT AUTO_INCREMENT PRIMARY KEY,
  status_name VARCHAR(50) NOT NULL,
  description TEXT,
  CONSTRAINT uq_status_name UNIQUE (status_name)
) ENGINE = InnoDB;

CREATE TABLE assessment (
  assessment_id   CHAR(36)  PRIMARY KEY,
  child_id        CHAR(36)  NOT NULL,
  recorded_by     CHAR(36)  NOT NULL,
  status_id       SMALLINT  NOT NULL,
  assessment_date DATE      NOT NULL,
  notes           TEXT,
  CONSTRAINT fk_assessment_child
    FOREIGN KEY (child_id) REFERENCES child(child_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_assessment_user
    FOREIGN KEY (recorded_by) REFERENCES user_account(user_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_assessment_status
    FOREIGN KEY (status_id) REFERENCES nutrition_status(status_id)
    ON DELETE RESTRICT,
  CONSTRAINT uq_child_assessment_date
    UNIQUE (child_id, assessment_date)
) ENGINE = InnoDB;

CREATE TABLE measurement (
  assessment_id CHAR(36)     PRIMARY KEY,
  weight_kg     DECIMAL(5,2) NOT NULL,
  height_cm     DECIMAL(5,2) NOT NULL,
  muac_cm       DECIMAL(5,2),
  CONSTRAINT fk_measurement_assessment
    FOREIGN KEY (assessment_id) REFERENCES assessment(assessment_id)
    ON DELETE CASCADE,
  CONSTRAINT chk_weight_positive
    CHECK (weight_kg > 0 AND weight_kg <= 200),
  CONSTRAINT chk_height_positive
    CHECK (height_cm > 0 AND height_cm <= 250),
  CONSTRAINT chk_muac_valid
    CHECK (muac_cm IS NULL OR (muac_cm > 0 AND muac_cm <= 100))
) ENGINE = InnoDB;

CREATE TABLE feeding_program (
  program_id     CHAR(36)     PRIMARY KEY,
  barangay_id    CHAR(36)     NOT NULL,
  program_name   VARCHAR(150) NOT NULL,
  start_date     DATE         NOT NULL,
  end_date       DATE,
  program_status VARCHAR(20)  NOT NULL DEFAULT 'PLANNED',
  CONSTRAINT fk_program_barangay
    FOREIGN KEY (barangay_id) REFERENCES barangay(barangay_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_program_dates
    CHECK (end_date IS NULL OR end_date >= start_date),
  CONSTRAINT chk_program_status
    CHECK (program_status IN ('PLANNED', 'ONGOING', 'COMPLETED', 'CANCELLED'))
) ENGINE = InnoDB;

CREATE TABLE feeding_attendance (
  program_id         CHAR(36)    NOT NULL,
  child_id           CHAR(36)    NOT NULL,
  attendance_date    DATE        NOT NULL,
  attendance_status  VARCHAR(20) NOT NULL,
  remarks            TEXT,
  CONSTRAINT pk_feeding_attendance
    PRIMARY KEY (program_id, child_id, attendance_date),
  CONSTRAINT fk_attendance_program
    FOREIGN KEY (program_id) REFERENCES feeding_program(program_id)
    ON DELETE CASCADE,
  CONSTRAINT fk_attendance_child
    FOREIGN KEY (child_id) REFERENCES child(child_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_attendance_status
    CHECK (attendance_status IN ('PRESENT', 'ABSENT', 'EXCUSED'))
) ENGINE = InnoDB;

CREATE TABLE follow_up (
  follow_up_id   CHAR(36)    PRIMARY KEY,
  child_id       CHAR(36)    NOT NULL,
  assessment_id  CHAR(36),
  recorded_by    CHAR(36)    NOT NULL,
  follow_up_date DATE        NOT NULL,
  action_type    VARCHAR(50) NOT NULL,
  outcome        TEXT,
  CONSTRAINT fk_followup_child
    FOREIGN KEY (child_id) REFERENCES child(child_id)
    ON DELETE RESTRICT,
  CONSTRAINT fk_followup_assessment
    FOREIGN KEY (assessment_id) REFERENCES assessment(assessment_id)
    ON DELETE SET NULL,
  CONSTRAINT fk_followup_user
    FOREIGN KEY (recorded_by) REFERENCES user_account(user_id)
    ON DELETE RESTRICT,
  CONSTRAINT chk_followup_action
    CHECK (action_type IN (
      'HOME_VISIT', 'REFERRAL', 'FEEDING_SUPPORT', 'REASSESSMENT', 'OTHER'
    ))
) ENGINE = InnoDB;

-- ==============================================================================
-- INDEXES (Phase 4)
-- ==============================================================================
-- 1. Date-range reports and ORDER BY assessment_date (Query 1, monthly reports)
CREATE INDEX idx_assessment_date
  ON assessment (assessment_date);

-- 2. Attendance reports by date and status (Query 4, daily attendance sheets)
CREATE INDEX idx_attendance_date_status
  ON feeding_attendance (attendance_date, attendance_status);

-- 3. Follow-up history of one child, newest first
CREATE INDEX idx_followup_child_date
  ON follow_up (child_id, follow_up_date DESC);

-- 4. Searching for a child by name (search function of the system)
CREATE INDEX idx_child_name
  ON child (last_name, first_name);
