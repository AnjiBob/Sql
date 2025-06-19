# MySQL End-to-End Tutorial (with Sakila Database Reference)


---

## Table of Contents

1. Introduction: What is MySQL?
2. Installing MySQL
3. The Sakila Sample Database: Overview & Setup
4. MySQL Database Structure: Schemas, Tables, and Relationships
5. MySQL Data Types: In-Depth
6. SQL Queries: Syntax, Keywords, and Usage
7. Views: Creation, Use Cases, and Management
8. Stored Procedures: Syntax, Parameters, and Best Practices
9. Triggers: Creation, Invocation, and Use Cases
10. Transactions: ACID, Control, and Error Handling
11. Query Optimization: Indexes, EXPLAIN, and Performance Tips
12. Security and User Management
13. Backup, Restore, and Maintenance
14. Sample Interview Questions and Practice Tasks
15. References & Further Reading

---

## 1. Introduction: What is MySQL?

**MySQL** is an open-source relational database management system (RDBMS). It uses a client-server model and the SQL language (Structured Query Language) to query, update, and manage data.

**Key Terms:**
- **RDBMS:** Relational Database Management System
- **SQL:** Structured Query Language, the standard language for relational databases

---

## 2. Installing MySQL

### Windows

1. Download the [MySQL Installer](https://dev.mysql.com/downloads/installer/).
2. Follow the setup wizard (choose "Developer Default" for most features).
3. Set a root password; remember this for future use.

### Linux (Ubuntu)

```sh
sudo apt-get update
sudo apt-get install mysql-server
sudo systemctl start mysql
sudo mysql_secure_installation
```

### macOS

```sh
brew install mysql
brew services start mysql
```

### Connecting to MySQL

```sh
mysql -u root -p
```
- `-u`: Specifies the username (root is admin)
- `-p`: Prompts for password

---

## 3. The Sakila Sample Database: Overview & Setup

### What is Sakila?
Sakila is a sample database provided by MySQL, modeling a DVD rental store. It has a realistic, normalized schema with many-to-many relationships, triggers, views, and stored procedures.

### Download and Install Sakila

1. Download from: https://dev.mysql.com/doc/index-other.html
   - Get `sakila-schema.sql` (structure) and `sakila-data.sql` (sample data)
2. Load into MySQL:

```sh
mysql -u root -p < sakila-schema.sql
mysql -u root -p sakila < sakila-data.sql
```

3. Verify:

```sql
SHOW DATABASES;
USE sakila;
SHOW TABLES;
```

---

## 4. MySQL Database Structure: Schemas, Tables, and Relationships

### Schema

A **schema** is a logical container for database objects (tables, views, procedures, etc.). In MySQL, schema and database are synonymous.

### Tables

A **table** stores rows (records) and columns (fields). Each table should have a **primary key**.

Example from Sakila:

```sql
DESCRIBE actor;
```
| Field      | Type         | Null | Key | Default | Extra          |
|------------|--------------|------|-----|---------|----------------|
| actor_id   | SMALLINT(5)  | NO   | PRI | NULL    | auto_increment |
| first_name | VARCHAR(45)  | NO   |     | NULL    |                |
| last_name  | VARCHAR(45)  | NO   |     | NULL    |                |
| last_update| TIMESTAMP    | NO   |     | CURRENT_TIMESTAMP|           |

**Keywords:**
- `PRIMARY KEY`: Uniquely identifies a row (e.g. actor_id)
- `FOREIGN KEY`: Links to another table's primary key
- `AUTO_INCREMENT`: Increments value automatically for new rows
- `NOT NULL`: Value must be provided
- `DEFAULT`: Default value if none provided

### Relationships

- **One-to-Many:** One customer, many rentals (`customer` to `rental`)
- **Many-to-Many:** Films and actors (`film_actor` is a junction table)

---

## 5. MySQL Data Types: In-Depth

- `INT`: Integer values (whole numbers)
- `SMALLINT`, `TINYINT`: Smaller integer ranges
- `VARCHAR(n)`: Variable-length string, up to n characters
- `CHAR(n)`: Fixed-length string
- `TEXT`: Large text data
- `DATE`, `DATETIME`, `TIMESTAMP`: Date and date-time values
- `DECIMAL(m,d)`: Fixed-point number (m digits, d decimals)
- `FLOAT`, `DOUBLE`: Floating-point numbers
- `BLOB`: Binary large object (images, files)

**Example:**
```sql
CREATE TABLE sample (
  id INT PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 6. SQL Queries: Syntax, Keywords, and Usage

### SELECT

Retrieve data from one or more tables.

```sql
SELECT first_name, last_name FROM actor WHERE last_name = 'WAHLBERG';
```
- `SELECT`: Columns to retrieve
- `FROM`: Table name
- `WHERE`: Filter condition

### INSERT

Add new rows.

```sql
INSERT INTO actor (first_name, last_name) VALUES ('JOHN', 'DOE');
```

### UPDATE

Modify existing rows.

```sql
UPDATE actor SET last_name = 'SMITH' WHERE actor_id = 1;
```

### DELETE

Remove rows.

```sql
DELETE FROM actor WHERE actor_id = 1;
```

### JOINs

Combine data from multiple tables.

**INNER JOIN**: Only rows that match in both tables.

```sql
SELECT f.title, a.first_name
FROM film f
INNER JOIN film_actor fa ON f.film_id = fa.film_id
INNER JOIN actor a ON fa.actor_id = a.actor_id;
```

**LEFT JOIN**: All rows from left table, matching rows from right.

```sql
SELECT c.first_name, r.rental_id
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id;
```

### GROUP BY and Aggregate Functions

```sql
SELECT rating, COUNT(*) AS film_count
FROM film
GROUP BY rating;
```
- `COUNT()`, `SUM()`, `AVG()`, `MIN()`, `MAX()`: Aggregate functions

### ORDER BY

Sort results.

```sql
SELECT * FROM film ORDER BY release_year DESC;
```

### LIMIT

Restrict number of rows.

```sql
SELECT * FROM actor LIMIT 10;
```

---

## 7. Views: Creation, Use Cases, and Management

### What is a View?

A **view** is a virtual table based on a SELECT query. It doesn’t store data, but provides an easy way to present data or abstract complex queries.

### Creating a View

```sql
CREATE VIEW top_customers AS
SELECT customer_id, SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;
```

### Querying a View

```sql
SELECT * FROM top_customers;
```

### Updating Data Through a View

Views can be updatable if they map directly to a table and do not use aggregation or joins. Otherwise, they are read-only.

### Dropping a View

```sql
DROP VIEW IF EXISTS top_customers;
```

**Common Use Cases:**
- Simplify complex queries
- Provide a security layer
- Present different data to different users

---

## 8. Stored Procedures: Syntax, Parameters, and Best Practices

### What is a Stored Procedure?

A **stored procedure** is a set of SQL statements saved in the database and executed as a unit. Used for encapsulating business logic and reducing network traffic.

### Creating a Procedure

```sql
DELIMITER $$

CREATE PROCEDURE GetCustomerRentals(IN cust_id INT)
BEGIN
    SELECT * FROM rental WHERE customer_id = cust_id;
END $$

DELIMITER ;
```

- `DELIMITER`: Temporarily changes statement delimiter to allow semicolons inside procedure
- `IN`: Input parameter
- `OUT`: Output parameter
- `INOUT`: Both input and output

### Calling a Procedure

```sql
CALL GetCustomerRentals(5);
```

### Procedure With Output Parameter

```sql
DELIMITER $$

CREATE PROCEDURE CountRentals(IN cust_id INT, OUT rental_count INT)
BEGIN
    SELECT COUNT(*) INTO rental_count FROM rental WHERE customer_id = cust_id;
END $$

DELIMITER ;

-- Usage:
CALL CountRentals(5, @total);
SELECT @total;
```

### Procedure With Transaction Control

```sql
DELIMITER $$

CREATE PROCEDURE TransferFunds(
    IN from_customer INT,
    IN to_customer INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction Failed!';
    END;

    START TRANSACTION;
    UPDATE customer_balance SET balance = balance - amount WHERE customer_id = from_customer;
    UPDATE customer_balance SET balance = balance + amount WHERE customer_id = to_customer;
    COMMIT;
END $$

DELIMITER ;
```
**Best Practices:**
- Always handle exceptions.
- Use transactions for multi-step changes.
- Use parameters for flexibility.

---

## 9. Triggers: Creation, Invocation, and Use Cases

### What is a Trigger?

A **trigger** is a procedural code that is automatically executed in response to certain events on a particular table or view.

### Syntax

```sql
DELIMITER $$

CREATE TRIGGER before_payment_insert
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.amount < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Negative payment not allowed';
    END IF;
END $$

DELIMITER ;
```

- `BEFORE` or `AFTER`: Specifies when the trigger fires
- `FOR EACH ROW`: Executes for each affected row
- `NEW`: Refers to new row for INSERT/UPDATE
- `OLD`: Refers to existing row for UPDATE/DELETE

### Use Cases

- Enforcing business rules (e.g., no negative payment)
- Auditing changes
- Maintaining derived columns

---

## 10. Transactions: ACID, Control, and Error Handling

### What is a Transaction?

A **transaction** is a sequence of SQL operations executed as a single unit. Transactions ensure data integrity using the **ACID** properties:

- **Atomicity**: All or nothing
- **Consistency**: Valid state transition
- **Isolation**: Transactions do not interfere
- **Durability**: Persisted after commit

### Transaction Control Statements

- `START TRANSACTION;`
- `COMMIT;`  (Makes changes permanent)
- `ROLLBACK;` (Undoes changes)

### Example

```sql
START TRANSACTION;
UPDATE inventory SET store_id = 2 WHERE film_id = 10;
UPDATE payment SET amount = amount - 2.00 WHERE customer_id = 3;
COMMIT;
```

### Rollback Example

```sql
START TRANSACTION;
UPDATE payment SET amount = amount - 1000 WHERE customer_id = 3;
ROLLBACK;  -- Cancels the change
```

### Savepoints

```sql
START TRANSACTION;
UPDATE film SET rental_rate = rental_rate + 1 WHERE film_id = 1;
SAVEPOINT before_update;
UPDATE film SET rental_rate = rental_rate + 10 WHERE film_id = 1;
ROLLBACK TO before_update;
COMMIT;
```

### Isolation Levels

- **READ UNCOMMITTED**: Dirty reads allowed
- **READ COMMITTED**: Only committed data visible
- **REPEATABLE READ**: Same result in same transaction (default)
- **SERIALIZABLE**: Strictest, fully isolated

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

### Error Handling

Use `DECLARE HANDLER` in procedures/triggers for robust error recovery.

---

## 11. Query Optimization: Indexes, EXPLAIN, and Performance Tips

### Indexes

Indexes speed up data retrieval. Always index columns used in WHERE, JOIN, and ORDER BY.

```sql
CREATE INDEX idx_last_name ON customer(last_name);
SHOW INDEXES FROM customer;
DROP INDEX idx_last_name ON customer;
```

**Types of Indexes:**
- **PRIMARY**: Unique and not NULL
- **UNIQUE**: Values must be unique
- **FULLTEXT**: For text search
- **SPATIAL**: For geometry data types

### The EXPLAIN Keyword

Analyze query performance:

```sql
EXPLAIN SELECT * FROM film WHERE rating = 'PG';
```
- `type`: Type of join (ALL, index, range, ref, eq_ref, const, system)
- `possible_keys`: Which indexes could be used
- `rows`: Estimated rows examined

### Optimization Tips

- Use specific column lists instead of `SELECT *`
- Avoid subqueries in SELECT and WHERE when possible; prefer JOINs
- Normalize but denormalize for read-heavy workloads if necessary
- Use proper data types and sizes
- Regularly run `ANALYZE TABLE` and `OPTIMIZE TABLE`

### Query Caching (if enabled)

```sql
SET GLOBAL query_cache_size = 1048576;
```

---

## 12. Security and User Management

### Creating and Managing Users

```sql
CREATE USER 'dev'@'localhost' IDENTIFIED BY 'strongpassword';
GRANT SELECT, INSERT, UPDATE, DELETE ON sakila.* TO 'dev'@'localhost';
FLUSH PRIVILEGES;
```

### Changing Passwords

```sql
ALTER USER 'dev'@'localhost' IDENTIFIED BY 'newpassword';
```

### Revoking Privileges

```sql
REVOKE INSERT ON sakila.* FROM 'dev'@'localhost';
```

---

## 13. Backup, Restore, and Maintenance

### Backup

```sh
mysqldump -u root -p sakila > sakila_backup.sql
```

### Restore

```sh
mysql -u root -p sakila < sakila_backup.sql
```

### Maintenance

- `ANALYZE TABLE tablename;` — updates table statistics
- `OPTIMIZE TABLE tablename;` — defragments table

---

## 14. Sample Interview Questions and Practice Tasks

**Q: What is the difference between a procedure and a function in MySQL?**  
A: Procedures do not return a value directly, while functions must return a single value and can be used in expressions.

**Q: How do you handle transactions in a stored procedure?**  
A: Use `START TRANSACTION`, `COMMIT`, and `ROLLBACK` inside the procedure, with error handlers for rollbacks.

**Practice Task:**  
- Write a procedure that lists all overdue rentals and updates their status.
- Create a view showing the top 5 rented films per store.
- Optimize a slow query using EXPLAIN and indexing.

---

## 15. References & Further Reading

- [MySQL Documentation](https://dev.mysql.com/doc)
- [Sakila Database Docs](https://dev.mysql.com/doc/sakila/en/)
- [MySQL Tutorial](https://www.mysqltutorial.org/)
- [MySQL Optimization](https://dev.mysql.com/doc/refman/8.0/en/optimization.html)
- [MySQL Stored Procedures](https://dev.mysql.com/doc/refman/8.0/en/stored-programs-defining.html)

---
 

