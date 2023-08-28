/*Using NORTHWIND database*/

--Find all
SELECT * FROM Shippers



--Listing all in ascending order based on CompanyName  [Good]
SELECT * FROM Shippers
ORDER BY CompanyName




--Selecting certain columns
SELECT FirstName, LastName, Title, BirthDate, City
FROM Employees




--Using DISTINCT
SELECT DISTINCT Title FROM employees




--Selecting only selected orders made on a specified date [GREAT]
SELECT *
FROM Orders
WHERE CAST(OrderDate AS DATE) = '1997-05-19';




--Retrieve all info for ppl only in selected cities  [Applying OR]
SELECT * FROM Customers                  --Note that strings always use ' '
WHERE City = 'London' OR City = 'Madrid'




--Using WHERE with ORDER BY
SELECT Phone, ContactName
FROM Customers
WHERE Country = 'uk'    --SQL is case insensitive so doesnt matter if use uk or UK
ORDER BY ContactName




--WHERE with CustomerId
SELECT OrderID, OrderDate
FROM Orders
WHERE CustomerID = 'Hanar'




--Applying string concatenation                          [IMPT!!!!]
SELECT TitleOfCourtesy + ' ' + FirstName + ' ' + LastName
FROM Employees
--Sorting based on LastName        Works geat!!!
SELECT TitleOfCourtesy + ' ' + FirstName + ' ' + LastName
FROM Employees
ORDER BY LastName




--MUST REMEMBER, APPLYING SUB-QUERY!!!!              [SUPER IMPT]
SELECT OrderID, OrderDate  --, CustomerID   --Add if wanna check correct
FROM Orders
WHERE CustomerID IN (
SELECT CustomerID FROM Customers WHERE CompanyName LIKE '%Dewey%'
)                  --Here we used the WHERE-LIKE function as well

--ANOTHER VARIATION, where this time using IN function rather than LIKE
SELECT OrderID, OrderDate  --, CustomerID   --Add if wanna check correct
FROM Orders
WHERE CustomerID IN (
SELECT CustomerID FROM Customers WHERE CompanyName IN ('Maison Dewey')
) 

--ANOTHER VARIATION, where this time using WHERE & = function
SELECT OrderID,OrderDate
FROM Orders WHERE CustomerId IN
	(SELECT Customerid 
	 FROM Customers
     WHERE Companyname ='Maison Dewey');




--Another eg using the WHERE-LIKE argument
SELECT *
FROM Products
WHERE ProductName LIKE '%lager%'




--Using NOT and IN to find item(s) that are not inside another list.  [GREAT]
SELECT CustomerID, ContactName
FROM Customers WHERE CustomerID NOT IN (
SELECT DISTINCT CustomerID FROM Orders
)




--Using AVG() to calculate average and AS function to name your result header [GREAT]
SELECT AVG(UnitPrice) AS AvgProductPrice FROM PRODUCTS




--Using DISTINCT
SELECT DISTINCT City FROM Customers




--Notice how we can use DISTINCT within an aggregation function!!!
SELECT COUNT(DISTINCT CustomerID)
FROM Customers WHERE CustomerID IN (
SELECT CustomerID FROM Orders
)



--Using IS NULL to det which customers have no fax no.    [USEFUL]
SELECT CompanyName, Phone
FROM Customers
WHERE Fax IS NULL



--Using SUM() function to find the total of all the values identified
SELECT SUM(UnitPrice * Quantity)
AS TotalSales FROM [Order Details]




--Complex!!! Using IN function to specify a range of values.        [GREAT]
--Finding the orderID based on the orderID of the Customer that we want as identified from another table.
SELECT OrderID, CustomerID
FROM Orders WHERE Orders.CustomerID IN (
SELECT CustomerID
FROM Customers WHERE Customers.CompanyName IN ('Alan Out','Blone Coy')
)




--Using GROUP BY
SELECT CustomerID, Count(*) AS NumOrders
FROM Orders
GROUP BY CustomerID




--Joining two tables to retrieve a specific coy's no of orders
SELECT c.CompanyName, o.OrderID
FROM Customers c, Orders o
WHERE c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, CompanyName, o.OrderID
HAVING c.CustomerID = 'BONAP'



--A complex example involving GROUP BY, join function and many more
SELECT Count(*) AS NumberOfOrdersMade, o.CustomerID, c.CompanyName
FROM Orders o, Customers c
WHERE o.CustomerID = c.CustomerID   --This here indicates the binding factor for the joining to take place
GROUP BY o.CustomerID, c.CompanyName
HAVING COUNT(*) > 10
ORDER BY COUNT(*) DESC

--Another variation but same result, using JOIN and ON
select count(*), O.CustomerID,C.CompanyName
from Orders O INNER JOIN Customers C
ON C.CustomerID=O.CustomerID
group by O.CustomerID, c.companyname
having count(*) > 10 order by count(*);



