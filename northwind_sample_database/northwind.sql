-- Retrieve the full names and contract numbers of all employee
SELECT first_name ||''|| last_name AS employee_name, home_phone
FROM employees;

-- Count unique number of products per category
SELECT 
	c.category_name, 
	COUNT(DISTINCT p.product_name) AS product_count
FROM categories c
JOIN products p
ON c.category_id = p.category_id
GROUP BY c.category_name;

-- List all products along with the names of their respective suppliers
SELECT 
	p.product_name, 
	s.company_name AS supplier_name
FROM products p
JOIN suppliers s
ON p.supplier_id = s.supplier_id;

-- Identify customers who have places orders, including their names and locations
SELECT 
	c.company_name, 
	c.city
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id;

-- List the most recent orders that include "Chai" as a product, 
-- displaying orer dates and customer names
SELECT 
	o.order_id, 
	c.company_name, 
	o.order_date
FROM 
	orders o
JOIN 
	order_details od ON o.order_id = od.order_id
JOIN 
	products p ON od.product_id = p.product_id
JOIN 
	customers c ON o.customer_id = c.customer_id
WHERE 
	p.product_name = 'Chai'
ORDER BY 
	o.order_date DESC;

-- Summarize total monthly sales per employee for the year 1997
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_sales
FROM 
    employees e
JOIN 
    orders o ON e.employee_id = o.employee_id
JOIN 
    order_details od ON o.order_id = od.order_id
WHERE 
    EXTRACT(YEAR FROM o.order_date) = 1997
GROUP BY 
    employee_name, order_month;

-- Identify the top three shippers based on the number of orders handled
SELECT 
	s.company_name AS shipper_name,
	COUNT(o.order_id) AS order_count
FROM 
	shippers s
JOIN
	orders o
ON 
	s.shipper_id = o.ship_via
GROUP BY
	shipper_name
ORDER BY
	order_count DESC
LIMIT 3;

-- List countries with total order values exceeding $5000
SELECT 
	o.ship_country,
	SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_order_value
FROM orders o
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.ship_country
HAVING SUM(od.unit_price * od.quantity * (1 - od.discount)) > 5000;

-- Show customer handled by each employee, including employee and customer names
SELECT 
	e.first_name ||''|| e.last_name AS employee_name,
	c.company_name AS customer_name
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN customers c ON o.customer_id = c.customer_id;

-- Identify product sold with a discount exceeding 20%, along with the order details
SELECT
	p.product_name,
	od.quantity,
	od.unit_price,
	od.discount
FROM order_details od
JOIN products p
ON od.product_id = p.product_id
WHERE od.discount > 0.2;
