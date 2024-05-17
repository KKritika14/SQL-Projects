--SQL Advance Case Study

--Q1. List all the states in which we have customers who have bought cellphones from 2005 till today.
--Q1--BEGIN 

Begin
Select State 
From DIM_LOCATION as DL
Join FACT_TRANSACTIONS as FT
On DL.IDLocation = FT.IDLocation
Where year(Date) between 2005 and Getdate()
Group by State
End 

--Q1--END

--Q2.  What state in the US is buying the most 'Samsung' cell phones?
--Q2--BEGIN

Begin
Select Top 1 State  
From (Select State, Count(IDCustomer) as Model_Count 
		From FACT_TRANSACTIONS as FT
		Join DIM_LOCATION as DL
			On FT.IDLocation = DL.IDLocation
		Join DIM_MODEL as DM
			On FT.IDModel = DM.IDModel
		Where DL.Country like 'US%'
			 and  
			 DM.IDManufacturer = '12'
		Group by State) as Q
Order by Model_Count desc
End 

--Q2--END

--Q3. Show the number of transactions for each model per zip code per state.
--Q3--BEGIN      

Begin 
Select Distinct Model_Name ,State, ZipCode, Count(IDCustomer) as Tran_Count
	From FACT_TRANSACTIONS as FT
	Join DIM_LOCATION as DL
		On FT.IDLocation = DL.IDLocation
	Join DIM_MODEL as DM
		On FT.IDModel = DM.IDModel
	Group by Model_Name ,State, ZipCode
End 

--Q3--END

--Q4. Show the cheapest cellphone (Output should contain the price also)
--Q4--BEGIN

Begin
Select Top 1 Model_Name, Unit_price 
From DIM_MODEL
Order by  Unit_price Asc
End

--Q4--END

--Q5. Find out the average price for each model in the top5 manufacturers in 
--terms of sales quantity and order by average price. 
--Q5--BEGIN

Begin 
WITH Top_Manf AS (
    SELECT TOP 5 DMA.IDManufacturer
    FROM FACT_TRANSACTIONS AS FT
    JOIN DIM_MODEL AS DM ON FT.IDModel = DM.IDModel
    JOIN DIM_MANUFACTURER AS DMA ON DM.IDManufacturer = DMA.IDManufacturer
    GROUP BY DMA.IDManufacturer
    ORDER BY SUM(Quantity) DESC
)
SELECT DM.Model_Name, AVG(Unit_Price) AS Avg_Price
FROM FACT_TRANSACTIONS AS FT
JOIN DIM_MODEL AS DM ON FT.IDModel = DM.IDModel
JOIN DIM_MANUFACTURER AS DMA ON DM.IDManufacturer = DMA.IDManufacturer
WHERE DMA.IDManufacturer IN (SELECT IDManufacturer FROM Top_Manf)
GROUP BY DM.Model_Name
ORDER BY Avg_Price DESC
End 


--Q5--END

--Q6. List the names of the customers and the average amount spent in 2009, 
-- the average is higher than 500
--Q6--BEGIN

Begin
Select Customer_Name, avg(TotalPrice) as Avg_Price
From FACT_TRANSACTIONS as FT
Join DIM_DATE as DD
	on FT.Date = DD.DATE
Join DIM_CUSTOMER as DC
	on FT.IDCustomer = DC.IDCustomer
Where DD.Year = '2009'
Group by Customer_Name
Having Avg(TotalPrice) >500
End

--Q6--END

--Q7. List if there is any model that was in the top 5 in terms of quantity, 
-- simultaneously in 2008, 2009 and 2010 
--Q7--BEGIN  

Begin
SELECT IDModel
FROM (
    SELECT TOP 5 IDModel, SUM(Quantity) as Total_Qty, YEAR(Date) as Year
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2008
    GROUP BY IDModel, YEAR(Date)
    ORDER BY SUM(Quantity) DESC
) AS A
Intersect
SELECT IDModel
FROM (
    SELECT TOP 5 IDModel, SUM(Quantity) as Total_Qty, YEAR(Date) as Year
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2009
    GROUP BY IDModel, YEAR(Date)
    ORDER BY SUM(Quantity) DESC
) AS B
Intersect
SELECT IDModel
FROM(
    SELECT TOP 5 IDModel, SUM(Quantity) as Total_Qty, YEAR(Date) as Year
    FROM FACT_TRANSACTIONS
    WHERE YEAR(Date) = 2010
    GROUP BY IDModel, YEAR(Date)
    ORDER BY SUM(Quantity) DESC
) AS C
End 

--Q7--END

--Q8. Show the manufacturer with the 2nd top sales in the year of 2009 and the 
--manufacturer with the 2nd top sales in the year of 2010.
--Q8--BEGIN

Begin
SELECT TOP 1 MANUFACTURER_NAME 
FROM DIM_MANUFACTURER as DM
JOIN DIM_MODEL as DMO 
ON DM.IDMANUFACTURER= DMO.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS as FT 
ON DMO.IDModel= FT.IDMODEL
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(TOTALPRICE) DESC
End

--Q8--END

--Q9. Show the manufacturers that sold cellphones in 2010 but did not in 2009. 
--Q9--BEGIN

Begin
Select IDManufacturer
From FACT_TRANSACTIONS as FT
Join DIM_DATE as DD
	on FT.Date= DD.DATE
Join DIM_MODEL as DM
	On FT.IDModel = DM.IDModel
Where Year = '2010'
Group by IDManufacturer
Except
Select IDManufacturer
From FACT_TRANSACTIONS as FT
Join DIM_DATE as DD
	on FT.Date= DD.DATE
Join DIM_MODEL as DM
	On FT.IDModel = DM.IDModel
Where Year = '2009'
Group by IDManufacturer
End

--Q9--END

--Q10. Find top 100 customers and their average spend, average quantity by each 
--year. Also find the percentage of change in their spend.
--Q10--BEGIN

Begin
WITH Top_10 As(
		Select Top 10 Customer_Name, Sum(TotalPrice) as Price
		From FACT_TRANSACTIONS as FT 
		Join DIM_CUSTOMER as DC 
		on FT.IDCustomer = DC.IDCustomer
		Group by Customer_Name
		Order by Price DESC
), 
TBL_Year As(
		Select Customer_Name, Year(Date) as Years, Avg(TotalPrice) as Avg_Price, Avg(Quantity) as Avg_Qty
		From FACT_TRANSACTIONS as FT
		Join DIM_CUSTOMER as DC
		on FT.IDCustomer = DC.IDCustomer
		Where Customer_Name IN (Select Customer_Name From Top_10)
		Group by Customer_Name, Year(Date)
		), 
Prev_Year As (
    Select *,
           Lag(Avg_Price, 1) over (Partition by Customer_Name order by Years) as Prev_Price
      From Tbl_Year
)
Select*, ((Avg_Price - Prev_Price)/Prev_Price*100) as Percentage_Price
From Prev_Year
Endx

--Q10--END



