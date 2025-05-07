/* Question 1  Provide the top 10 customers (full name) by revenue, 
the country they shipped to, the cities and -- their revenue (orderqty * unitprice)*/

/*The Required Top 10 Customers are listed in the table below*/

SELECT TOP 10
FirstName + ' ' + LastName AS Full_Name,
SalesLT.Address.CountryRegion AS Country_Shipped_To,
SalesLT.Address.City AS City_Shipped_To,
(Orderqty * UnitPrice) AS Revenue
FROM SalesLT.Customer

JOIN
SalesLT.CustomerAddress ON SalesLT.Customer.CustomerID=SalesLT.CustomerAddress.CustomerID
JOIN
SalesLT.Address ON SalesLT.Address.AddressID = SalesLT.CustomerAddress.AddressID
JOIN
SalesLT.SalesOrderHeader ON SalesLT.Customer.CustomerID = SalesLT.SalesOrderHeader.CustomerID
JOIN
SalesLT.SalesOrderDetail ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID

ORDER BY Revenue desc


/* Question 2 -- Create 4 distinct Customer segments using the total Revenue (orderqty * unitprice) by customer.
-- List the customer details --(ID, Company Name), Revenue and the segment the customer belongs to.
-- This analysis can use to create a loyalty program, market customers --with discount or leave customers as-is*/

WITH CustomerRevenue AS(
SELECT
	c.CustomerID,
	c.CompanyName,
	SUM(OrderQty * UnitPrice) AS TotalRevenue
FROM
	SalesLT.Customer c
JOIN
	SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN
	SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
	c.CustomerID, c.CompanyName
),

segmentedCustomers AS (
	SELECT *,
		NTILE (4) OVER( ORDER BY TotalRevenue DESC) AS RevenueSegment
	FROM CustomerRevenue
)
SELECT
	CustomerID,
	CompanyName,
	TotalRevenue,
CASE RevenueSegment
	WHEN 1 THEN 'Very High'
	WHEN 2 THEN 'High'
	WHEN 3 THEN 'Low'
	WHEN 4 THEN 'Very Low'
END AS CustomerSegment
FROM SegmentedCustomers
ORDER BY TotalRevenue DESC;


/*-- Question 3 -- What products with their respective categories did our
customers buy on our last day of business? -- List the CustomerID,
Product ID, Product Name, Category Name and Order Date. 

The Products bought on the last day are listed on the Table
*/

WITH LastOrderDate AS(
SELECT MAX(OrderDate) MaxOrderDate
FROM SalesLT.SalesOrderHeader
),
LastDayOrder AS (
SELECT soh. SalesOrderID, soh. CustomerID, soh.OrderDate
FROM SalesLT.SalesOrderHeader soh
JOIN
LastOrderDate lod ON soh. OrderDate = lod.MaxOrderDate
)

SELECT
l.CustomerID,
p. ProductID,
p.Name AS Product_Name,
pc.Name AS Category_Name,
l.OrderDate AS Order_Date
FROM LastDayOrder l
JOIN SalesLT.SalesOrderDetail sod ON l.SalesOrderID =sod. SalesOrderID
JOIN SalesLT.Product p ON sod. ProductID = p.ProductID
JOIN SalesLT.ProductCategory pc ON p. ProductCategoryID =pc.ProductCategoryID
ORDER BY Product_Name;


/*-- Question 4 A View called Customer Segment for Question 2 */

CREATE VIEW Customer_Segment AS

WITH CustomerRevenue AS(
SELECT
	c.CustomerID,
	c.CompanyName,
	SUM(OrderQty * UnitPrice) AS TotalRevenue
FROM
	SalesLT.Customer c
JOIN
	SalesLT.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN
	SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY
	c.CustomerID, c.CompanyName
),

segmentedCustomers AS (
	SELECT *,
		NTILE (4) OVER( ORDER BY TotalRevenue DESC) AS RevenueSegment
	FROM CustomerRevenue
)
SELECT
	CustomerID,
	CompanyName,
	TotalRevenue,
CASE RevenueSegment
	WHEN 1 THEN 'Very High'
	WHEN 2 THEN 'High'
	WHEN 3 THEN 'Low'
	WHEN 4 THEN 'Very Low'
END AS CustomerSegment
FROM SegmentedCustomers;


/*-- ** Question 5 -- What are the top 3 selling product (including
productname) in each category (including categoryname) -- by revenue*/

WITH Product_Revenue AS (
SELECT
pc. ProductCategoryID,
pc.NAME AS CategoryName,
p.ProductID,
P.NAME AS ProductName,
SUM(sod.OrderQty*sod UnitPrice) AS TotalRevenue
FROM SalesLT.SalesOrderDetail sod
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
GROUP BY
pc. ProductCategoryID, pc.NAME, p.ProductID, p.NAME
)


RankedProducts AS (
SELECT *,
RANK() OVER (PARTITION BY ProductCategoryID ORDER BY TotalRevenue DESC) AS Ranknum
FROM Product_Revenue
)

SELECT
ProductID,
ProductName,
CategoryName,
RankNum

FROM RankedProducts
WHERE RankNum <= 3
ORDER BY CategoryName, RankNum
