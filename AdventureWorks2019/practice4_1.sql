-- ***************************************
-- SQL PRACTICE 4.1
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : 
-- =============================================

-- -----------------------------------------
--TASK a:
-- -----------------------------------------
	CREATE TABLE Production.WorkOrderHst (
		[ID] [int] IDENTITY(1, 1) PRIMARY KEY
		,[Action] [nvarchar](10) NOT NULL
		,[ModifiedDate] [datetime] NOT NULL
		,[SourceID] [int] NOT NULL
		,[UserName] [sysname] NOT NULL
		);

	--DROP TABLE Production.WorkOrderHst;

-- -----------------------------------------
--TASK b:
-- -----------------------------------------
	CREATE TRIGGER Production.TRG_WorkOrder_AFTER ON Production.WorkOrder
	AFTER INSERT
		,UPDATE
		,DELETE
	AS
	BEGIN
		SET NOCOUNT ON;

		DECLARE @action AS NVARCHAR(10);
		DECLARE @sourceID AS INT;

		SET @action = (
				CASE
					WHEN EXISTS (
							SELECT *
							FROM inserted
							)
						AND EXISTS (
							SELECT *
							FROM deleted
							)
						THEN 'UPDATE'
					WHEN EXISTS (
							SELECT *
							FROM inserted
							)
						THEN 'INSERT'
					WHEN EXISTS (
							SELECT *
							FROM deleted
							)
						THEN 'DELETE'
					END
				);

		IF @action = 'UPDATE'
			OR @action = 'INSERT'
			INSERT INTO Production.WorkOrderHst (
				Action
				,ModifiedDate
				,SourceID
				,UserName
				)
			SELECT @action
			,GETDATE()
				,inserted.WorkOrderID
				,SUSER_NAME()
			FROM inserted;
			ELSE
			INSERT INTO Production.WorkOrderHst (
				Action
				,ModifiedDate
				,SourceID
				,UserName
				)
			SELECT @action
			,GETDATE()
				,deleted.WorkOrderID
				,SUSER_NAME()
			FROM deleted;
	END;
	GO

	DROP TRIGGER Production.TRG_WorkOrder_AFTER;

	/*
	INSERT INTO [Production].[WorkOrder]
			   ([ProductID]
			   ,[OrderQty]
			   ,[ScrappedQty]
			   ,[StartDate]
			   ,[EndDate]
			   ,[DueDate]
			   ,[ScrapReasonID]
			   ,[ModifiedDate])
		 VALUES
			   ('722'
			   ,'330'
			   ,'0'
			   ,GETDATE()
			   ,GETDATE()
			   ,GETDATE()
			   ,NULL
			   ,GETDATE());

	DELETE FROM Production.WorkOrder
	WHERE WorkOrderID = 72609;

	UPDATE Production.WorkOrder
	SET ModifiedDate = GETDATE()
	WHERE WorkOrderID = 72608;

	SELECT * FROM Production.WorkOrderHst;
	SELECT * FROM Production.WorkOrder;
	*/

-- -----------------------------------------
--TASK c:
-- -----------------------------------------
	CREATE VIEW [ViewWorkOrder]
	AS
	SELECT *
	FROM Production.WorkOrder;
	GO

	--SELECT * FROM [ViewWorkOrder];
	--DROP VIEW [ViewWorkOrder];

-- -----------------------------------------
--TASK d:
-- -----------------------------------------
	INSERT INTO ViewWorkOrder
			   ([ProductID]
			   ,[OrderQty]
			   ,[ScrappedQty]
			   ,[StartDate]
			   ,[EndDate]
			   ,[DueDate]
			   ,[ScrapReasonID]
			   ,[ModifiedDate])
		 VALUES
			   ('722'
			   ,'330'
			   ,'0'
			   ,GETDATE()
			   ,GETDATE()
			   ,GETDATE()
			   ,NULL
			   ,GETDATE()),
			   ('722'
			   ,'330'
			   ,'0'
			   ,GETDATE()
			   ,GETDATE()
			   ,GETDATE()
			   ,NULL
			   ,GETDATE());

	UPDATE ViewWorkOrder
	SET ModifiedDate = GETDATE()
	WHERE WorkOrderID IN (72645, 72646);

	DELETE FROM ViewWorkOrder
	WHERE WorkOrderID IN (72645, 72646);

	SELECT * FROM Production.WorkOrderHst;
