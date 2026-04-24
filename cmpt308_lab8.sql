-- Students table
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100),
    major VARCHAR(50),
    class_year INT
);

-- Courses table
CREATE TABLE Courses (
    course_id VARCHAR(10) PRIMARY KEY,
    title VARCHAR(100),
    credits INT CHECK (credits > 0)
);

-- Enrollments table
CREATE TABLE Enrollments (
    student_id INT,
    course_id VARCHAR(10), 
    term VARCHAR(20),
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id, term),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) 
);

-- Students data
INSERT INTO Students (student_id, name, major, class_year) VALUES
(1001, 'Seema', 'Computer Science', 2027), 
(1002, 'Sienna', 'Psychology', 2027), 
(1003, 'Matt', 'Education', 2026),
(1004, 'Marina', 'Fashion', 2025),
(1005, 'Jeffrey', 'Pre Law', 2028),
(1006, 'Jose', 'Mathematics', 2029); 

-- Courses data
INSERT INTO Courses (course_id, title, credits) VALUES
('MATH333', 'Discrete Mathematics', 4),
('CMPT222', 'Database Management', 4),
('ENGL133', 'English', 3),
('PSYC444', 'Psychology', 3),
('CMPT308', 'Database Systems', 4),
('CYBR210', 'Cybersecurity Fundamentals', 3);

-- Enrollments data
INSERT INTO Enrollments (student_id, course_id, term, grade) VALUES
(1001, 'CMPT222', '2026SP', NULL),
(1001, 'MATH333', '2026SP', 'B'),
(1002, 'PSYC444', '2026SP', NULL),
(1002, 'ENGL133', '2025FA', 'A'),
(1003, 'ENGL133', '2025FA', 'A'),
(1004, 'ENGL133', '2026SP', 'B'),
(1005, 'MATH333', '2025FA', 'C'),
(1006, 'MATH333', '2026SP', 'A'),
(1003, 'MATH333', '2026SP', NULL),
(1004, 'MATH333', '2026SP', NULL),
(1001, 'CMPT308', '2026SP', 'A'),
(1003, 'CMPT308', '2026SP', 'B'),
(1003, 'CYBR210', '2026SP', 'A'),
(1004, 'CYBR210', '2026SP', NULL);





