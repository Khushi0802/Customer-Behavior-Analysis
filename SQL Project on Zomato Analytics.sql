drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'22-09-2017'),
(3,'21-04-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'02-09-2014'),
(2,'15-01-2015'),
(3,'11-04-2014');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'18-12-2019',1),
(2,'20-07-2020',3),
(1,'23-10-2019',2),
(1,'19-03-2018',3),
(3,'20-12-2016',2),
(1,'09-11-2016',1),
(1,'20-05-2016',3),
(2,'24-09-2017',1),
(1,'11-03-2017',2),
(1,'11-03-2016',1),
(3,'10-11-2016',1),
(3,'07-12-2017',2),
(3,'15-12-2016',2),
(2,'08-11-2017',2),
(2,'10-09-2018',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;



1 ---- what is total amount each customer spent on zomato ?

Select s.userid, SUM(p.price) as total_amount_spent
from sales s
inner join product p
on s.product_id=p.product_id
group by s.userid


2 ---- How many days has each customer visited zomato?

SELECT userid, COUNT(DISTINCT created_date) as distinct_days
from sales
group by userid


3 --- what was the first product purchased by each customer?

select *
from (
	select *, RANK() OVER (Partition by userid order by created_date asc) as rnk
	from sales
) s
where rnk=1;


4 --- what is most purchased item on menu & how many times was it purchased by all customers ?

SELECT product_id, COUNT(*) AS total_purchases
FROM sales
GROUP BY product_id
ORDER BY COUNT(*) DESC
LIMIT 1;


5 ---- which item was most popular for each customer?

SELECT * 
FROM (SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk
    FROM (SELECT userid, product_id, COUNT(product_id) AS cnt 
        FROM sales 
        GROUP BY userid, product_id
    ) a
) b	
where rnk =1;


6 --- which item was purchased first by customer after they become a member ?

SELECT * 
FROM (
    SELECT a.*, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk 
    FROM (
        SELECT s.userid, s.created_date, s.product_id, g.gold_signup_date 
        FROM sales as s
        INNER JOIN goldusers_signup g 
        ON s.userid = g.userid 
        AND s.created_date >= g.gold_signup_date
    ) a
) b 
WHERE rnk = 1;


7 --- which item was purchased just before customer became a member?

SELECT * 
FROM (
    SELECT c.*, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk 
    FROM (
        SELECT a.userid, a.created_date, a.product_id, b.gold_signup_date 
        FROM sales a 
        INNER JOIN goldusers_signup b 
        ON a.userid = b.userid 
        AND a.created_date <= b.gold_signup_date
    ) c
) d 
WHERE rnk = 1;


8 ---- what is total orders and amount spent for each member before they become a member ?

SELECT userid, COUNT(created_date) AS order_purchased, SUM(price) AS total_amt_spent 
FROM (SELECT  c.*, d.price 
    FROM (SELECT s.userid, s.created_date, s.product_id, g.gold_signup_date 
        FROM sales s 
        INNER JOIN goldusers_signup g 
        ON s.userid = g.userid 
        AND s.created_date <= g.gold_signup_date
    ) c 
    INNER JOIN 
        product d 
    ON 
        c.product_id = d.product_id
) e 
GROUP BY userid;



10 --- in the first one year after customer joins the gold program (including the join date ) irrespective of 
  --  what customer has purchased earn 5 zomato points for every 10rs spent who earned more more 1 or 3
   -- what int earning in first yr ? 1zp = 2rs



SELECT c.userid, SUM(p.price * 0.5) AS total_points_earned
FROM (SELECT s.userid, s.created_date, s.product_id, g.gold_signup_date
    FROM sales s
    INNER JOIN goldusers_signup g
    ON s.userid = g.userid
    WHERE s.created_date >= g.gold_signup_date
      AND s.created_date <= g.gold_signup_date + INTERVAL '1 year'
) c
INNER JOIN product p
ON c.product_id = p.product_id
GROUP BY c.userid;



11 --- rnk all transaction of the customers


SELECT *, RANK() over (partition by userid order by created_date ) rnk 
	From sales;
