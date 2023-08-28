-- ***************************************
-- SQL PRACTICE 5
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : 
-- =============================================

-- -----------------------------------------
--TASK a:
-- -----------------------------------------
CREATE FUNCTION dbo.udfDetailedSum
(@purchaseorderID int)
RETURNS MONEY
BEGIN
	RETURN (SELECT SUM(LineTotal) FROM Purchasing.PurchaseOrderDetail
			WHERE PurchaseOrderID = @purchaseorderID)
END;
GO

CREATE FUNCTION dbo.udfDetailedSumInline
(@purchaseorderID int)
RETURNS TABLE
AS
RETURN
	(SELECT SUM(LineTotal) as TotalSum FROM Purchasing.PurchaseOrderDetail
			WHERE PurchaseOrderID = @purchaseorderID);
GO

SELECT * FROM dbo.udfDetailedSumInline(2)
WHERE TotalSum > 200;

SET STATISTICS TIME ON

SELECT *
FROM Purchasing.PurchaseOrderDetail
CROSS APPLY dbo.udfDetailedSumInline(PurchaseOrderID) as udf
WHERE TotalSum > 200;
GO

SELECT *
FROM Purchasing.PurchaseOrderDetail
WHERE dbo.udfDetailedSum(PurchaseOrderID) > 200;
GO

SET STATISTICS TIME OFF

SELECT * FROM Purchasing.PurchaseOrderDetail
WHERE PurchaseOrderID = 2;

--DROP FUNCTION dbo.udfDetailedSum;

--SELECT * FROM Purchasing.PurchaseOrderHeader;
--SELECT * FROM Purchasing.PurchaseOrderDetail;
DECLARE @id int;
SET @id = 2;
--PRINT dbo.udfDetailedSum(@id);
PRINT ('Detailed sum for your order is ' + LTRIM(CAST(dbo.udfDetailedSum(@id) AS CHAR)) + '.');
GO
-- -----------------------------------------
--TASK b:
-- -----------------------------------------
CREATE FUNCTION dbo.udfGetProfitableOrders
(@customerID int, @rowsAmount int)
RETURNS TABLE
AS
RETURN
	(SELECT TOP(@rowsAmount) CustomerID, TotalDue
	FROM Sales.SalesOrderHeader
	WHERE CustomerID = @customerID
	ORDER BY TotalDue DESC);
GO

CREATE FUNCTION dbo.udfGetProfitableOrders
(@customerID int, @rowsAmount int)
RETURNS TABLE
AS
RETURN
	(SELECT TOP(@rowsAmount) CustomerID, TotalDue
	FROM Sales.SalesOrderHeader
	WHERE CustomerID = @customerID
	ORDER BY TotalDue DESC);
GO

SELECT * FROM dbo.udfGetProfitableOrders(11000, 5);

--DROP FUNCTION dbo.udfGetProfitableOrders;

SELECT * FROM Sales.SalesOrderHeader
ORDER BY CustomerID;

SELECT *
FROM Sales.SalesOrderHeader
CROSS APPLY udfGetProfitableOrders(CustomerID, 4) as udf;
GO

SELECT *
FROM Sales.SalesOrderHeader
OUTER APPLY udfGetProfitableOrders(CustomerID, 4) as udf;
GO

/*
SELECT *
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29825
ORDER BY TotalDue DESC;
*/
-- -----------------------------------------
--TASK c:
-- -----------------------------------------
--DROP FUNCTION dbo.udfGetProfitableOrders

CREATE FUNCTION dbo.udfGetProfitableOrdersMultiStatement (
	@customerID INT
	,@rowsAmount INT
	)
RETURNS @ProfitableOrders TABLE (
	CustomerID INT
	,TotalDue MONEY
	)
AS
BEGIN
	INSERT INTO @ProfitableOrders
	SELECT TOP (@rowsAmount) CustomerID
		,TotalDue
	FROM Sales.SalesOrderHeader
	WHERE CustomerID = @customerID
	ORDER BY TotalDue DESC
	RETURN
END;
GO

SELECT * FROM dbo.udfGetProfitableOrdersMultiStatement(11000, 2);

--DROP FUNCTION dbo.udfGetProfitableOrdersMultiStatement;
