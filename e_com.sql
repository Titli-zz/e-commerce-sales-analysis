--basic 

select count (*) from customer
select count (*) from product
select count (*) from sale

select order_status , count(*) as total_order
from sale
where order_status in ('Delivered', 'Cancelled', 'Returned', 'Shipped',
'Processing')
group by order_status
order by total_order desc

select order_id,total_amount
from sale
order by total_amount desc 
limit 10

select count(*) as total_customer
from customer
where state = 'West Bengal'

--groupby & agg

select sum(total_amount) as total_revenue
from sale
where order_status= 'Delivered'

select category,
       sum(total_amount) as revenue,
       count(distinct order_id) as num_of_orders
from sale
where order_status = 'Delivered'
group by category
order by revenue desc;

select state,city, sum(total_amount) as revenue
from sale
where order_status= 'Delivered'
group by state ,city
order by revenue desc
limit 10

select payment_mode, sum(total_amount) as revenue
from sale
where order_status= 'Delivered'
group by payment_mode
order by revenue desc


select category, count(order_status) as total_order,
sum(case 
when order_status='Cancelled' then 1 else 0 end 
)*100.0/count(*) as cancel_rate,

sum(case 
when order_status='Returned' then 1 else 0 end 
)*100.0/count(*) as return_rate

from sale
group by category
order by cancel_rate desc ,return_rate desc

select age_group, avg(total_amount) as avg_rev
from sale
where order_status= 'Delivered'
group by age_group
order by avg_rev desc

--join

select c.customer_id, c.customer_name, sum(s.total_amount) as revenue
from sale s
join customer c
  on s.customer_id = c.customer_id
where s.order_status = 'Delivered'
group by c.customer_id, c.customer_name
order by revenue desc
limit 10;

select count(distinct c.customer_id) as customer_never_order
from customer c
left join sale s
on s.customer_id=c.customer_id
where s.customer_id is NULL


select p.product_id,p.product_name,p.stock_quantity,coalesce(sum(s.quantity),0) as total_quantity_sold
from product p
left join sale s
on p.product_id=s.product_id and s.order_status='Delivered'
group by p.product_id,p.product_name,p.stock_quantity
order by p.stock_quantity asc, total_quantity_sold desc
limit 10


SELECT
    DATE_TRUNC('month', c.registration_date::DATE)::DATE AS registration_month,
    COUNT(DISTINCT c.customer_id) AS registered_customers,
    COUNT(DISTINCT s.customer_id) AS customers_who_bought
FROM customer c
LEFT JOIN sale s
    ON c.customer_id = s.customer_id
GROUP BY DATE_TRUNC('month', c.registration_date::DATE)
ORDER BY registration_month;


SELECT
    EXTRACT(YEAR FROM c.registration_date::DATE) AS year,
    EXTRACT(MONTH FROM c.registration_date::DATE) AS month,
    COUNT(DISTINCT c.customer_id) AS registered_customers,
    COUNT(DISTINCT s.customer_id) AS customers_who_bought
FROM customer c
LEFT JOIN sale s
    ON c.customer_id = s.customer_id
GROUP BY
    EXTRACT(YEAR FROM c.registration_date::DATE),
    EXTRACT(MONTH FROM c.registration_date::DATE)
ORDER BY year, month;

--case,ctes

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date::DATE)::DATE AS month,
        SUM(total_amount) AS revenue
    FROM sale
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date::DATE)
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND((
        (revenue - LAG(revenue) OVER (ORDER BY month))
        * 100.0
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0))::numeric,
        2
    ) AS mom_change_percent
FROM monthly_revenue
ORDER BY month;


with product_sale as(
select p.category,p.product_id,p.product_name,sum(s.total_amount) as rev
from product p
join sale s 
on p.product_id=s.product_id
where s.order_status = 'Delivered'
group by p.category,p.product_id,p.product_name
),
ranked_pro as(
select  category,product_id,product_name,rev,
rank() over(partition by category order by rev desc) as pro_rank
from product_sale
)

select * 
from ranked_pro
where pro_rank<=3
order by  category,pro_rank


with customer_spending as(
select s.customer_id,sum(s.total_amount) as total_spent
from sale s
WHERE order_status = 'Delivered'
group by s.customer_id
)

select c.customer_id,c.customer_name,coalesce(cs.total_spent,0) as total_spent,
case 
when coalesce(cs.total_spent,0)>=170000 then 'high'
when coalesce(cs.total_spent,0)>=38000 then 'medium'
else 'low'
end as spending_sagement
from customer c
left join customer_spending cs
on c.customer_id=cs.customer_id
order by total_spent desc


