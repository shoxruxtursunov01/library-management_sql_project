SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;


--Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;


-- Task 2: Update an Existing Member's Address


UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT * FROM issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';


--Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id ='E101';


--Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    issued_emp_id,
    COUNT(*) AS total_book_issued
FROM issued_status
GROUP BY issued_emp_id 
HAVING count(issued_id) > 1;



--CTAS

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts AS
SELECT 
	b.isbn,
	b.book_title,
	count(ist.issued_id) AS no_issued
FROM books AS b
INNER JOIN issued_status AS ist 
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2;

SELECT * FROM book_cnts;


--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books 
WHERE category = 'Classic';



--Task 8: Find Total Rental Income by Category:
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;



--Task.9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= DATE '2024-08-23' - INTERVAL '180 days';

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C118', 'Sam', '145 Main St', '2024-06-01'),
('C119', 'John', '133 Main St', '2024-05-01')
ON CONFLICT (member_id) DO NOTHING;


-- Library Management System - SQL Project (PostgreSQL)


-- Task 10: List employees with their branch manager's name and their branch details
SELECT
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name AS manager
FROM employees AS e1
JOIN branch AS b
    ON e1.branch_id = b.branch_id
JOIN employees AS e2
    ON e2.emp_id = b.manager_id;


-- Task 11: Create a table of books with rental price above a certain threshold (7.00)
DROP TABLE IF EXISTS expensive_books;

CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 7.00;

SELECT * FROM expensive_books;


-- Task 12: Retrieve the list of books not yet returned
SELECT ist.*
FROM issued_status AS ist
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


-- Task 13: Identify members with overdue books (30-day return period)
-- Display member id, member name, book title, issue date and days overdue.
SELECT
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    (CURRENT_DATE - ist.issued_date) - 30 AS days_overdue
FROM issued_status AS ist
JOIN members AS m
    ON m.member_id = ist.issued_member_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
  AND (CURRENT_DATE - ist.issued_date) > 30
ORDER BY ist.issued_member_id;


-- Task 14: Update book status on return
-- When a book is returned, add a record to return_status and set the book's status to 'yes'.
CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id    VARCHAR(10),
    p_issued_id    VARCHAR(10),
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_isbn      VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT
        issued_book_isbn,
        issued_book_name
    INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;

-- Testing the procedure (issued_id = IS135, ISBN = 978-0-307-58837-1)
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- cleanup, so the test can be re-run without duplicate key errors
DELETE FROM return_status
WHERE return_id IN ('RS138', 'RS148');

CALL add_return_records('RS138', 'IS135', 'Good');
CALL add_return_records('RS148', 'IS140', 'Good');


-- Task 15: Branch performance report
-- Number of books issued, number of books returned and total revenue per branch.
DROP TABLE IF EXISTS branch_reports;

CREATE TABLE branch_reports AS
SELECT
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id)  AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
JOIN books AS bk
    ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

SELECT * FROM branch_reports;


-- Task 16: CTAS - Create a table of active members
-- Members who issued at least one book in the last 2 months.
DROP TABLE IF EXISTS active_members;

CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
);

SELECT * FROM active_members;


-- Task 17: Find employees with the most book issues processed
-- Top 3 employees: name, number of books processed, branch.
SELECT
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY e.emp_id, e.emp_name, b.branch_id
ORDER BY no_book_issued DESC
LIMIT 3;


-- Task 18: Identify members issuing high-risk books
-- Members who issued damaged books more than twice.
SELECT
    m.member_name,
    bk.book_title,
    COUNT(*) AS times_damaged
FROM issued_status AS ist
JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
JOIN members AS m
    ON m.member_id = ist.issued_member_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
WHERE rs.book_quality  = 'Damaged'
GROUP BY m.member_name, bk.book_title
HAVING COUNT(*) > 2;

ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(15) DEFAULT 'Good';


-- Task 19: Stored procedure to issue a book
-- If the book is available (status = 'yes'), issue it and set status to 'no'.
-- Otherwise, show that it is not available.
CREATE OR REPLACE PROCEDURE issue_book(
    p_issued_id        VARCHAR(10),
    p_issued_member_id VARCHAR(30),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id    VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(10);
BEGIN
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn: %', p_issued_book_isbn;

    ELSE
        RAISE NOTICE 'Sorry, the book you have requested is unavailable. book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$;

-- Testing the procedure
SELECT * FROM books;
-- 978-0-553-29698-2 -> yes
-- 978-0-375-41398-8 -> no
SELECT * FROM issued_status;

-- cleanup, so the test can be re-run without duplicate key errors
DELETE FROM issued_status
WHERE issued_id IN ('IS155', 'IS156');

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-553-29698-2';

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books;
WHERE isbn = '978-0-375-41398-8';

SELECT * FROM issued_status
WHERE issued_id IN ('IS155', 'IS156');

