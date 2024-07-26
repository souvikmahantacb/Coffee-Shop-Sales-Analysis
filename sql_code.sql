create database coffe_shop;
use coffe_shop;
describe coffee_shop_sales;

update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s') ;

alter table coffee_shop_sales
modify column transaction_time time;

update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%m/%d/%Y') ;

alter table coffee_shop_sales
modify column transaction_date date;

-- total sales of particular month
select sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where month(transaction_date)= 5; -- may month

-- month on month increase or decrease in sales

select
month(transaction_date) as month,
round(sum(transaction_qty * unit_price)) as total_sales,
(sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price), 1) 
over (order by month(transaction_date))) / lag(sum(transaction_qty * unit_price), 1)
over (order by month(transaction_date))*100 as percentage
from coffee_shop_sales
where month(transaction_date) in (3,4)
group by month(transaction_date)
order by month(transaction_date);

-- difference in sales between selected month and previous month
select
month(transaction_date) as month,
sum(transaction_qty * unit_price) - lag(sum(transaction_qty * unit_price), 1)
over (order by month(transaction_date)) as difference
from coffee_shop_sales
where month(transaction_date) in (3,4)
group by month(transaction_date)
order by month(transaction_date);

-- total order in a particular month
select count(transaction_id) as total_order
from coffee_shop_sales
where month(transaction_date) = 4;

-- month on month increase or decrease in number of sales
SELECT
    MONTH(transaction_date) AS month,
    COUNT(transaction_id) AS total_sales,
    ROUND(
        (COUNT(transaction_id) - LAG(COUNT(transaction_id)) OVER (ORDER BY MONTH(transaction_date))) 
        / LAG(COUNT(transaction_id)) OVER (ORDER BY MONTH(transaction_date)) * 100, 2
    ) AS percentage
FROM coffee_shop_sales
WHERE MONTH(transaction_date) IN (3, 4)
GROUP BY MONTH(transaction_date)
ORDER BY MONTH(transaction_date);

-- total quantity sold for each respective month
select sum(transaction_qty) as total_qty
from coffee_shop_sales
WHERE MONTH(transaction_date) = 6;

-- calender heat map
select concat(round(count(transaction_id)/1000,1), 'k') as total_order,
concat(round(sum(transaction_qty * unit_price)/1000,1), 'k') as total_sales,
concat(round(sum(transaction_qty)/1000,1), 'k') as total_qty_saled
from coffee_shop_sales
where transaction_date= '2023-05-04';

-- sales on weekdays and weekends
select 
case when dayofweek(transaction_date) in(1,7) then 'weekends'
else 'weekdays'
end as day_type,
concat(round(sum(transaction_qty * unit_price)/1000, 1), 'k') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by
case when dayofweek(transaction_date) in(1,7) then 'weekends'
else 'weekdays'
end ;

-- avg sales of respective month
select avg(total_sales) as avg_sales
from
(select sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date) as innner_querry;

-- sales by day
select 
day(transaction_date) as day_of_month,
round(sum(transaction_qty * unit_price), 2) as total_sales
from coffee_shop_sales
where month(transaction_date) = 4
group by day(transaction_date)
order by day(transaction_date);

-- sales status of each day
select
day_of_month,
case 
	when total_sales>avg_sales then 'above avg sales'
    when total_sales<avg_sales then 'below avg sales'
    end as sales_status, 
    total_sales
from (
select day(transaction_date) as day_of_month,
sum(transaction_qty * unit_price) as total_sales,
avg (sum(transaction_qty * unit_price))  OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
-- sales accross diff catagory
select product_category, sum(transaction_qty * unit_price) as total_sales
from coffee_shop_sales
group by product_category
order by total_sales desc
limit 10;

-- sales by hour and date

select sum(transaction_qty * unit_price) as total_sales,
sum(transaction_qty) as total_order,
count(*)
from coffee_shop_sales
where month(transaction_date)= 5
and dayofweek(transaction_date)= 2
and hour(transaction_time)= 8









