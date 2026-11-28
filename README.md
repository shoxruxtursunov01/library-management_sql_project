
# Library Management System - SQL Project

A SQL data analysis project built on a library management database in **PostgreSQL**. The project covers table design, CRUD operations, joins, aggregations, CTAS (Create Table As Select), subqueries and stored procedures, answering 19 business questions about books, members, employees and branches.

## Tools

- PostgreSQL
- DBeaver (SQL client)

## Database Schema

<img width="1735" height="803" alt="Снимок экрана 2026-11-25 174723" src="https://github.com/user-attachments/assets/b39b12fb-b930-4080-8793-26fce1be218b" />

### Core tables

| Table | Description | Key columns |
|---|---|---|
| `branch` | Library branches | `branch_id` (PK), `manager_id`, `branch_address`, `contact_no` |
| `employees` | Library staff | `emp_id` (PK), `emp_name`, `position`, `salary`, `branch_id` |
| `members` | Registered library members | `member_id` (PK), `member_name`, `member_address`, `reg_date` |
| `books` | Book catalog | `isbn` (PK), `book_title`, `category`, `rental_price`, `status`, `author`, `publisher` |
| `issued_status` | Books issued to members | `issued_id` (PK), `issued_member_id`, `issued_book_name`, `issued_date`, `issued_book_isbn`, `issued_emp_id` |
| `return_status` | Books returned by members | `return_id` (PK), `issued_id`, `return_book_name`, `return_date`, `return_book_isbn`, `book_quality` |

### Result tables (created with CTAS)

| Table | Created in | Description |
|---|---|---|
| `book_cnts` | Task 6 | Number of times each book was issued |
| `expensive_books` | Task 11 | Books with rental price above 7.00 |
| `branch_reports` | Task 15 | Performance report per branch |
| `active_members` | Task 16 | Members who issued a book in the last 2 months |

These tables are snapshots of query results, so they have no keys or relationships in the ERD.

## Project Tasks

### Tasks 1-9: CRUD and basic analysis

| # | Task |
|---|---|
| 1 | Create a new book record |
| 2 | Update a member's address |
| 3 | Delete a record from the `issued_status` table |
| 4 | Retrieve all books issued by a specific employee |
| 5 | List members who have issued more than one book |
| 6 | CTAS: create a summary table of issue counts per book (`book_cnts`) |
| 7 | Retrieve all books in a specific category |
| 8 | Find the total rental income by category |
| 9 | List members who registered in the last 180 days |

### Tasks 10-19: Joins, CTAS and stored procedures

| # | Task | Concepts |
|---|---|---|
| 10 | List employees with their branch manager's name and branch details | Self join, multiple joins |
| 11 | Create a table of books with rental price above a threshold | CTAS |
| 12 | Retrieve the list of books not yet returned | LEFT JOIN, `IS NULL` |
| 13 | Identify members with overdue books (30-day return period) | Joins, date arithmetic |
| 14 | Update book status on return | Stored procedure (`add_return_records`) |
| 15 | Branch performance report: books issued, books returned, revenue | CTAS, aggregation, `GROUP BY` |
| 16 | Create a table of active members (issued a book in the last 2 months) | CTAS, subquery |
| 17 | Find the top 3 employees with the most book issues processed | Aggregation, `ORDER BY`, `LIMIT` |
| 18 | Identify members who issued damaged books more than twice | Joins, `GROUP BY`, `HAVING` |
| 19 | Issue a book only if it is available, otherwise report it as unavailable | Stored procedure (`issue_book`), `IF/ELSE` |

## Stored Procedures

**`add_return_records(return_id, issued_id, book_quality)`**
Inserts a record into `return_status`, finds the returned book through `issued_status`, sets its `status` to `yes` in `books` and prints a thank-you message.

```sql
CALL add_return_records('RS138', 'IS135', 'Good');
```

**`issue_book(issued_id, member_id, book_isbn, emp_id)`**
Checks whether the book is available (`status = 'yes'`). If it is, the book is issued and its status becomes `no`. If not, a message says the book is unavailable.

```sql
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
```

## How to Run

1. Create a PostgreSQL database and create the tables from the schema above.
2. Load the sample data into the tables.
3. Open `library_tasks_10_19.sql` in your SQL client.
4. Run the full script (in DBeaver: `Alt + X`).

The test sections of the procedures include cleanup statements, so the script can be re-run without duplicate key errors.

## Notes

- Tasks that use `CURRENT_DATE` (such as Task 13 and Task 16) depend on the date you run them. The sample data contains older dates, so these queries may return empty results. Change the interval or use a fixed date to test them.
- `NOTICE` messages like `table "active_members" does not exist, skipping` are normal on the first run. They come from `DROP TABLE IF EXISTS`.

## Repository Structure

```
library-management-sql/
├── README.md
├── library_tasks_10_19.sql
└── images/
    └── erd.png
```

## Author

Tursunov Shoxrux - [GitHub](https://github.com/shoxruxtursunov01) | [Repository](https://github.com/shoxruxtursunov01/library-management-sql)
