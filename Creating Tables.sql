--Library Managment System Project 2

--Creating branch table

DROP TABLE IF EXISTS branch;
CREATE  TABLE branch
	(
		branch_id varchar(10) PRIMARY KEY, 
		manager_id varchar(10),
		branch_address varchar(50),
		contact_no varchar(15)
	);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
	emp_id varchar(10) PRIMARY KEY,
	emp_name varchar(25),
	POSITION varchar(25),
	salary int,
	branch_id varchar(25) --FK
	);


DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
	isbn varchar(20) PRIMARY KEY,
	book_title varchar(75),
	category varchar(15),
	rental_price float, 
	status varchar(15),
	author varchar(35),
	publisher varchar(55)
	);


DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
	member_id varchar(10) PRIMARY KEY,
	member_name varchar(25),
	member_address varchar(75),
	reg_date date 
	);


DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
	issued_id varchar(10) PRIMARY KEY,
	issued_member_id varchar(10),--FK
	issued_book_name varchar(75),
	issued_date date,
	issued_book_isbn varchar(25), --FK
	issued_emp_id varchar(10) --FK
	);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
	return_id varchar(10) PRIMARY KEY,
	issued_id varchar(10),
	return_book_name varchar(75),
	return_date date,
	return_book_isbn varchar(20)
	);
	


--Foreign Key
ALTER TABLE issued_status 
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);


ALTER TABLE issued_status 
ADD CONSTRAINT fk_books 
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);


ALTER TABLE issued_status 
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees  
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);


ALTER TABLE return_status   
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);









