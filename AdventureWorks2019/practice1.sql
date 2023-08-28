-- ***************************************
-- SQL PRACTICE 1
-- ***************************************
USE [AdventureWorks2019]
GO

-- =============================================
--TASK 1: Query Department have Department Name that start by P
-- =============================================
	SELECT DepartmentID
		,Name
	FROM [HumanResources].Department
	WHERE Name LIKE 'P%';

-- =============================================
--TASK 2: Query Business Entity that have VacationHours BETWEEN 10 AND 13
-- =============================================
	SELECT BusinessEntityID
		,JobTitle
		,Gender
		,VacationHours
		,SickLeaveHours
	FROM [HumanResources].Employee
	WHERE VacationHours BETWEEN 10
			AND 13;

-- =============================================
--TASK 3: Query Business Entity that have Month of HireDate equal 12
-- =============================================
	SELECT MONTH(HireDate) AS HireDateMonth
	FROM [HumanResources].Employee
	WHERE MONTH(HireDate) = 12
	--HAVING HireDateMonth = 7
	ORDER BY BusinessEntityID ASC OFFSET 3 ROWS
	FETCH NEXT 5 ROWS ONLY;

	ALTER TABLE [HumanResources].Employee
	ADD HireDateMonth as MONTH(HireDate);

	ALTER TABLE [HumanResources].Employee
	DROP COLUMN HireDateMonth;

	CREATE INDEX ix_Month ON [HumanResources].Employee(HireDateMonth);

	DROP INDEX [HumanResources].Employee.ix_Month;

	SELECT BusinessEntityID
		,JobTitle
		,Gender
		,BirthDate
		,HireDate
	FROM [HumanResources].Employee
	WHERE MONTH(HireDate) = 12
	ORDER BY BusinessEntityID ASC OFFSET 3 ROWS
	FETCH NEXT 5 ROWS ONLY;