--Specifically finding the no.of orders made by a specific company with custID 'BONAP'       [GREAT]
SELECT Count(*) AS NumberOfOrdersMade, o.CustomerID, c.CompanyName
FROM Orders o, Customers c
WHERE o.CustomerID = c.CustomerID   
GROUP BY o.CustomerID, c.CompanyName
HAVING o.CustomerID = 'BONAP'

--Another variation but same result, using JOIN and ON
select count(*), O.CustomerID,C.CompanyName from Orders O INNER JOIN Customers C
ON C.CustomerID=O.CustomerID and c.customerid ='BONAP'
group by O.CustomerID, c.companyname




--A more complex use of the HAVING function rather than using simple integers [GREAT]
SELECT Count(*) AS NumberOfOrdersMade, o.CustomerID, c.CompanyName
FROM Orders o, Customers c
WHERE o.CustomerID = c.CustomerID   
GROUP BY o.CustomerID, c.CompanyName
HAVING COUNT(*) > (SELECT Count(*) FROM Orders WHERE CustomerID = 'BONAP')

--Another variation but same result, using JOIN and ON
select count(*), O.CustomerID,C.CompanyName
from Orders O INNER JOIN Customers C
ON C.CustomerID=O.CustomerID
group by O.CustomerID, c.companyname
having count(*) > (select count(*) from Orders O INNER JOIN Customers C
ON C.CustomerID=O.CustomerID and c.customerid ='BONAP'
group by O.CustomerID)




--Straightforward, just print out those products that are either cat 1 or 2
SELECT ProductID, ProductName, CategoryID
FROM Products
WHERE CategoryID = 1 OR CategoryID = 2
GROUP BY ProductID, ProductName, CategoryID

----Another variation using just ORDER BY.
select ProductName from Products
where CategoryID in (1,2)
order by ProductID, ProductName;




--Two ways to find products that are either beverages and condiments
-- Using Join
select ProductName 
from Products P
INNER JOIN Categories C ON P.CategoryID=C.CategoryID
where CategoryName in('Beverages','Condiments');

-- Using SubQuery
select ProductName 
from Products P
where CategoryID in
      (Select CategoryID from Categories
		where CategoryName in ('Beverages','Condiments'));




--Counting the number of employees. Since its not specified, it will count the entire table.
SELECT COUNT(*) AS 'Number Of Employees'
FROM Employees




--COUNT() with a condition
SELECT COUNT(*) AS 'Number Of Employees'
FROM Employees
WHERE Country = 'USA'




--COMPLEX!!! Need to access three diff tables!
SELECT *
FROM Orders o, Employees e
WHERE o.EmployeeID = e.EmployeeID
AND e.Title = 'SALES REPRESENTATIVE'
AND o.ShipVia = (Select ShipperID FROM Shippers s WHERE o.ShipVia = s.ShipperID AND s.CompanyName = 'UNITED PACKAGE')

--Another variation. Its way more efficient!!! NOTICE HOW THREE tables are used WITHOUT subquery
select *
from Orders o, Employees e, Shippers s 
where e.EmployeeID= o.EmployeeID
and o.ShipVia = s.ShipperID
and e.Title='Sales Representative'
and s.CompanyName='United Package';


--Another example illustrating Self-Join (2)
SELECT staff.TitleOfCourtesy + staff.FirstName AS Staff, manager.TitleOfCourtesy + manager.FirstName AS DirectSuperior
FROM Employees staff, Employees manager
WHERE staff.ReportsTo = manager.EmployeeID

-- using outer join, all employee will be listed
select staff.LastName + ' ' + staff.FirstName as Employee,  
       manager.LastName + ' ' + manager.FirstName as Manager
from Employees staff left outer join Employees manager
on staff.ReportsTo = manager.EmployeeID;




--BETTER REMEMBER HOW ITS DONE!!!!!!
select top 5 p.productname,sum(od.discount * od.unitprice * od.quantity) 
from [order details] od, products p
where p.productid = od.productid 
and p.productid = od.productid
group by p.productid, p.productname
order by sum (od.unitprice * od.quantity * od.discount) desc


--DAMN IMPT. REFER to the joins diagrams. This here is an inverse right join. 
SELECT c.ContactName, c.City, s.City
FROM Customers c
LEFT JOIN Suppliers s
ON c.City = s.City
WHERE s.City IS NULL

--Another more efficient variation
select C.ContactName from Customers C
where C.City not in (select Distinct City from Suppliers);


--Cities where there are both suppliers and customers. A standarad join function.
select c.ContactName, c.City, s.ContactName, s.City
from Customers c, Suppliers s
WHERE c.City = s.City


--Using UNION
SELECT c.ContactName AS BizAssNames, c.Address, c.Phone
FROM Customers c
UNION SELECT s.ContactName AS BizAssNames, s.Address, s.Phone
FROM Suppliers s


--Another UNION eg
SELECT c.ContactName AS BizAssNames, c.Address, c.Phone
FROM Customers c
UNION SELECT s.ContactName AS BizAssNames, s.Address, s.Phone
FROM Suppliers s
UNION SELECT h.CompanyName AS BizAssNames, ' ', h.Phone
FROM Shippers h

