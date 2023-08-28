-- ***********************************
-- SQL ADVANCED
-- ***********************************
USE [QLDS]
GO

SELECT TOP 100 * FROM BANHANG

GO

-----------------------------------------------
-- TASK 1: CREATE PROCEDURE
-----------------------------------------------
-- TẠO PROCEDURE ĐỂ THỐNG KÊ DOANH SỐ BÁN RA HÀNG THÁNG CHO TỪNG LOẠI STORE 
-- TRONG ĐÓ BẢNG KẾT QUẢ TÊN [BANG1] BAO GỒM: 
----- [THÁNG], [STORE ID], [DOANH SỐ BÁN RA]
----- BIẾN THÁNG BÁO CÁO: @MONTH

--- Step1: Tạo bảng kết quả [BANG1]
	CREATE TABLE [BANG1] (
	[THÁNG] INT, 
	[STORE ID] NVARCHAR(50) , 
	[DOANH SỐ BÁN RA] FLOAT
	)

---Step 2 : TẠO FUNCTION GET_MONTH()
GO
	CREATE FUNCTION GET_MONTH (@NGAY DATETIME) RETURNS INT AS
	BEGIN
		DECLARE @KQ1 INT
			SET @KQ1 = SUBSTRING(CONVERT(NVARCHAR(MAX), @NGAY,112),1,6)
		IF @KQ1 <= SUBSTRING(CONVERT(NVARCHAR(MAX), GETDATE(),112),1,6)
			SET @KQ1 = SUBSTRING(CONVERT(NVARCHAR(MAX), @NGAY,112),1,6)
		RETURN @KQ1
		--- ELSE --- REMOVED
		--RETURN NULL
	END
GO
	-- Check Function
	SELECT TOP 10  DBO.GET_MONTH(Trans_Time) FROM BANHANG


---Step 3: Tạo Procedure
GO
	CREATE PROCEDURE PRO_DT_STORE_BYMONTH(@MONTH INT) AS
	BEGIN
	    DELETE FROM BANG1
		INSERT INTO BANG1 ([THÁNG],[STORE ID],[DOANH SỐ BÁN RA])
		SELECT TOP 10 DBO.GET_MONTH(Trans_Time) AS [THÁNG],Store_ID, 
			SUM(Số_tiền_Mua_hàng_nguyên_tệ) AS [DOANH SỐ BÁN RA]
		FROM BANHANG
		WHERE DBO.GET_MONTH(Trans_Time) = @MONTH
		AND Mua_vào_C_Bán_ra_D = 'D'
		GROUP BY DBO.GET_MONTH(Trans_Time),
				Store_ID
		ORDER BY [DOANH SỐ BÁN RA] DESC
	END
GO
	-- Check Doanh số tháng 4/2019
	EXECUTE PRO_DT_STORE_BYMONTH 201904
	SELECT * FROM BANG1

-----------------------------------------------
--TASK 2: SCALAR FUNCTION
-----------------------------------------------
-- TẠO SCALAR FUNCTION ĐỂ KIỂM TRA GIÁ TRỊ SỐ CÓ LỚN HƠN 500000 HAY KHÔNG
-- GIÁ TRỊ FUNCTION TRẢ RA: ‘LỚN HƠN 500000’, ‘DƯỚI 500000’

GO
	CREATE FUNCTION FUNC_CHECK_NUMBER500K (@Number INT) RETURNS NVARCHAR(100) AS
	BEGIN
		DECLARE @KETQUA NVARCHAR(100)
			IF @Number > 500000
				SET @KETQUA =N'LỚN HƠN 500000'
			ELSE
				SET @KETQUA = N'DƯỚI 500000'
		RETURN @KETQUA
	END

GO
	
	-- Check thử số 500001
	SELECT DBO.FUNC_CHECK_NUMBER500K (500001) AS [KET QUA]

