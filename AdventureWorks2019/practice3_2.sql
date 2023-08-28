-- ***************************************
-- SQL PRACTICE 3.2
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : 
-- =============================================

-- -----------------------------------------
--TASK a)
-- -----------------------------------------
--From PRACTICE 2.2:
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

	ALTER TABLE dbo.Address
	ALTER COLUMN [StateProvinceID] [int] NOT NULL;

	ALTER TABLE dbo.Address
	ALTER COLUMN [PostalCode] [nvarchar](15) NOT NULL;

	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT PK_Address_StateProvinceID_PostalCode PRIMARY KEY (
		StateProvinceID
		,PostalCode
		);

	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT CHK_PostalCode CHECK (PostalCode NOT LIKE '%[^0-9]%');

	ALTER TABLE dbo.Address
	DROP CONSTRAINT CHK_PostalCode;

	ALTER TABLE [dbo].[Address]
	ADD CONSTRAINT DF_ModifiedDate
	DEFAULT GETUTCDATE() FOR ModifiedDate;

	INSERT INTO [dbo].Address
	SELECT AddressID
		,AddressLine1
		,AddressLine2
		,City
		,StateProvinceID
		,PostalCode
		,ModifiedDate
	FROM (
		SELECT Address.AddressID
			,Address.AddressLine1
			,Address.AddressLine2
			,Address.City
			,Address.StateProvinceID
			,Address.PostalCode
			,Address.ModifiedDate
			,MAX([Person].Address.AddressID) OVER (
				PARTITION BY Address.StateProvinceID
				,Address.PostalCode
				) AS MaxAddressID
		FROM [Person].Address
		INNER JOIN [Person].StateProvince ON Address.StateProvinceID = StateProvince.StateProvinceID
		WHERE CountryRegionCode = 'US'
			AND PostalCode NOT LIKE '%[^0-9]%'
		) SubAddressWithMaxID
	WHERE SubAddressWithMaxID.MaxAddressID = AddressID;

	ALTER TABLE dbo.Address
	ALTER COLUMN [City] [nvarchar](20);
	--

	ALTER TABLE dbo.Address
	ADD CountryRegionCode NVARCHAR(3);

	ALTER TABLE dbo.Address
	ADD TaxRate SMALLMONEY;

	ALTER TABLE dbo.Address
	ADD DiffMin AS (TaxRate - 5.00)

	--SELECT * FROM dbo.Address;

-- -----------------------------------------
--TASK b)
-- -----------------------------------------
	CREATE TABLE #Address(
		[AddressID] [int] PRIMARY KEY,
		[AddressLine1] [nvarchar](60) NULL,
		[AddressLine2] [nvarchar](60) NULL,
		[City] [nvarchar](20) NULL,
		[StateProvinceID] [int] NOT NULL,
		[PostalCode] [nvarchar](15) NOT NULL,
		[ModifiedDate] [datetime] NULL,
		[AddressType] [nvarchar](50) NULL,
		[CountryRegionCode] [nvarchar](3) NULL,
		[TaxRate] [smallmoney] NULL
		);

	--DROP TABLE #Address;
	/*
	SELECT * FROM dbo.Address;
	SELECT * FROM #Address;
	*/
-- -----------------------------------------
--TASK c)
-- -----------------------------------------
	WITH AddressView (
	AddressID
	,AddressLine1
	,AddressLine2
	,City
	,StateProvinceID
	,PostalCode
	,ModifiedDate
	,CountryRegionCode
	,TaxRate
	)
	AS (
	SELECT AddressID
		,AddressLine1
		,AddressLine2
		,City
		,Address.StateProvinceID
		,PostalCode
		,Address.ModifiedDate
		,StateProvince.CountryRegionCode
		,SalesTaxRate.TaxRate
	FROM dbo.Address
	INNER JOIN Person.StateProvince ON Address.StateProvinceID = StateProvince.StateProvinceID
	INNER JOIN Sales.SalesTaxRate ON StateProvince.StateProvinceID = SalesTaxRate.StateProvinceID
	WHERE SalesTaxRate.TaxRate > 5.0
	)
	INSERT INTO #Address (
	AddressID
	,AddressLine1
	,AddressLine2
	,City
	,StateProvinceID
	,PostalCode
	,ModifiedDate
	,CountryRegionCode
	,TaxRate
	)
	SELECT AddressID
	,AddressLine1
	,AddressLine2
	,City
	,StateProvinceID
	,PostalCode
	,ModifiedDate
	,CountryRegionCode
	,TaxRate
	FROM AddressView;

-- -----------------------------------------
--TASK d)
-- -----------------------------------------
	DELETE TOP(1) FROM dbo.Address
	WHERE Address.StateProvinceID = '36';
-- -----------------------------------------
--TASK e)
-- -----------------------------------------
	MERGE dbo.Address AS TargetTable
	USING #Address AS SourceTable
		ON (TargetTable.AddressID = SourceTable.AddressID)
	WHEN MATCHED
		THEN
			UPDATE
			SET TargetTable.CountryRegionCode = SourceTable.CountryRegionCode
				,TargetTable.TaxRate = SourceTable.TaxRate
	WHEN NOT MATCHED BY SOURCE
		THEN
			DELETE
	WHEN NOT MATCHED BY TARGET
		THEN
			INSERT (
				AddressID
				,AddressLine1
				,AddressLine2
				,City
				,StateProvinceID
				,PostalCode
				,ModifiedDate
				,CountryRegionCode
				,TaxRate
				)
			VALUES (
				SourceTable.AddressID
				,SourceTable.AddressLine1
				,SourceTable.AddressLine2
				,SourceTable.City
				,SourceTable.StateProvinceID
				,SourceTable.PostalCode
				,SourceTable.ModifiedDate
				,SourceTable.CountryRegionCode
				,SourceTable.TaxRate
				);

	--SELECT * FROM dbo.Address
	--SELECT * FROM #Address;
