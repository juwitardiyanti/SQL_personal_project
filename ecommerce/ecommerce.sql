-- CHECKING DATASET 
-- products table
# Checking null and total records
SELECT *
FROM ecommerce.products
WHERE
	product_id IS NULL OR
    desc_product IS NULL OR
    category IS NULL OR
    base_price IS NULL; 
-- orders table
# Checking null and total records
SELECT *
FROM ecommerce.orders
WHERE
	order_id IS NULL OR
    seller_id IS NULL OR
    buyer_id IS NULL OR
    kodepos IS NULL OR
    subtotal IS NULL OR
    discount IS NULL OR
    total IS NULL OR
    created_at IS NULL OR
    paid_at IS NULL OR
    delivery_at IS NULL; 
-- orders table
# Checking null and total records
SELECT *
FROM ecommerce.users
WHERE
	user_id IS NULL OR
    nama_user IS NULL OR
    kodepos IS NULL OR
    email IS NULL; 
-- orders table
# Checking null and total records
SELECT *
FROM ecommerce.order_details
WHERE
	order_detail_id IS NULL OR
    order_id IS NULL OR
    product_id IS NULL OR
    price IS NULL OR
    quantity IS NULL; 

-- Check transaction per month
SELECT
	DATE_FORMAT(created_at, '%Y-%m') AS month_name,
	count(1) AS total_transaction
FROM
	ecommerce.orders
GROUP BY month_name
ORDER BY month_name;

-- The number of unpaid transactions
SELECT
	COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE paid_at = 'NA';

-- The number of transaction has been paid but not sent
SELECT COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE paid_at != 'NA' AND delivery_at = 'NA';

-- The number of transaction has been paid but not sent
SELECT COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE paid_at != 'NA' AND delivery_at = 'NA';

-- The number of transactions are not sent, whether paid or not
SELECT COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE delivery_at = 'NA' AND (paid_at = 'NA' OR paid_at != 'NA');

-- The number of unsent transactions
SELECT COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE delivery_at = 'NA';

-- The number of transactions sent on the same day as the payment date
SELECT COUNT(1) AS total_transaction
FROM ecommerce.orders
WHERE delivery_at = paid_at;

-- Total users
SELECT COUNT(DISTINCT user_id) AS total_user
FROM ecommerce.users;

-- Total users who have made transactions as buyers
SELECT COUNT(DISTINCT u.user_id) AS total_user_as_buyer 
FROM ecommerce.users u
JOIN ecommerce.orders o ON u.user_id = o.buyer_id;

-- Total users who have transacted as sellers
SELECT COUNT(DISTINCT u.user_id) AS total_user_as_seller 
FROM ecommerce.users u
JOIN ecommerce.orders o ON u.user_id = o.seller_id;

-- Total users who have transacted as buyers and sellers
SELECT COUNT(DISTINCT u.user_id) AS total_user_as_buyer_seller 
FROM ecommerce.users u
JOIN ecommerce.orders o1 ON u.user_id = o1.buyer_id
JOIN ecommerce.orders o2 ON u.user_id = o2.seller_id;

-- Total users who have never transacted as buyers or sellers
SELECT COUNT(DISTINCT u.user_id) AS jumlah_pengguna
FROM ecommerce.users u
LEFT JOIN ecommerce.orders o1 ON u.user_id = o1.buyer_id
LEFT JOIN ecommerce.orders o2 ON u.user_id = o2.seller_id
WHERE o1.buyer_id IS NULL AND o2.seller_id IS NULL;

-- Top 5 buyers with the largest total purchases (based on total item price after discount)
SELECT u.user_id, u.nama_user, SUM(o.total) AS total_purchase
FROM ecommerce.users u
JOIN ecommerce.orders o ON u.user_id = o.buyer_id
GROUP BY u.user_id, u.nama_user
ORDER BY total_purchase DESC
LIMIT 5;

-- Top 5 buyers with the largest total order and never used a discount
SELECT u.user_id, u.nama_user, COUNT(o.order_id) AS total_purchases
FROM ecommerce.users u
JOIN ecommerce.orders o ON u.user_id = o.buyer_id
WHERE o.discount = 0
GROUP BY u.user_id, u.nama_user
ORDER BY total_purchases DESC
LIMIT 5;