-----------------------------------------------
--TASK 3: TABLE-VALUED FUNCTION
-----------------------------------------------
-- TẠO TABLE-VALUED FUNCTION ĐỂ HIỂN THỊ DOANH SỐ BÁN RA CỦA TỪNG STORE THEO TỪNG THÁNG. 
-- TRONG ĐÓ, CÓ 2 BIẾN: @STORE, @MONTH 
-- NẾU @STORE = 0 VÀ @MONTH = 0 THÌ HIỂN THỊ TẤT CẢ THÔNG TIN DOANH SỐ BÁN RA TỪNG STORE TỪNG THÁNG.
GO
	CREATE FUNCTION FUNC_TABLE_DT_STORE_BYMONTH(@StoreID NVARCHAR(50), @MONTH INT) 
	RETURNS @DT_STORE_BYMONTH TABLE 
				([StoreID] NVARCHAR(50),
				[MONTHID] INT,
				[TOTAL SALE] FLOAT )
	AS
	BEGIN
		IF @StoreID='0' AND @MONTH=0 
			INSERT INTO @DT_STORE_BYMONTH (StoreID, MONTHID, [TOTAL SALE])
			SELECT Store_ID,DBO.GET_MONTH(Trans_Time) AS [THÁNG],
				   SUM(Số_tiền_Mua_hàng_nguyên_tệ) AS [DOANH SỐ BÁN RA]
			FROM BANHANG
			WHERE Mua_vào_C_Bán_ra_D='D'
			GROUP BY Store_ID,DBO.GET_MONTH(Trans_Time)
			ORDER BY [Store_ID] ASC,
				     SUM(Số_tiền_Mua_hàng_nguyên_tệ) DESC
		ELSE
			INSERT INTO @DT_STORE_BYMONTH (StoreID, MONTHID, [TOTAL SALE])
			SELECT Store_ID,DBO.GET_MONTH(Trans_Time) AS [THÁNG],
				SUM(Số_tiền_Mua_hàng_nguyên_tệ) AS [DOANH SỐ BÁN RA]
			FROM BANHANG
			WHERE Mua_vào_C_Bán_ra_D='D'
			AND Store_ID=@StoreID
			AND DBO.GET_MONTH(Trans_Time)=@MONTH
			GROUP BY Store_ID,
				DBO.GET_MONTH(Trans_Time)
			ORDER BY [DOANH SỐ BÁN RA] DESC
	RETURN
	END
GO
	--Check Doanh số Store 1 tháng 10/2019
		SELECT * FROM dbo.FUNC_TABLE_DT_STORE_BYMONTH ('STORE 1',201910)
GO  
	--Check Doanh số Toàn bộ
	   SELECT * 
	   FROM FUNC_TABLE_DT_STORE_BYMONTH (0,0)
	   ORDER BY StoreID ASC,
			[TOTAL SALE] DESC
GO



-----------------------------------------------
-- TASK 4: Trigger time execute Procedure
-----------------------------------------------
-- TẠO TRIGGER CHO [BANG1] ĐỂ GHI NHẬN VÀO [BANG4] THỜI ĐIỂM PROCEDURE TRONG BÀI 1 BẮT ĐẦU, THỜI ĐIỂM KẾT THÚC, THỜI GIAN THỰC HIỆN.
-- TRONG ĐÓ BẢNG KẾT QUẢ TÊN [BANG4] BAO GỒM:  
----- [ID], [START_TIME], [END_TIME], [DURATION],[THÔNG BÁO]

--- Step1: Tạo BANG4
	CREATE TABLE BANG4 (
	[ID] INT IDENTITY, 
	[START_TIME] DATETIME, 
	[END_TIME] DATETIME, 
	[DURATION] NVARCHAR(50),
	[THÔNG BÁO] NVARCHAR(100) )

	--DROP TABLE BANG4
GO

--- Step 2: TẠO TRIGGER
	CREATE TRIGGER TRIG_CHECK_BANG1 ON BANG1
	FOR INSERT, DELETE
	AS
		IF NOT EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED) ---- NHẬN DIỆN MỆNH ĐỀ DELETE
			INSERT INTO BANG4 ([START_TIME])
			VALUES (GETDATE())
		
		IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED) ---- NHẬN DIỆN MỆNH ĐỀ INSERT
			UPDATE BANG4
				SET [END_TIME] = GETDATE()
				WHERE [END_TIME] IS NULL
			UPDATE BANG4
				SET [DURATION] = CONVERT(varchar(12),DATEADD(millisecond,DATEDIFF(millisecond, [START_TIME], [END_TIME]),0),114),
					[THÔNG BÁO] = N'EXECUTE PRO_DT_STORE_BYMONTH BY TRIG_CHECK_BANG1 ON BANG 1'
				WHERE [DURATION] IS NULL		

GO

-- CHECK THỜI GIAN THỰC HIỆN PROCEDURE TRONG BÀI 1
 	EXECUTE PRO_DT_STORE_BYMONTH 201903
	SELECT * FROM BANG4

