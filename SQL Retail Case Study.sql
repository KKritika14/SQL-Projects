---------------------------------------------------------------- SQL CASE STUDY ----------------------------------------------------------------------------
-------------------------------------------------------DATA PREPARATION AND UNDERSTANDING ------------------------------------------------------------------

-- 1. What is the total number of rows in each of the 3 tables in the database? --
Begin

	Select 'customer' as Table_Name, Count(*) as Total_Row 
	From Customer 
	Union ALL
	Select 'Product Category' as Table_Name, Count(*) as Total_Row 
	From [Product Categoy]
	Union ALL
	Select 'Transactions' as Table_Name, Count(*) as Total_Row 
	From Transactions

End

-- 2. What is the total number of transactions that have a return? 
Begin 
	
	Select Count(*) as Total_Count
	From Transactions
	Where Qty < 0

End

-- 3. As you would have noticed, the date provided across the database are not in a 
-- correct format. As first steps, pls convert the date variable into valid data format
-- before procedding ahead?

/* Answer to Qustion No. 3:  
The data was formatted before import using Custom formatting. However, in SQL, the data 
can be formatted using Convert function where the function will be as following -
CONVERT( new_datatpe, col_name, [informat]) */


-- 4. What is the time range of the transaction data available for analysis? Show the output in 
-- number of days, months and years simultaneously in different columns. 
Begin
	 Select 
	 DATEDIFF (Day, Min(tran_date), Max(tran_Date)) as Total_Days,
	 DATEDIFF (Month, Min(tran_date), Max(tran_Date)) as Total_Months,
	 DATEDIFF (Year, Min(tran_date), Max(tran_Date)) as Total_Years
	 from Transactions
End

-- 5. Which product category does the sub category "DIY" beloong to? 
Begin 
	Select prod_cat_code, prod_cat
	From [Product Categoy]
	Where prod_subcat = 'DIY'
End 

--------------------------------------------------------------------------- DATA ANALYTICS ------------------------------------------------------------------

-- 1. Which channel is most frequenctly used for transactions? 
Begin 
	Select TOP 1 Store_type, count(transaction_id) AS Tran_Count
	From Transactions
	Group by Store_type
	Order by count(transaction_id) desc
End 

-- 2. What is the count of Males and Females customers in the database? 
Begin 
	Select Gender, Count(Gender) as Gender_Count
	From Customer 
	Where Gender IN('F', 'M')
	Group By Gender
End

-- 3. From which city do you have the maximum number of customers and how many? 
Begin 
	Select Top 1 city_code, Count(customer_Id) as Cust_Count 
	From Customer
	Group by city_code
	Order by Count(customer_Id) desc
End

-- 4. How many sub-categories are there under the books Category? 
Begin 
	Select prod_cat , count(prod_subcat) as Sub_Prod_Count
	From [Product Categoy]
	Where prod_cat = 'Books'
	Group by prod_cat
End

-- 5. What is the maximum quantity of products ever ordered? 
Begin 
	Select top 1 Qty as Max_Qty 
	From Transactions
	Order by qty desc
End


-- 6. What is the net total revenue generated in categories Electronics and Books? 
Begin 
	Select PC.prod_cat, Sum(t.total_amt) as PC_Total
	From Transactions as T
	Join [Product Categoy] as PC 
	On t.prod_cat_code = pc.prod_cat_code and t.prod_subcat_code = pc.prod_sub_cat_code
	Where pc.prod_cat IN('Electronics', 'Books')
	Group by PC.prod_cat
End

-- 7. How many customers have >10 transactions with us, excluding returns?
Begin 
	Select count(*) as Count
	From	(Select Cust_id, Count(cust_id) as Tran_Count
			From Transactions
			Where qty >0
			Group by cust_id
			Having count(cust_id) >10) as X
End

-- 8. What is the combined revenue earned from the "Electronics" & "Clothing" Categories
-- from "Flagship stores" ? 
Begin
	Select Sum(T.total_amt) as Comb_Revenue
	From Transactions as T
	Join [Product Categoy] as PC 
	On T.prod_cat_code = PC.prod_cat_code
	and 
	  T.prod_subcat_code = PC.prod_sub_cat_code
	Where PC.prod_cat IN('Electronics', 'clothing')
					AND
		  Store_type like 'Flagship%'
End


