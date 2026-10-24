CREATE DATABASE IF NOT EXISTS library_management;
USE library_management;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS issue_books;
DROP TABLE IF EXISTS book_requests;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS admin;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS fine_settings;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL
);

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(120) NOT NULL,
    category VARCHAR(100),
    isbn VARCHAR(50),
    rack_no VARCHAR(50),
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 0
);

CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    mobile VARCHAR(20),
    password VARCHAR(100) NOT NULL,
    course VARCHAR(50),
    `year` VARCHAR(20),
    section VARCHAR(20),
    address TEXT
);

CREATE TABLE issue_books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    student_name VARCHAR(100),
    student_contact VARCHAR(100),
    course VARCHAR(50),
    `year` VARCHAR(20),
    section VARCHAR(20),
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine DECIMAL(10,2) DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',
    returned TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_issue_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    CONSTRAINT fk_issue_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE book_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    student_name VARCHAR(100),
    course VARCHAR(50),
    `year` VARCHAR(20),
    book_id INT NOT NULL,
    book_title VARCHAR(150),
    request_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_request_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_request_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

CREATE TABLE fine_settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fine_per_day DECIMAL(10,2) NOT NULL DEFAULT 5.00
);

-- Insert defaults
INSERT INTO fine_settings (id, fine_per_day) VALUES (1, 5.00);
INSERT INTO admin (username, password) VALUES ('admin', 'admin123');
