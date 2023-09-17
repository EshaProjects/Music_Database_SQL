use music_database
---------------------------------------------EASY------------------------------------------------------------------

---Q1. Who is the senior most employee based on job title?
select max(birthdate), first_name, last_name
from Music_Database..employee
where levels = 'L7'
group by birthdate, first_name, last_name

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
--listeners. Return your list ordered alphabetically by email starting with Aselect distinct e.first_name, e.last_name, e.email, a.namefrom genre ajoin track bon a.genre_id = b.genre_idjoin invoice_line con b.track_id = c.track_idjoin invoice don c.invoice_id = d.invoice_idjoin customer eon d.customer_id = e.customer_idwhere a.name = 'Rock'order by email asc------------------------------------------------------------------------------------Q2. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bandsselect top 10 a.name, count(a.artist_id) as 'Songs_count'from artist ajoin Music_Database..album bon a.artist_id = b.artist_idjoin track con b.album_id = c.album_idjoin genre don c.genre_id = d.genre_idwhere d.name = 'Rock'group by a.name, a.artist_idorder by Songs_count desc---------------------------------------------------------------------------------------Q3. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed firstselect a.name, a.milliseconds from track awhere a.milliseconds > (select AVG(milliseconds) from track b)order by milliseconds desc--select AVG (milliseconds) from track--------------------------------------------Advance------------------------------------------------------------------------------------------------------------------------------------------------Q1. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

--select  a.customer_id, 
--CONCAT( c.first_name, ' ', c.last_name) as 'Full_Name', 
--sum(b.unit_price*b.quantity) as 'Total_Spent', 
--f.name
--into #temp1
--from invoice a

--join invoice_line b
--on a.invoice_id = b.invoice_id

--join customer c
--on a.customer_id = c.customer_id

--join track d
--on d.track_id = b.track_id

--join album e
--on d.album_id = e.album_id

--join artist f
--on e.artist_id = f.artist_id
--group by 1,4--a.customer_id-- c.first_name, c.last_name, b.unit_price, b.quantity, f.name

--select * from #temp1

--select top 10* from customer

---------------------------------------------------------------------------------------------------

--Q2. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres

drop table 
#temp2

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

-------------------------------------------------------------------------


