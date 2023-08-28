-- ***************************************
-- SQL PRACTICE 6
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : 
-- =============================================

CREATE PROCEDURE dbo.SubCategoriesByClass (@Classes text)
AS
EXEC('
SELECT Name
	,' + @Classes + '
FROM (
	SELECT DISTINCT
		ListPrice
		,Class
		,Production.Product.ProductSubcategoryID AS ID
		,Production.ProductSubcategory.Name AS Name
	FROM Production.Product
	INNER JOIN Production.ProductSubcategory ON Production.ProductSubcategory.ProductSubcategoryID = Production.Product.ProductSubcategoryID
	--WHERE Class IS NOT NULL
	GROUP BY
		ListPrice
		,Class
		,Production.Product.ProductSubcategoryID
		,Production.ProductSubcategory.Name
	) subQ
PIVOT(AVG(ListPrice) FOR Class IN ('
 + @Classes + '
			)) AS test_pivot
ORDER BY ID;');
GO

--DROP PROCEDURE dbo.SubCategoriesByClass;

SELECT DISTINCT Class FROM Production.Product
WHERE Class IS NOT NULL;
GO

SELECT * FROM Production.ProductSubcategory;
SELECT * FROM Production.ProductCategory;

SELECT DISTINCT AVG(ListPrice) as AverageListPrice, Class, Production.Product.ProductSubcategoryID, Production.ProductSubcategory.Name  FROM Production.Product
INNER JOIN Production.ProductSubcategory
ON Production.ProductSubcategory.ProductSubcategoryID = Production.Product.ProductSubcategoryID
WHERE Class IS NOT NULL
GROUP BY Class, Production.Product.ProductSubcategoryID, Production.ProductSubcategory.Name

--PIVOT (AverageListPricefor for Class in ([H], [L], [M]) as test_pivot;

/*
SELECT * FROM
(SELECT DISTINCT ListPrice, Class, Production.Product.ProductSubcategoryID, Production.ProductSubcategory.Name  FROM Production.Product
INNER JOIN Production.ProductSubcategory
ON Production.ProductSubcategory.ProductSubcategoryID = Production.Product.ProductSubcategoryID
WHERE Class IS NOT NULL
GROUP BY ListPrice, Class, Production.Product.ProductSubcategoryID, Production.ProductSubcategory.Name) subQ
PIVOT (AVG(ListPrice) FOR Class in ([H], [L], [M])) AS test_pivot;
*/

SELECT Name
	,[H]
	,[L]
	,[M]
FROM (
	SELECT ListPrice
		,Class
		,Production.Product.ProductSubcategoryID AS ID
		,Production.ProductSubcategory.Name AS Name
	FROM Production.Product
	INNER JOIN Production.ProductSubcategory ON Production.ProductSubcategory.ProductSubcategoryID = Production.Product.ProductSubcategoryID
	--WHERE Class IS NOT NULL
	) subQ
PIVOT(AVG(ListPrice) FOR Class IN (
			[H]
			,[L]
			,[M]
			)) AS test_pivot
ORDER BY ID;

--EXECUTE dbo.SubCategoriesByClass '[L],[M]';

SELECT AVG(ListPrice)
		,Class
		,Production.Product.ProductSubcategoryID AS ID
		,Production.ProductSubcategory.Name AS Name
	FROM Production.Product
	INNER JOIN Production.ProductSubcategory ON Production.ProductSubcategory.ProductSubcategoryID = Production.Product.ProductSubcategoryID
	--WHERE Class IS NOT NULL
	GROUP BY Class
		,Production.Product.ProductSubcategoryID
		,Production.ProductSubcategory.Name
	ORDER BY ID;


/*
2924,6328	H 	1	Mountain Bikes
552,49	    L 	1	Mountain Bikes
924,74	    M 	1	Mountain Bikes
2879,8576	H 	2	Road Bikes
722,24	    L 	2	Road Bikes
1406,8828	M 	2	Road Bikes
*/