--Notice also how you can use spacing for names provided you put single quotation marks '....'
select companyname as 'Business associate name',Address,phone from customers
union
select companyname as 'Business associate name',Address,phone from suppliers
union 
select companyname as 'Business associate name',null, phone from shippers;


--Alot of conditions.
SELECT staff.TitleOfCourtesy + staff.FirstName AS Staff,
manager.TitleOfCourtesy + manager.FirstName AS DirectSuperior, o.OrderID
FROM Employees staff, Employees manager, Orders o
WHERE staff.ReportsTo = manager.EmployeeID 
AND staff.EmployeeID = o.EmployeeID AND o.OrderID = 10248


--Note that the avg product price is $28.888 so anything above that is captured
SELECT ProductName, ProductID, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) From Products)


--SUPER IMPT, must GROUP BY OrderId not ProductID. Finding the total of each orders' sale of products
--Each order has multiple products and each has their own qty and price. COMPLEX  [GREAT]
SELECT d.OrderID, SUM(d.UnitPrice * d.Quantity) AS Amount
FROM [Order Details] d
GROUP BY d.OrderID
HAVING SUM(d.UnitPrice * d.Quantity) > 10000
ORDER BY Amount Desc


--Good practice
SELECT d.OrderID, SUM(d.UnitPrice * d.Quantity) AS Amount, o.CustomerID
FROM [Order Details] d, Orders o
WHERE d.OrderID = o.OrderID
GROUP BY d.OrderID, o.CustomerID
HAVING SUM(d.UnitPrice * d.Quantity) > 10000
ORDER BY Amount Desc




--Performing multiple joins on multiple tables.
--Here we join the OrderDetails with the orders and then joining  orders with customers tables
SELECT d.OrderID, SUM(d.UnitPrice * d.Quantity) AS Amount, o.CustomerID, c.CompanyName
FROM [Order Details] d, Orders o, Customers c
WHERE d.OrderID = o.OrderID
AND o.CustomerID = c.CustomerID
GROUP BY d.OrderID, o.CustomerID, c.CompanyName
HAVING SUM(d.UnitPrice * d.Quantity) > 10000
ORDER BY Amount Desc



--Here we are grouping by CustomerID instead of OrderID
SELECT o.CustomerID, SUM(d.UnitPrice * d.Quantity) AS Amount
FROM [Order Details] d, Orders o
WHERE d.OrderID = o.OrderID
GROUP BY o.CustomerID
ORDER BY Amount Desc




--Find the avg of amt of all the business done
--A very complex SELECT statement
SELECT SUM(d.UnitPrice * d.Quantity) / (SELECT COUNT(DISTINCT CustomerID) FROM Orders)
AS AvgAmtOfBiz FROM [Order Details] d
--This function below identifies the unique CustomerID and counts it.
--Remember how to use DISTINCT inside an aggregate function.
SELECT COUNT(DISTINCT CustomerID) FROM Orders

--Another variation
select sum(quantity*unitprice) /  count(distinct(orders.customerid) ) as Amount
from [order details], orders
where orders.orderid=[order details].orderid




--Evolution of. Combining the two basically.
SELECT o.CustomerID, c.ContactName, SUM(d.UnitPrice * d.Quantity) AS Amount
FROM [Order Details] d, Orders o, Customers c
WHERE d.OrderID = o.OrderID
AND o.CustomerID = c.CustomerID
GROUP BY o.CustomerID, c.ContactName
HAVING SUM(d.UnitPrice * d.Quantity) > 
(SELECT SUM(d.UnitPrice * d.Quantity) / (SELECT COUNT(DISTINCT CustomerID) FROM Orders) FROM [Order Details] d)
ORDER BY Amount Desc

--Another variation. Using a diff subquery
select customerid, sum(quantity*unitprice) as Amount
from [order details],orders
where orders.orderid=[order details].orderid
group by customerid
having sum(quantity*unitprice)  > 
 (select sum(quantity*unitprice) /  count(distinct(orders.customerid) ) as Amount
  from [order details], orders
  where orders.orderid=[order details].orderid
 ) 
order by Amount




--Evolution of the prev practice. But this time we only limit the amt gathered to be within the year 1997.
SELECT o.CustomerID, SUM(d.UnitPrice * d.Quantity) AS Amount
FROM [Order Details] d, Orders o
WHERE d.OrderID = o.OrderID AND o.OrderDate LIKE '%1997%'
GROUP BY o.CustomerID
ORDER BY Amount Desc

--Another variation
select customerid, sum(quantity*unitprice) as Amount
from [order details],orders
where orders.orderid=[order details].orderid
      and year(orderdate)=1997
group by customerid




--Check if it is able to retrieve only the 1997 order details. Ans is yes :)
SELECT OrderDate FROM Orders
WHERE OrderDate like '1997%'


SELECT * FROM Invoices


