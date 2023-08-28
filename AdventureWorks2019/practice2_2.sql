-- ***************************************
-- SQL PRACTICE 2.2
-- ***************************************
USE [AdventureWorks2019]
GO

-- =============================================
-- TASK : Extract data to new Address table 
-- =============================================

-- -----------------------------------------
--TASK a)
-- -----------------------------------------
	CREATE TABLE dbo.Address (
		[AddressID] [int]
		,[AddressLine1] [nvarchar](60)
		,[AddressLine2] [nvarchar](60)
		,[City] [nvarchar](30)
		,[StateProvinceID] [int]
		,[PostalCode] [nvarchar](15)
		,[ModifiedDate] [datetime]
		)
GO
	DROP TABLE [dbo].[Address];
-- -----------------------------------------
--TASK b)
-- -----------------------------------------
	ALTER TABLE dbo.Address
	ALTER COLUMN [StateProvinceID] [int] NOT NULL;
	ALTER TABLE dbo.Address
	ALTER COLUMN [PostalCode] [nvarchar](15) NOT NULL;

	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT PK_Address_StateProvinceID_PostalCode PRIMARY KEY (
		StateProvinceID
		,PostalCode
		);
-- -----------------------------------------
--TASK c)
-- -----------------------------------------
	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT CHK_PostalCode CHECK (PostalCode NOT LIKE '%[^0-9]%');
-- -----------------------------------------
--TASK d)
-- -----------------------------------------
	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT DF_ModifiedDate
	DEFAULT GETDATE() FOR ModifiedDate;
-- -----------------------------------------
--TASK e)
-- -----------------------------------------
	INSERT INTO [dbo].Address
	SELECT AddressID ,
		AddressLine1 ,
		AddressLine2 ,
		City ,
		StateProvinceID ,
		PostalCode ,
		ModifiedDate
	FROM
	(SELECT Address.AddressID ,
			Address.AddressLine1 ,
			Address.AddressLine2 ,
			Address.City ,
			Address.StateProvinceID ,
			Address.PostalCode ,
			Address.ModifiedDate ,
			MAX([Person].Address.AddressID) OVER (PARTITION BY Address.StateProvinceID ,
																Address.PostalCode) AS MaxAddressID
	FROM [Person].Address
	INNER JOIN [Person].StateProvince ON Address.StateProvinceID = StateProvince.StateProvinceID
	WHERE CountryRegionCode = 'US'
		AND PostalCode NOT LIKE '%[^0-9]%' ) SubAddressWithMaxID
	WHERE SubAddressWithMaxID.MaxAddressID = AddressID;

	SELECT * FROM [dbo].Address;
-- -----------------------------------------
--TASK f)
-- -----------------------------------------
	ALTER TABLE dbo.Address
	ALTER COLUMN [City] [nvarchar](20);
