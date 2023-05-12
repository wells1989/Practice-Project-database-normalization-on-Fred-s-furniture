SELECT * FROM store LIMIT 10;

-- 1. Restructuring the database .....

-- a. New customers table + primary key 

CREATE TABLE customers AS
SELECT distinct customer_id, customer_phone, customer_email
FROM store;

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);

-- b. New items table, staking items 1, 2 + 3, + primary key

CREATE TABLE items AS
SELECT DISTINCT item_1_id AS item_id, item_1_name AS item_name, item_1_price AS item_price 
FROM store
WHERE item_1_id IS NOT NULL
UNION
SELECT DISTINCT item_2_id AS item_id, item_2_name AS item_name, item_2_price AS item_price 
FROM store
WHERE item_2_id IS NOT NULL
UNION
SELECT DISTINCT item_3_id AS item_id, item_3_name AS item_name, item_3_price AS item_price 
FROM store
WHERE item_3_id IS NOT NULL;

ALTER TABLE items
ADD PRIMARY KEY (item_id);

-- c. New orders table + primary / foreign keys

CREATE TABLE orders AS
SELECT distinct order_id, order_date, customer_id
FROM store;

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

ALTER TABLE orders
ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id);

-- d. New orders_items table to manage many-to-many relationship, + foreign keys

CREATE TABLE orders_items AS SELECT DISTINCT order_id, item_1_id AS item_id
FROM store
WHERE item_1_id IS NOT NULL
UNION ALL 
SELECT order_id, item_2_id AS item_id 
FROM store
WHERE item_2_id IS NOT NULL
UNION ALL 
SELECT order_id, item_3_id AS item_id 
FROM store
WHERE item_3_id IS NOT NULL;

ALTER TABLE orders_items
ADD FOREIGN KEY (item_id) REFERENCES items(item_id);

ALTER TABLE orders_items
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id);

-- 2. Querying the database .......

-- a. Finding list of customers who ordered after a certain date, first using the original database then using the newly restructured one

SELECT * FROM store WHERE order_date > '2019-07-25';

SELECT order_date, customers.customer_id
FROM orders, customers
WHERE order_date > '2019-07-25'
AND orders.customer_id = customers.customer_id;

-- b. Findinge each item id and how many times it was ordered, first using the original table then using the restructured schema

WITH all_items AS (
SELECT item_1_id as item_id 
FROM store
UNION ALL
SELECT item_2_id as item_id
FROM store
WHERE item_2_id IS NOT NULL
UNION ALL
SELECT item_3_id as item_id
FROM store
WHERE item_3_id IS NOT NULL
)
SELECT item_id, COUNT(*)
FROM all_items
GROUP BY item_id
ORDER BY item_id;

SELECT item_id, COUNT(*)
FROM orders_items
GROUP BY item_id
ORDER BY item_id;