-- ***************************************
-- SQL PRACTICE 4.2
-- ***************************************

USE [AdventureWorks2019]
GO
-- =============================================
-- TASK : 
-- =============================================

-- -----------------------------------------
-- TASK a:
-- -----------------------------------------
	CREATE VIEW ViewWorkOrderScrapReasonProduct
		WITH ENCRYPTION
			,SCHEMABINDING
	AS
	SELECT wo.WorkOrderID
		,wo.ProductID
		,wo.OrderQty
		,wo.StockedQty
		,wo.ScrappedQty
		,wo.StartDate
		,wo.EndDate
		,wo.DueDate
		,wo.ScrapReasonID
		,wo.ModifiedDate
		,sr.Name AS ScrapReasonName
		,sr.ModifiedDate AS ScrapReasonModifiedDate
		,p.Name AS ProductName
	FROM Production.WorkOrder AS wo
	INNER JOIN Production.ScrapReason AS sr ON wo.ScrapReasonID = sr.ScrapReasonID
	INNER JOIN Production.Product AS p ON wo.ProductID = p.ProductID;
	GO

	--DROP VIEW ViewWorkOrderScrapReasonProduct;

	--SELECT * FROM ViewWorkOrderScrapReasonProduct;

	CREATE UNIQUE CLUSTERED INDEX
		ucidx_WorkOrderID
	ON ViewWorkOrderScrapReasonProduct(WorkOrderID);

-- -----------------------------------------
--TASK b:
-- -----------------------------------------
	CREATE TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_INSERT ON ViewWorkOrderScrapReasonProduct
	INSTEAD OF INSERT
	AS
	BEGIN
		SET NOCOUNT ON;

		INSERT INTO Production.ScrapReason (
			Name
			,ModifiedDate
			)
		SELECT DISTINCT i.ScrapReasonName
			,GETDATE()
		FROM inserted i
		WHERE i.ScrapReasonName NOT IN (
				SELECT Name
				FROM Production.ScrapReason
				);

		INSERT INTO Production.WorkOrder (
			ProductID
			,OrderQty
			,ScrappedQty
			,StartDate
			,EndDate
			,DueDate
			,ScrapReasonID
			,ModifiedDate
			)
		SELECT (
				SELECT ProductID
				FROM Production.Product
				WHERE Name = i.ProductName
				)
			,i.OrderQty
			,i.ScrappedQty
			,i.StartDate
			,i.EndDate
			,i.DueDate
			,(
				SELECT ScrapReasonID
				FROM Production.ScrapReason
				WHERE Name = i.ScrapReasonName
				)
			,GETDATE()
		FROM inserted i
	END;
	GO

	--DROP TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_INSERT;

	CREATE TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_DELETE ON ViewWorkOrderScrapReasonProduct
	INSTEAD OF DELETE
	AS
	BEGIN
		SET NOCOUNT ON;

		DELETE
		FROM Production.WorkOrder
		WHERE WorkOrderID IN (
				SELECT WorkOrderID
				FROM deleted
				);

		--SELECT ScrapReasonID FROM deleted;
		--SELECT ScrapReasonID FROM Production.WorkOrder;
		DELETE
		FROM Production.ScrapReason
		WHERE ScrapReasonID IN (
				SELECT ScrapReasonID
				FROM deleted
				)
			AND ScrapReasonID NOT IN (
				SELECT ScrapReasonID
				FROM Production.WorkOrder
				WHERE ScrapReasonID IS NOT NULL
				);

	END;
	GO

	--DROP TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_DELETE;

	CREATE TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_UPDATE ON ViewWorkOrderScrapReasonProduct
	INSTEAD OF UPDATE
	AS
	BEGIN
		SET NOCOUNT ON;

		UPDATE Production.ScrapReason
		SET Name = i.ScrapReasonName
			,ModifiedDate = GETDATE()
		FROM inserted i
		WHERE ScrapReason.ScrapReasonID = i.ScrapReasonID;

		UPDATE Production.WorkOrder
		SET ScrappedQty = i.ScrappedQty
			,StartDate = i.StartDate
			,EndDate = i.EndDate
			,DueDate = i.DueDate
			,ScrapReasonID = (
				SELECT ScrapReasonID
				FROM Production.ScrapReason
				WHERE Name = i.ScrapReasonName
				)
			,ModifiedDate = GETDATE()
		FROM inserted i
		WHERE WorkOrder.WorkOrderID = i.WorkOrderID;
	END

	--DROP TRIGGER dbo.TRG_ViewWorkOrderScrapReasonProduct_UPDATE

	SELECT * FROM Production.Product;

-- -----------------------------------------
-- Task c:
-- -----------------------------------------
	INSERT INTO ViewWorkOrderScrapReasonProduct (
		OrderQty
		,ScrappedQty
		,StartDate
		,EndDate
		,DueDate
		,ScrapReasonName
		,ProductName
		)
	VALUES (
		330
		,0
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,'scrapreasonname111'
		,'Adjustable Race'
		),
		(
		330
		,0
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,'scrapreasonname555'
		,'Adjustable Race'
		)
		,
		(
		330
		,0
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,'scrapreasonname000000'
		,'Adjustable Race'
		)
		,
		(
		330
		,0
		,GETDATE()
		,GETDATE()
		,GETDATE()
		,'scrapreasonname000000'
		,'Bearing Ball'
		);

	SELECT *
	FROM Production.WorkOrder
	ORDER BY WorkOrderID DESC;

	SELECT *
	FROM Production.ScrapReason
	ORDER BY ScrapReasonID DESC;

	UPDATE ViewWorkOrderScrapReasonProduct
	SET ScrappedQty = 1000
		,StartDate = GETDATE() - 1
		,EndDate = GETDATE() + 1
		,DueDate = GETDATE()
		,ScrapReasonName = 'NEWNAMEForScrapReason000000'
	WHERE WorkOrderID IN (72652, 72651)
		AND ScrapReasonID = 36;

	DELETE FROM ViewWorkOrderScrapReasonProduct
	WHERE WorkOrderID IN (72652, 72651);
