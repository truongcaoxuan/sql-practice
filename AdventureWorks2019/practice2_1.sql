-- ***************************************
-- SQL PRACTICE 2.1
-- ***************************************
USE [AdventureWorks2019]
GO

-- =============================================
--TASK 1: Query BusinessEntityID, JobTitle, DepartmentID, Department Name
-- =============================================
	SELECT Employee.BusinessEntityID ,
		   JobTitle ,
		   Department.DepartmentID ,
		   Name
	FROM [HumanResources].Employee
	INNER JOIN [HumanResources].EmployeeDepartmentHistory ON Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
	INNER JOIN [HumanResources].Department ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID;

-- =============================================
--TASK 2: Query EmpCount for DepartmentID, Department Name 
-- =============================================
	SELECT Department.DepartmentID ,
		   Department.Name ,
		   COUNT(EmployeeDepartmentHistory.DepartmentID) AS EmpCount
	FROM [HumanResources].Department
	INNER JOIN [HumanResources].EmployeeDepartmentHistory ON Department.DepartmentID = EmployeeDepartmentHistory.DepartmentID
	GROUP BY Department.DepartmentID ,
			 Department.Name;

-- =============================================
-- TASK3: Report the rate for JobTitle was set to Rate at RateChangeDate
-- =============================================
	SELECT JobTitle ,
		   EmployeePayHistory.Rate ,
		   EmployeePayHistory.RateChangeDate ,
		   CONCAT ('The rate for ' ,
				   JobTitle ,
				   ' was set to ' ,
				   Rate ,
				   ' at ' ,
				   CONVERT(NVARCHAR(11), RateChangeDate, 106)) AS Report
	FROM [HumanResources].Employee
	INNER JOIN [HumanResources].EmployeePayHistory ON Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID;
