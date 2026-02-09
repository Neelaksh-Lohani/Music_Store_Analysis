-- LEVEL 1 ---

-- Q1.) Senior most Employee based on the job Title ?
Select 
	first_name,
	last_name,
	levels
from employee
ORDER BY Levels DESC
LIMIT 1;

Select *
from genre

-- Q2.) WHICH COUNTRIES HAVE THE MOST INVOICES?
Select
	COUNT(*) as c,
	billing_country
from invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q3.) WHAT ARE THE TOP 3 VALUES OF THE TOTAL INVOICES
Select *
from invoice
ORDER BY total DESC
limit 3;

-- Q4.) 
Select 
	SUM(total) as invoice_total,
	billing_city
from invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Q5.) 
Select 
	c.customer_id,
	c.first_name,
	c.last_name,
	SUM(i.total) as total
from Customer as c
JOIN invoice as i
ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name, c.customer_id
ORDER BY total DESC
LIMIT 1;

--- LEVEL 2 ---

-- Q1.) 
Select DISTINCT
	c.email,
	c.first_name,
	c.last_name
from Customer as c
JOIN invoice as i
ON c.customer_id = i.customer_id
JOIN invoice_line as il
ON i.invoice_id = il.invoice_id
WHERE track_id IN (
	Select track_id
	from track
	JOIN genre 
	ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email ASC;

-- Q2.) 
Select
	a.name,
	SUM(t.milliseconds) as total_track_time
from Artist as a
JOIN Album as al
ON a.Artist_Id = al.Artist_Id
JOIN track as t
ON t.Album_Id = al.Album_Id
JOIN genre as g
ON g.genre_Id = t.genre_Id
Where g.Name LIKE 'Rock'
Group by a.name
ORDER BY total_track_time DESC
LIMIT 10;

-- Q3.) 
Select
	t.name
from track as t
Where t.milliseconds > (
	Select
	AVG(milliseconds) as avg_track_length
	FROM track
)
ORDER BY milliseconds DESC;


--- LEVEL 3 ---

-- Q1.)
WITH best_selling_artist AS (
    SELECT 
        ar.artist_id,
        ar.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM invoice_line il
    JOIN track t 
        ON t.track_id = il.track_id
    JOIN album al
        ON al.album_id = t.album_id
    JOIN artist ar
        ON ar.artist_id = al.artist_id
    GROUP BY ar.artist_id, ar.name
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name,
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c
    ON c.customer_id = i.customer_id
JOIN invoice_line il
    ON il.invoice_id = i.invoice_id
JOIN track t 
    ON t.track_id = il.track_id
JOIN album al
    ON al.album_id = t.album_id
JOIN best_selling_artist bsa
    ON bsa.artist_id = al.artist_id
GROUP BY 
    c.customer_id,
    c.first_name,
    c.last_name,
    bsa.artist_name
ORDER BY amount_spent DESC;


--Q2.) 
WITH popular_genre AS (
    SELECT
        customer.country,
        genre.name AS genre_name,
        genre.genre_id,
        SUM(invoice_line.quantity) AS purchases,
        ROW_NUMBER() OVER (
            PARTITION BY customer.country
            ORDER BY SUM(invoice_line.quantity) DESC
        ) AS RowNo
    FROM invoice_line
    JOIN invoice 
        ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer 
        ON customer.customer_id = invoice.customer_id
    JOIN track 
        ON track.track_id = invoice_line.track_id
    JOIN genre 
        ON genre.genre_id = track.genre_id
    GROUP BY
        customer.country,
        genre.name,
        genre.genre_id
)

SELECT *
FROM popular_genre
WHERE RowNo = 1;


-- Q3.) 
WITH customer_with_country AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country,
        SUM(i.total) AS total_spending	
    FROM invoice i
    JOIN customer c
        ON c.customer_id = i.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name,
        i.billing_country
),

country_max_spending AS (
    SELECT
        billing_country,
        MAX(total_spending) AS max_spending
    FROM customer_with_country
    GROUP BY billing_country
)

SELECT
    cwc.billing_country,
    cwc.first_name,
    cwc.last_name,
    cwc.total_spending
FROM customer_with_country cwc
JOIN country_max_spending cms
    ON cwc.billing_country = cms.billing_country
   AND cwc.total_spending = cms.max_spending
ORDER BY
    cwc.billing_country;

