-- Top 5 users who transacted at least 1 time per month in 2020 with  an average total amount per transaction of more than 1 Million
SELECT 
    o.buyer_id, 
    u.email, 
    ROUND(AVG(o.total), 2) AS rata_rata, 
    COUNT(DISTINCT DATE_FORMAT(o.created_at, '%m')) AS month_count
FROM ecommerce.orders o
JOIN ecommerce.users u ON o.buyer_id = u.user_id
WHERE YEAR(o.created_at) = 2020
GROUP BY o.buyer_id, u.email
HAVING rata_rata > 1000000 AND month_count >= 5
ORDER BY rata_rata DESC;

-- Sellers email domain
SELECT 
    SUBSTRING_INDEX(email, '@', -1) AS domain_email,
    COUNT(user_id) AS total_user
FROM ecommerce.users
WHERE user_id IN (SELECT DISTINCT seller_id FROM ecommerce.orders)
GROUP BY domain_email;

-- Top 5 product based on the number of quantity
SELECT p.desc_product, SUM(od.quantity) AS total_quantity
FROM ecommerce.products p
JOIN ecommerce.order_details od
ON p.product_id = od.product_id
JOIN ecommerce.orders o
ON od.order_id = o.order_id
WHERE DATE_FORMAT(o.created_at, '%Y-%m') = '2019-12'
GROUP BY p.desc_product
ORDER BY total_quantity DESC
LIMIT 5;

-- Displays 10 transactions from purchases from user with user_id 12476, 
-- sorted by largest transaction value. Display seller_id, buyer_id, transaction_value, and transaction_date variables
SELECT 
	seller_id, 
    buyer_id, 
    total AS transaction_value, 
    created_at AS transaction_date
FROM ecommerce.orders
WHERE buyer_id = 12476
ORDER BY 3 DESC
LIMIT 10;

-- Transactions per month in 2020.
SELECT 
	EXTRACT(YEAR_MONTH FROM created_at) AS year_month_, 
    count(1) AS total_transaction, 
    SUM(total) AS total_value_transaction
FROM ecommerce.orders
WHERE created_at>='2020-01-01'
GROUP BY 1
ORDER BY 1;

-- Top 10 users with the highest average transactions in January 2020
SELECT 
	buyer_id, 
    COUNT(1) AS total_transaction, 
    AVG(total) AS avg_value_transaction
FROM ecommerce.orders
WHERE created_at>='2020-01-01' AND created_at<'2020-02-01'
GROUP BY 1
HAVING count(1)>=  2
ORDER BY 3 DESC
LIMIT 10;

-- Buyers who have large transactions in December 2019 with a minimum transaction value of 20,000,000
SELECT 
	nama_user AS buyer_name, 
    total AS value_transaction, 
    created_at AS transaction_date
FROM ecommerce.orders
INNER JOIN ecommerce.users ON buyer_id = user_id
WHERE 
	created_at>='2019-12-01' AND created_at<'2020-01-01'
	AND total >= 20000000
ORDER BY 1;

-- Top 5 Categories with the highest total quantity in 2020, only for transactions that have been sent to buyers.
SELECT 
	category, 
    sum(quantity) AS total_quantity, 
    sum(price) AS total_price
FROM ecommerce.orders
INNER JOIN ecommerce.order_details USING(order_id)
INNER JOIN ecommerce.products USING(product_id)
WHERE 
	created_at>='2020-01-01' AND delivery_at IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Buyers who have made transactions more than 5 times, and each transaction is more than 2,000,000.
SELECT
	nama_user AS buyer_name,
	count(1) AS total_transaction,
	sum(total) AS total_value_transaction,
	min(total) AS min_value_transaction
FROM
	ecommerce.orders
INNER JOIN
	ecommerce.users
	ON buyer_id = user_id
GROUP BY
	user_id,
	nama_user
HAVING
	count(1) > 5 AND min(total) > 2000000
ORDER BY
	3 DESC;

-- Looking for Dropshipper
SELECT
	nama_user AS buyer_name,
	count(1) AS total_transaction,
	count(DISTINCT orders.kodepos) AS distinct_kodepos,
	sum(total) AS total_value_transaction,
	avg(total) AS avg_value_transaction
FROM
	ecommerce.orders 
INNER JOIN
	ecommerce.users
	ON buyer_id = user_id
GROUP BY
	user_id,
	nama_user
HAVING
	count(1) >= 10 AND count(1) = count(DISTINCT orders.kodepos)
ORDER BY 2 DESC;
