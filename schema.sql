DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  customer VARCHAR(255),
  account_no VARCHAR(255)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  employee_id INT REFERENCES employees(id),
  customer_id INT REFERENCES customers(id),
  product_id INT REFERENCES products(id),
  sale_date DATE,
  sale_amount MONEY,
  units_sold INTEGER,
  invoice_no INTEGER,
  invoice_frequency VARCHAR(255)
);
