use music_database
---------------------------------------------EASY------------------------------------------------------------------

---Q1. Who is the senior most employee based on job title?
select top 1 title, levels, first_name, last_name
from Music_Database..employee

order by levels desc

-------------------------------------------------------------------------------

--Q2. Which countries have the most Invoices?

select count(*) as 'Total Count', billing_country
from music_database..invoice
group by billing_country
order by [Total Count] desc

---------------------------------------------------------------------------------


--Q3. What are top 3 values of total invoice?

select top 3 a.total,* 
from music_database..invoice a
order by a.total desc

-------------------------------------------------------------------------------------------------
--Q4.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 

select top 1 sum(a.total) as 'Invoice_Total', billing_city
from invoice a
group by billing_city
order by Invoice_Total desc

--------------------------------------------------------------------------------------------------------

--Q5. Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the most money

select  top 1 a.customer_id,b.first_name, b.last_name, sum(a.total) as 'Amount Spent'
from invoice a
join customer b
on a.customer_id = b.customer_id
group by a.customer_id, first_name, last_name
order by [Amount Spent] desc

---------------------------------------------------------------------------------------------------------------
--------------------------------------------------Moderate------------------------------------------------------

--Q1. Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A

select distinct e.first_name, e.last_name, e.email, a.name
from genre a
join track b
on a.genre_id = b.genre_id
join invoice_line c
on b.track_id = c.track_id
join invoice d
on c.invoice_id = d.invoice_id
join customer e
on d.customer_id = e.customer_id
where a.name = 'Rock'
order by email asc

----------------------------------------------------------------------------------

--Q2. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

select top 10 a.name, count(a.artist_id) as 'Songs_count'
from artist a
join Music_Database..album b
on a.artist_id = b.artist_id
join track c
on b.album_id = c.album_id

join genre d
on c.genre_id = d.genre_id
where d.name = 'Rock'


group by a.name, a.artist_id
order by Songs_count desc

-------------------------------------------------------------------------------------
--Q3. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first


select a.name, a.milliseconds 
from track a
where a.milliseconds > (select AVG(milliseconds) from track b)

order by milliseconds desc

--select AVG (milliseconds) from track


--------------------------------------------Advance---------------------------------------------
-------------------------------------------------------------------------------------------------

--Q1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

--( Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
--which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
--Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
--so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
--for each artist.) 

drop table #temp1 

	SELECT top 1  d.artist_id, d.name,  (sum ( a.quantity * a.unit_price) ) as 'Sales'
	into #temp1
	from invoice_line a

	join track b
	on a.track_id = b.track_id

	join album c
	on b.album_id = c.album_id

	join artist d
	on c.artist_id = d.artist_id
	
	group by d.artist_id, d.name, a.unit_price*a.quantity
	order by Sales desc

	
	select c.customer_id, concat (c.first_name, ' ', c.last_name) as 'Full_name', sum (c2.quantity * c2.unit_price) as 'Spend', c4.artist_id, c5.name
	from customer c
	join invoice c1
	on c.customer_id = c1.customer_id

	join invoice_line c2
	on c1.invoice_id = c2.invoice_id

	join track c3
	on c2.track_id = c3.track_id

	join album c4
	on c3.album_id = c4.album_id

	join artist c5
	on c4.artist_id = c5.artist_id

	where c4.artist_id in (select artist_id from #temp1)
	group by c.customer_id, c5.name, c.first_name, c.last_name, c4.artist_id
	order by Spend desc


	

---------------------------------------------------------------------------------------------------

--Q2. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres

drop table #temp2

select distinct (c.billing_country),count (b.track_id) as 'Most Popular' ,
d.name,
row_number () over (partition by c.billing_country order by count (b.track_id) desc) as RN 
into #temp2
from track a

join invoice_line b
on a.track_id = b.track_id

join invoice c
on b.invoice_id = c.invoice_id

join genre d
on a.genre_id = d.genre_id

group by billing_country, d.name

select * from #temp2 where RN <= 1

----------------------------------------------------------------------------------------

--Q3. Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount


drop table #temp4
select  a.customer_id, a.billing_country, sum(a.total) as 'Amount_Spend',
row_number () over (partition by a.billing_country order by sum(a.total) desc) as RN 

into #temp4
from invoice a

group by a.customer_id,a.billing_country
order by 2


select billing_country, t.customer_id, Amount_Spend, concat (t1.first_name,' ',t1.last_name) as 'Full_name' 
from #temp4 t

join customer t1
on t.customer_id = t1.customer_id
where RN <= 1
order by billing_country


-------------------------------------
--------------------------------------
--To Validate Advanced Ques 1

use Music_Database

select *
into #temp11
from album where artist_id = 51 

select * from #temp11

select *
into #temp22 -- from track
from track where album_id in (select album_id from #temp11)

select * from #temp22

select *
into #temp33 -- from IL
from invoice_line
where track_id in (select track_id from #temp22)

select * from #temp33
select sum (unit_price*quantity) from #temp33