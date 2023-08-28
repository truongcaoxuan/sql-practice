-- ***************************************
-- SQL PRACTICE 7
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : Variable XML, Temporary Table
-- =============================================

	DECLARE @xml xml;
	SELECT @xml =
	  (SELECT BusinessEntityID AS ID,
			  FirstName,
			  LastName
	   FROM Person.Person
	   FOR XML PATH('Person'),
			   ROOT('Persons'));
	SELECT @xml;

	CREATE TABLE #PersonsFromXML
	(
		[BusinessEntityID] [int] NOT NULL,
		[FirstName] [nvarchar](50) NOT NULL,
		[LastName] [nvarchar](50) NOT NULL
	)

	--DROP TABLE #PersonsFromXML;

	INSERT INTO #PersonsFromXML
		   SELECT x.value('ID[1]', 'int') AS BusinessEntityID,
			   x.value('FirstName[1]', 'varchar(50)') AS FirstName,
			   x.value('LastName[1]', 'varchar(50)') AS LastName
		   FROM @xml.nodes('//Person[ID=293]') XmlData(x)

	SELECT * FROM #PersonsFromXML;