WITH customer_spending AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent
    FROM sale
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        c.customer_id,
        CASE
            WHEN COALESCE(cs.total_spent, 0) >= 170000 THEN 'High'
            WHEN COALESCE(cs.total_spent, 0) >= 38000 THEN 'Medium'
            ELSE 'Low'
        END AS spending_segment
    FROM customer c
    LEFT JOIN customer_spending cs
        ON c.customer_id = cs.customer_id
)
SELECT
    spending_segment,
    COUNT(*) AS customer_count
FROM customer_segments
GROUP BY spending_segment
ORDER BY
    CASE spending_segment
        WHEN 'High' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Low' THEN 3
    END;



WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date::DATE)::DATE AS month,
        SUM(total_amount) AS revenue
    FROM sale
    WHERE order_status = 'Delivered'
    GROUP BY DATE_TRUNC('month', order_date::DATE)
)
SELECT
    month,
    revenue,
    SUM(revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM monthly_revenue
ORDER BY month;


WITH category_revenue AS (
    SELECT
        category,
        SUM(total_amount) AS revenue
    FROM sale
    WHERE order_status = 'Delivered'
    GROUP BY category
)
SELECT
    category,
    revenue,
    SUM(revenue) OVER () AS total_revenue,
    ROUND((
        revenue * 100.0 /(SUM(revenue) OVER ()))::numeric,
        2
    ) AS revenue_share_percent
FROM category_revenue
ORDER BY revenue_share_percent DESC;


--business case

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM sale
	where order_status = 'Delivered'
    GROUP BY customer_id
)
select round(
           (count(*) filter (where total_orders > 1) * 100.0 / count(*))::numeric,
           2
       ) as repeat_customer_percent
from customer_orders;



WITH last_orders AS (
    SELECT customer_id, MAX(order_date::DATE) AS last_order_date
    FROM sale
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
)
SELECT c.customer_id, c.customer_name, lo.last_order_date
FROM customer c
JOIN last_orders lo ON c.customer_id = lo.customer_id
WHERE lo.last_order_date < (SELECT MAX(order_date::DATE) FROM sale) - INTERVAL '180 days'
ORDER BY lo.last_order_date;


SELECT
    age_group,
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(total_amount) AS revenue
FROM sale
WHERE order_status = 'Delivered'
GROUP BY age_group, category
ORDER BY age_group, revenue DESC;


SELECT
    DATE_TRUNC('month', order_date::DATE)::DATE AS month,

    SUM(CASE
        WHEN order_status = 'Cancelled' THEN total_amount
        ELSE 0
    END) AS cancelled_amount,

    SUM(CASE
        WHEN order_status = 'Returned' THEN total_amount
        ELSE 0
    END) AS returned_amount,

    SUM(CASE
        WHEN order_status IN ('Cancelled', 'Returned')
        THEN total_amount
        ELSE 0
    END) AS total_affected_amount,

    ROUND(
        (
            SUM(CASE
                WHEN order_status IN ('Cancelled', 'Returned')
                THEN total_amount
                ELSE 0
            END) * 100.0
            / NULLIF(SUM(total_amount), 0)
        )::NUMERIC,
        2
    ) AS affected_revenue_percent

FROM sale
GROUP BY DATE_TRUNC('month', order_date::DATE)
ORDER BY month;


SELECT
    CASE
        WHEN COALESCE(coupon_discount, 0) > 0
            THEN 'Coupon order'
        ELSE 'No coupon'
    END AS coupon_group,

    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(total_amount)::NUMERIC, 2) AS average_order_value

FROM sale
WHERE order_status = 'Delivered'
GROUP BY
    CASE
        WHEN COALESCE(coupon_discount, 0) > 0
            THEN 'Coupon order'
        ELSE 'No coupon'
    END
ORDER BY average_order_value DESC;



SELECT
    city,

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status = 'Returned'
    ) AS returned_orders,

    ROUND(
        (
            COUNT(DISTINCT order_id) FILTER (
                WHERE order_status = 'Returned'
            ) * 100.0
            / NULLIF(COUNT(DISTINCT order_id), 0)
        )::NUMERIC,
        2
    ) AS return_rate_percent

FROM sale
GROUP BY city
ORDER BY return_rate_percent DESC NULLS LAST;