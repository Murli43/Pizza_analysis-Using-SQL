-- Selecting the `pizza_sales` database to ensure all subsequent queries are executed within the correct database context.
USE pizza_sales;


-- Selecting all records from the `orders` table to view order details such as order ID, order date, and time.
SELECT * FROM orders;

-- Selecting all records from the `order_details` table to analyze order-specific details, including the quantity of each pizza ordered and the associated order ID.
SELECT * FROM order_details;

-- Selecting all records from the `pizzas` table to retrieve pizza-related information, such as pizza ID, price, and type.
SELECT * FROM pizzas;

-- Selecting all records from the `pizza_types` table to understand different pizza categories and their names.
SELECT * FROM pizza_types;



--Q1. Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS Total_orders 
FROM 
    orders;


--Q2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(OD.quantity * P.price),0) AS total_revenue
FROM 
    order_details AS OD 
    JOIN 
    pizzas AS P ON OD.pizza_id = P.pizza_id;

--Q3. Identify the highest-priced pizza.
SELECT TOP 1
            pt.name, p.price 
FROM 
    pizzas AS p 
    JOIN pizza_types AS pt ON P.pizza_type_id = pt.pizza_type_id
ORDER BY 
    p.price DESC;

--Q4. Identify the most common pizza size ordered.
SELECT TOP 1 
            COUNT(OD.order_id) AS order_counts, p.[size]
FROM 
    order_details AS od 
JOIN pizzas AS p  ON od.pizza_id = p.pizza_id
GROUP BY 
        p.[size]
ORDER BY 
        order_counts DESC;

--Q5. List the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5 
            pt.name, SUM(od.quantity) AS Quantities
FROM 
    order_details AS od 
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
        pt.name
ORDER BY 
        Quantities DESC;

--Q6. Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS Quantity
FROM 
    order_details AS od 
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
        pt.category
ORDER BY 
        Quantity DESC;


--Q7. Determine the distribution of orders by hour of the day.
SELECT  
    DATEPART(HOUR, [time]) AS hour, COUNT(order_id) AS Order_count
FROM 
    orders
GROUP BY 
        DATEPART(HOUR, [time])
ORDER BY 
        Order_count;


--Q8. Join relevant tables to find the category-wise distribution of pizzas.
SELECT  
    pt.category, COUNT(p.pizza_id) AS Pizza_count
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.category
ORDER BY 
    Pizza_count DESC;


--9. Group the orders by date and calculate the average number of pizzas ordered per day.
WITH daily_orders AS (
    SELECT 
            o.[date],SUM(od.quantity) AS Total_Quantity
    FROM orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY 
            o.[date]
)
SELECT AVG(Total_Quantity) AS avg_pizza_ordered_per_day
FROM daily_orders;


--Q10. Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP 3 
        pt.name, SUM(od.quantity * p.price) AS revenue
FROM order_details AS od 
JOIN  pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
        pt.name 
ORDER BY 
        revenue DESC;


--Q11. Calculate the percentage contribution of each pizza type to total revenue.
WITH TotalSales AS (
    SELECT 
            SUM(od.quantity * p.price) AS total_revenue
    FROM order_details AS od 
    JOIN pizzas AS p ON od.pizza_id = p.pizza_id
)
SELECT 
        pt.category,ROUND(SUM(od.quantity * p.price) *100 / ts.total_revenue,2) AS revenue_percentage
FROM order_details AS od 
JOIN pizzas AS p ON od.pizza_id = p.pizza_id 
JOIN pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
CROSS JOIN TotalSales AS ts
GROUP BY   
        pt.category, ts.total_revenue
ORDER BY 
        revenue_percentage DESC;


--Q12. Analyze the cumulative revenue generated over time.
WITH Sales AS (
    SELECT 
        o.[date],ROUND(SUM(od.quantity * p.price),2) AS revenue
    FROM 
        orders AS o 
    JOIN order_details AS od ON o.order_id = od.order_id
    JOIN pizzas AS p ON od.pizza_id = p.pizza_id
    GROUP BY 
        o.[date]
)
SELECT 
        s1.[date], SUM(s2.revenue) AS cum_revenue
FROM 
        Sales AS s1
JOIN Sales AS s2 ON s2.[date] <= s1.[date]
GROUP BY 
        s1.[date]
ORDER BY 
        s1.[date];

        
--Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH RankedSales AS (
    SELECT 
        pt.name, 
        pt.category, 
        SUM(od.quantity * p.price) AS revenue, 
        RANK() OVER(PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rn 
    FROM pizza_types AS pt
    JOIN pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
    JOIN order_details AS od ON p.pizza_id = od.pizza_id
    GROUP BY 
        pt.name, pt.category
)
SELECT name, revenue 
FROM RankedSales
WHERE rn <= 3;