-- 9. What is the total revenue generated from "Male" customers in "Electronics" 
-- Category? Output should display total revenue by prod sub-cat. 
Begin 
	Select PC.prod_subcat, Sum(t.total_amt) as Total_Rev
	From  Transactions as T
	Join  Customer as C 
		On T.cust_id =  C.customer_Id 
	Join [Product Categoy] as PC 
		On T.prod_subcat_code = PC.prod_sub_cat_code 
		and 
		T.prod_cat_code = PC.prod_cat_code
	Where Gender = 'M'
				and 
		 PC.prod_cat = 'Electronics'
	Group by PC.prod_subcat	
End		

-- 10. What is percentage of sales and returns by product sub-category; display 
-- only top 5 sub categories in term of sales? 

Begin
	Select prod_subcat, round((total_Sales/(total_Sales+ ABS(Total_Return))*100),2) as Percetage_Sales, 
			round((ABS(total_Return)/(total_Sales+ ABS(Total_Return))*100),2) as Percetage_Sales
	From (select Top 5 prod_subcat, 
			Sum(case 
			when total_amt>0
			Then total_amt
			Else 0 
			End) as Total_Sales,
			Sum(case 
			when total_amt<0
			Then total_amt
			Else 0 
			End) as Total_Return
	From Transactions  as T
	Join [Product Categoy] as PC 
	On T.prod_subcat_code = PC.prod_sub_cat_code and t.prod_cat_code = pc.prod_cat_code
	Group by prod_subcat
	Order by prod_subcat desc
	) as X
End

-- 11. For all customers aged between 25 to 35 years find what is the net total revenue 
-- generated by these consumers in last 30 days of transactions for max transaction
-- Date available in the data? 

Begin
	SELECT SUM(total_amt) AS Total_Amt
    FROM Transactions t
	JOIN Customer AS c 
	ON t.cust_id = c.customer_id
	Where DATEDIFF(year, c.DOB, tran_date) BETWEEN 25 AND 35  -- DateDiff was used calculated with tran_Date and not getdate() because the data shown in the table is 10 years back, which is 2014. 
	AND (tran_date >= DATEADD(DAY, -30, ( SELECT MAX(tran_date) AS max_tran_date FROM Transactions)))
End

-- 12. Which product category has seen the max value of return in the last 3 months of 
-- Transcations ? 

Begin 
  Select top 1 prod_cat_code
  From Transactions
       Where total_amt < 0 and tran_date >= DATEADD(month, -3, ( SELECT MAX(tran_date) AS max_tran_date FROM Transactions)) 
  Group by prod_cat_code
  Order by sum(total_amt) desc
End

-- 13. Which store-type selld the maximun products, by value of sales amounts and by 
-- quantity sold? 

Begin 
	Select top 1 Store_type, sum(qty) as Qty_Count, Sum(total_amt) as Total_Rev
	From Transactions
	Where Qty > 0
	Group By Store_type
	Order by sum(qty) desc
End

-- 14. What are the categories for which average revenue is above the overall average. 

Select prod_cat 
From Transactions as T
Join [Product Categoy] as PC 
on T.prod_cat_code =PC.prod_cat_code
and 
T.prod_subcat_code = PC.prod_sub_cat_code
Group by prod_cat
Having avg(total_amt) > (Select Avg(total_amt)
								From Transactions as T
								Join [Product Categoy] as PC 
								on T.prod_cat_code =PC.prod_cat_code
								and 
								T.prod_subcat_code = PC.prod_sub_cat_code)

-- 15. Find the average and total revenue by each subcategory for the categories which 
-- are among top 5 categories in term of quantity sold. 

  
SELECT prod_cat, prod_subcat, SUM(total_amt) AS Total_Revenue, AVG(total_amt) AS Avg_Revenue 
FROM Transactions as T
JOIN [Product Categoy] as PC 
on T.prod_cat_code =PC.prod_cat_code
and 
T.prod_subcat_code = PC.prod_sub_cat_code
WHERE prod_cat IN (SELECT TOP 5 prod_cat
				  FROM Transactions as T
				  INNER JOIN [Product Categoy] as PC 
				  on T.prod_cat_code =PC.prod_cat_code
				  and 
				  T.prod_subcat_code = PC.prod_sub_cat_code
				  GROUP BY prod_cat
				  ORDER BY SUM(Qty) DESC
				  )
GROUP BY PROD_CAT, PROD_SUBCAT 
  