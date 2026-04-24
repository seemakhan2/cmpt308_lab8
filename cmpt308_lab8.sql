-- Name: Seema Khan 
-- Date: April 24, 2026
-- Lab: Lab 8

DROP TRIGGER IF EXISTS enrollment_trigger ON lab8_enrollments;
DROP FUNCTION IF EXISTS log_enrollment();
DROP FUNCTION IF EXISTS register_student(INT, TEXT);

DROP TABLE IF EXISTS lab8_enrollment_audit;
DROP TABLE IF EXISTS lab8_enrollments;
DROP TABLE IF EXISTS lab8_courses;
DROP TABLE IF EXISTS lab8_students;

DROP ROLE IF EXISTS advisor_role;
DROP ROLE IF EXISTS registrar_role;

CREATE TABLE lab8_students (
  student_id INT PRIMARY KEY,
  student_name TEXT NOT NULL
);

CREATE TABLE lab8_courses (
  course_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  capacity INT NOT NULL CHECK (capacity > 0),
  enrolled_count INT NOT NULL DEFAULT 0 CHECK (enrolled_count >= 0 AND enrolled_count <= capacity)
);

CREATE TABLE lab8_enrollments (
  student_id INT NOT NULL REFERENCES lab8_students(student_id),
  course_id TEXT NOT NULL REFERENCES lab8_courses(course_id),
  enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (student_id, course_id)
);

CREATE TABLE lab8_enrollment_audit (
  audit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  action_type TEXT NOT NULL,
  student_id INT NOT NULL,
  course_id TEXT NOT NULL,
  action_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO lab8_students (student_id, student_name) VALUES
(1001, 'Seema'),
(1002, 'Sienna'),
(1003, 'Matt'),
(1004, 'Marina'),
(1005, 'Jeffrey'),
(1006, 'Jose');

INSERT INTO lab8_courses (course_id, title, capacity, enrolled_count) VALUES
('MATH333', 'Discrete Mathematics', 3, 0),
('CMPT222', 'Database Management', 2, 0),
('ENGL133', 'English', 2, 0),
('PSYC444', 'Psychology', 2, 0),
('CMPT308', 'Database Systems', 2, 0),
('CYBR210', 'Cybersecurity Fundamentals', 1, 0);

-- part a 

CREATE ROLE advisor_role;
CREATE ROLE registrar_role;

GRANT SELECT ON lab8_students TO advisor_role;
GRANT SELECT ON lab8_courses TO advisor_role;
GRANT SELECT ON lab8_enrollments TO advisor_role;

GRANT SELECT ON lab8_students TO registrar_role;
GRANT SELECT ON lab8_courses TO registrar_role;
GRANT SELECT ON lab8_enrollments TO registrar_role;

GRANT INSERT ON lab8_enrollments TO registrar_role;
GRANT UPDATE ON lab8_courses TO registrar_role;

REVOKE DELETE ON lab8_enrollments FROM registrar_role;

--part a output
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('advisor_role', 'registrar_role')
  AND table_name IN ('lab8_students', 'lab8_courses', 'lab8_enrollments')
ORDER BY grantee, table_name, privilege_type;

--part b 
CREATE OR REPLACE FUNCTION register_student(p_student INT, p_course TEXT)
RETURNS TEXT AS $$
DECLARE
  course_cap INT;
  course_count INT;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM lab8_students WHERE student_id = p_student
  ) THEN
    RETURN 'Student not found';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM lab8_courses WHERE course_id = p_course
  ) THEN
    RETURN 'Course not found';
  END IF;

  IF EXISTS (
    SELECT 1 FROM lab8_enrollments
    WHERE student_id = p_student AND course_id = p_course
  ) THEN
    RETURN 'Already enrolled';
  END IF;

  SELECT capacity, enrolled_count
  INTO course_cap, course_count
  FROM lab8_courses
  WHERE course_id = p_course;

  IF course_count >= course_cap THEN
    RETURN 'Course full';
  END IF;

  INSERT INTO lab8_enrollments(student_id, course_id)
  VALUES (p_student, p_course);

  UPDATE lab8_courses
  SET enrolled_count = enrolled_count + 1
  WHERE course_id = p_course;

  RETURN 'Enrollment successful';
END;
$$ LANGUAGE plpgsql;

-- tests 
SELECT register_student(1001, 'CMPT308');
SELECT register_student(1001, 'CMPT308');
SELECT register_student(1002, 'CYBR210');
SELECT register_student(1003, 'CYBR210');
SELECT register_student(9999, 'CMPT308');

-- part c 
CREATE OR REPLACE FUNCTION log_enrollment()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO lab8_enrollment_audit(action_type, student_id, course_id)
  VALUES ('INSERT', NEW.student_id, NEW.course_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enrollment_trigger
AFTER INSERT ON lab8_enrollments
FOR EACH ROW
EXECUTE FUNCTION log_enrollment();

-- tests 
SELECT register_student(1004, 'CMPT222');

-- audit 
SELECT audit_id, action_type, student_id, course_id, action_time
FROM lab8_enrollment_audit
ORDER BY action_time;

-- enrollment list 
SELECT s.student_name, e.course_id, c.title, e.enrolled_at
FROM lab8_enrollments e
JOIN lab8_students s ON e.student_id = s.student_id
JOIN lab8_courses c ON e.course_id = c.course_id
ORDER BY s.student_name, e.course_id;

-- seats remaining 

SELECT course_id, title, capacity, enrolled_count,
       capacity - enrolled_count AS seats_remaining
FROM lab8_courses
ORDER BY course_id;

--audit log 
SELECT audit_id, action_type, student_id, course_id, action_time
FROM lab8_enrollment_audit
ORDER BY action_time;

-- privledge report

SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee IN ('advisor_role', 'registrar_role')
  AND table_name IN ('lab8_students', 'lab8_courses', 'lab8_enrollments')
ORDER BY grantee, table_name, privilege_type;
