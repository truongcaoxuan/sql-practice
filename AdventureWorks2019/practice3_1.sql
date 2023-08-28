-- ***************************************
-- SQL PRACTICE 3.1
-- ***************************************

USE [AdventureWorks2019]
GO

-- =============================================
-- TASK : 
-- =============================================

-- -----------------------------------------
--TASK a:
-- -----------------------------------------
	ALTER TABLE dbo.Address
	ADD AddressType NVARCHAR(50);

	--SELECT * FROM dbo.Address;
-- -----------------------------------------
--TASK b:
-- -----------------------------------------
	DECLARE @table_variable_Address TABLE(
		[AddressID] [int],
		[AddressLine1] [nvarchar](60) NULL,
		[AddressLine2] [nvarchar](60) NULL,
		[City] [nvarchar](20) NULL,
		[StateProvinceID] [int] NOT NULL,
		[PostalCode] [nvarchar](15) NOT NULL,
		[ModifiedDate] [datetime] NULL,
		[AddressType] [nvarchar](50) NULL
		);

	INSERT INTO @table_variable_Address (
		AddressID
		,AddressLine1
		,AddressLine2
		,City
		,StateProvinceID
		,PostalCode
		,ModifiedDate
		,AddressType
		)
	SELECT AddressID
		,AddressLine1
		,AddressLine2
		,City
		,StateProvinceID
		,PostalCode
		,Address.ModifiedDate
		,Name
	FROM dbo.Address
	INNER JOIN Person.AddressType ON StateProvinceID % 6 + 1 = AddressTypeID;

	--SELECT * FROM @table_variable_Address;
-- -----------------------------------------
--TASK c:
-- -----------------------------------------
	UPDATE dbo.Address
	SET Address.AddressType = tvAddress.AddressType
	,Address.Addressline2 = ISNULL(tvAddress.AddressLine2, tvAddress.AddressLine1)
	FROM @table_variable_Address AS tvAddress
	WHERE Address.PostalCode = tvAddress.PostalCode;
-- -----------------------------------------
--TASK d:
-- -----------------------------------------
	DELETE
	FROM dbo.Address
	WHERE AddressID NOT IN (
			SELECT DISTINCT MAX(AddressID) OVER (PARTITION BY AddressType)
			FROM dbo.Address
			);

	SELECT * FROM Person.AddressType;

	--SELECT * FROM dbo.Address;
-- -----------------------------------------
--Task e:
-- -----------------------------------------
	ALTER TABLE dbo.Address
	DROP COLUMN AddressType;

	DECLARE @cnt INT = 1;
	DECLARE @cnt_total INT = (
			SELECT COUNT(CONSTRAINT_NAME)
			FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
			WHERE TABLE_SCHEMA = 'dbo'
				AND TABLE_NAME = 'Address'
			) + 1;

	--PRINT(@cnt_total);

	DECLARE @constraint NVARCHAR(40) = '';

	WHILE @cnt < @cnt_total
	BEGIN
		--PRINT(@cnt);
		SET @constraint = (
				SELECT CONSTRAINT_NAME
				FROM (
					SELECT row_number() OVER (
							ORDER BY CONSTRAINT_NAME
							) ID
						,CONSTRAINT_NAME
					FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
					WHERE TABLE_SCHEMA = 'dbo'
						AND TABLE_NAME = 'Address'
					) SD
				WHERE SD.ID = 1
				);

		EXEC('ALTER TABLE dbo.Address DROP CONSTRAINT ' + @constraint);

		--PRINT(@constraint);
		SET @cnt = @cnt + 1;
	END;

	DECLARE @cnt_default INT = 1;
	DECLARE @cnt_total_default INT = (
			SELECT COUNT(con.[name])
			FROM sys.default_constraints con
			LEFT OUTER JOIN sys.objects t ON con.parent_object_id = t.object_id
			LEFT OUTER JOIN sys.all_columns col ON con.parent_column_id = col.column_id
				AND con.parent_object_id = col.object_id
			WHERE schema_name(t.schema_id) + '.' + t.[name] = 'dbo.Address'
			) + 1;

	--PRINT(@cnt_total_default);

	DECLARE @constraint_default NVARCHAR(40) = '';

	WHILE @cnt_default < @cnt_total_default
	BEGIN
		SET @constraint_default = (
				SELECT CONSTRAINT_NAME
				FROM (
					SELECT row_number() OVER (
							ORDER BY con.[name]
							) ID
						,con.[name] AS CONSTRAINT_NAME
					FROM sys.default_constraints con
					LEFT OUTER JOIN sys.objects t ON con.parent_object_id = t.object_id
					LEFT OUTER JOIN sys.all_columns col ON con.parent_column_id = col.column_id
						AND con.parent_object_id = col.object_id
					WHERE schema_name(t.schema_id) + '.' + t.[name] = 'dbo.Address'
					) SD
				WHERE SD.ID = 1
				);

		EXEC ('ALTER TABLE dbo.Address DROP CONSTRAINT ' + @constraint_default);

		--PRINT(@constraint_default);
		SET @cnt_default = @cnt_default + 1;
	END;

-- -----------------------------------------
--TASK f:
-- -----------------------------------------
	DROP TABLE dbo.Address;
