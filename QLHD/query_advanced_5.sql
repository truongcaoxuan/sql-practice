-- ***********************************
-- SQL ADVANCED 5
-- ***********************************

use [QLHD]
GO

select * from [dbo].[CTHD] 
--- [SOHD, MASP]: Pri key, SL: so luong

select * from [dbo].[HOADON] 
--- [SOHD]: Pri key [MAKH, MANV]: Foreign Key, NGHD: Ngay hop dong, TRIGIA: gia tri HD

select * from [dbo].[KHACHHANG] 
--- [MAKH]: Pri key, HOTEN: ho va ten, DCHI: dia chi kh, SODT: so dien thoai
--- NGSINH: Ngay sinh cua kh, NGDK: Ngay kh dang ky, DOANHSO: Doanh so thu duoc tu kh

select * from [dbo].[NHANVIEN] 
--- [MANV]: Pri key, HOTEN: Ten nhan vien, SODT: So dien thoai cua nv
---, NGVL: Ngay bat dau lam viec

select * from [dbo].[SANPHAM] 
--- [MASP]: Pri key, TENSP: Ten san pham, DVT: Don vi tinh, NUOCSX: Noi san xuat
---, GIA: gia thanh sp
GO

-----------------------------------------------
-- TASK 1: EXEC(@SQL)
-----------------------------------------------
--1.1 TẠO PROCEDURE CÓ SỬ DỤNG SQL ĐỘNG ĐỂ 
-- THỐNG KÊ THÔNG TIN SỐ DÒNG, SỐ DÒNG NULL CHO TỪNG CỘT 
-- CỦA 5 BẢNG CTHD, HOADON, SANPHAM, KHACHHANG, NHANVIEN.

--BẢNG KẾT QUẢ BAO GỒM CÁC TRƯỜNG THÔNG TIN SAU:
-- [TÊN BẢNG], [TÊN CỘT], [SỐ DÒNG], [SỐ DÒNG NULL]

	SELECT * FROM SYS.tables
	-- TABLE OBJECT_ID
		--CTHD : 581577110
		--HOADON: 613577224
		--SANPHAM: 709577566
		--KHACHHANG: 645577338
		--NHANVIEN : 677577452
	
GO
	CREATE PROCEDURE PROC_TABLE_INF
	
	AS
	-- XÓA DỮ LIỆU BẢNG THÔNG TIN CŨ
	DROP TABLE IF EXISTS #TABLEINFO

	-- TẠO BẢNG LƯU THÔNG TIN BẢNG
	CREATE TABLE #TABLEINFO 
	([TÊN BẢNG] NVARCHAR(MAX),
	[TÊN CỘT] NVARCHAR(MAX), 
	[SỐ DÒNG] INT, 
	[SỐ DÒNG NULL] INT
	)
	
	-- VÒNG LẶP BẢNG THEO OBJECT_ID
	DECLARE @TABLE_OB_ID INT

	DECLARE CUR_OB_ID CURSOR
	FOR 
	    SELECT DISTINCT b.object_id
		FROM SYS.columns a
		LEFT JOIN SYS.tables  b
		ON a.object_id=b.object_id
		WHERE a.OBJECT_ID IN (581577110,613577224,709577566,645577338,677577452)
    
	OPEN CUR_OB_ID
	FETCH NEXT FROM CUR_OB_ID INTO  @TABLE_OB_ID
	WHILE @@FETCH_STATUS=0
	BEGIN

		-- VÒNG LẶP CỘT THEO TÊN
		DECLARE @COLUMN_NAME NVARCHAR(MAX)

		DECLARE CUR CURSOR 
		FOR
			SELECT name
			FROM SYS.columns WHERE OBJECT_ID = @TABLE_OB_ID
		
		DECLARE @SQL NVARCHAR(MAX)

		OPEN CUR
		FETCH NEXT FROM CUR INTO @COLUMN_NAME
		WHILE @@FETCH_STATUS = 0
		BEGIN
	        -- Xác định tên bảng dựa theo OBJECT_ID
			DECLARE @TableName NVARCHAR(MAX)
			SET @TableName=(SELECT name FROM SYS.tables			
					WHERE OBJECT_ID = @TABLE_OB_ID)
			
			-- Truy vấn SQL động lấy các ra các thông tin theo yêu cầu
			SET @SQL = '
		    DECLARE @TOTAL_ROW INT
			SELECT @TOTAL_ROW = COUNT('+@COLUMN_NAME+') 
			FROM '+@TableName+'
		
		    DECLARE @NO_NULLVALUE INT	
			SELECT @NO_NULLVALUE = COUNT('+@COLUMN_NAME+') 
			FROM  '+@TableName+'
			WHERE '+@COLUMN_NAME+' IS NULL'+

		
			' SELECT 
			b.name, 
			a.name, 
			@TOTAL_ROW, 
			@NO_NULLVALUE
			
			FROM SYS.columns a
			LEFT JOIN SYS.tables  b
			ON a.object_id=b.object_id
			WHERE a.OBJECT_ID ='+CONVERT(NVARCHAR(MAX),@TABLE_OB_ID)+' AND a.name =''' +@COLUMN_NAME+''''
			
			--PRINT @SQL
			
			INSERT INTO #TABLEINFO ([TÊN BẢNG], [TÊN CỘT],[SỐ DÒNG],[SỐ DÒNG NULL])
			EXEC(@SQL)
			

			FETCH NEXT FROM CUR INTO @COLUMN_NAME
		END -- END VÒNG LẶP CỘT
		CLOSE CUR
		DEALLOCATE CUR

	FETCH NEXT FROM CUR_OB_ID INTO  @TABLE_OB_ID
	END -- END VÒNG LẶP BẢNG
	
	SELECT * FROM #TABLEINFO

	CLOSE CUR_OB_ID
	DEALLOCATE CUR_OB_ID
GO

	EXEC PROC_TABLE_INF


	SELECT COUNT(SOHD) FROM CTHD

	SELECT * FROM SANPHAM
	SELECT COUNT(NUOCSX) FROM SANPHAM

-----------------------------------------------
--1.2 TẠO PROCEDURE CÓ SỬ DỤNG SQL ĐỘNG ĐỂ 
-- THỐNG KÊ THÔNG TIN SỐ DÒNG, SỐ DÒNG NULL CHO TỪNG CỘT 
-- CỦA 5 BẢNG CTHD, HOADON, SANPHAM, KHACHHANG, NHANVIEN.

--BẢNG KẾT QUẢ BAO GỒM CÁC TRƯỜNG THÔNG TIN SAU:
-- [TÊN BẢNG], [TÊN CỘT], [SỐ DÒNG], [SỐ DÒNG NULL]

	SELECT * FROM SYS.tables
	-- TABLE OBJECT_ID
		--CTHD : 581577110
		--HOADON: 613577224
		--SANPHAM: 709577566
		--KHACHHANG: 645577338
		--NHANVIEN : 677577452
	
GO
	CREATE PROCEDURE PROC_TABLE_INF2
	AS
	-- XÓA DỮ LIỆU BẢNG THÔNG TIN CŨ
	DROP TABLE IF EXISTS #TABLEINFO2

	-- TẠO BẢNG LƯU THÔNG TIN BẢNG
	CREATE TABLE #TABLEINFO2 
	([TÊN BẢNG] NVARCHAR(MAX),
	[TÊN CỘT] NVARCHAR(MAX), 
	[SỐ DÒNG] INT, 
	[SỐ DÒNG NULL] INT
	)  
	
	-- VÒNG LẶP BẢNG THEO OBJECT_ID
	DECLARE @TABLE_OB_ID INT

	DECLARE CUR_OB_ID CURSOR
	FOR 
	    SELECT DISTINCT b.object_id
		FROM SYS.columns a
		LEFT JOIN SYS.tables  b ON a.object_id=b.object_id
		WHERE a.OBJECT_ID IN (581577110,613577224,709577566,645577338,677577452)
    
	OPEN CUR_OB_ID
	FETCH NEXT FROM CUR_OB_ID INTO  @TABLE_OB_ID
	WHILE @@FETCH_STATUS=0
	BEGIN

		-- VÒNG LẶP CỘT THEO TÊN
		DECLARE @COLUMN_NAME NVARCHAR(MAX)

		DECLARE CUR CURSOR 
		FOR
			SELECT name
			FROM SYS.columns WHERE OBJECT_ID = @TABLE_OB_ID
		
		DECLARE @SpSQL NVARCHAR(MAX)

		OPEN CUR
		FETCH NEXT FROM CUR INTO @COLUMN_NAME
		WHILE @@FETCH_STATUS = 0
		BEGIN
	        -- Xác định tên bảng dựa theo OBJECT_ID
			DECLARE @TableName NVARCHAR(MAX)
			SET @TableName=(SELECT name FROM SYS.tables			
					WHERE OBJECT_ID = @TABLE_OB_ID)
			
			-- Truy vấn SP_EXECUTESQL lấy các ra các thông tin theo yêu cầu
			SET @SpSQL = N'
		    DECLARE @TOTAL_ROW INT
			SELECT @TOTAL_ROW = COUNT('+@COLUMN_NAME+') 
			FROM '+@TableName+'
		
		    DECLARE @NO_NULLVALUE INT	
			SELECT @NO_NULLVALUE = COUNT('+@COLUMN_NAME+') 
			FROM  '+@TableName+'
			WHERE '+@COLUMN_NAME+' IS NULL
		
			SELECT 
				b.name, 
				a.name, 
				@TOTAL_ROW, 
				@NO_NULLVALUE
			
			FROM SYS.columns a
			LEFT JOIN SYS.tables  b
			ON a.object_id=b.object_id
			WHERE a.OBJECT_ID = @SpTABLE_OB_ID AND a.name = '''+@COLUMN_NAME+''''
			
			
			--PRINT @SpSQL
			INSERT INTO #TABLEINFO2 ([TÊN BẢNG], [TÊN CỘT],[SỐ DÒNG],[SỐ DÒNG NULL])
			EXEC SP_EXECUTESQL @SpSQL,
							   N'@SpTABLE_OB_ID INT',
							   @TABLE_OB_ID
			
			
			FETCH NEXT FROM CUR INTO @COLUMN_NAME
		END -- END VÒNG LẶP CỘT
		CLOSE CUR
		DEALLOCATE CUR

	FETCH NEXT FROM CUR_OB_ID INTO  @TABLE_OB_ID
	END -- END VÒNG LẶP BẢNG
	
	SELECT * FROM #TABLEINFO2
	

	CLOSE CUR_OB_ID
	DEALLOCATE CUR_OB_ID
GO

	EXEC PROC_TABLE_INF2


	SELECT COUNT(SOHD) FROM CTHD

	SELECT * FROM SANPHAM
	SELECT COUNT(NUOCSX) FROM SANPHAM

-----------------------------------------------
-- TASK 2. PIVOT TABLE
-----------------------------------------------

 ---- 2.1 TÍNH TỔNG SL MASP 'BB01', 'BB02'
	--// truy vấn thông thường
	SELECT SOHD,
		   SUM(SL) SLSP
	FROM CTHD
	WHERE SOHD IN (1001,
				   1002)
	GROUP BY SOHD
	
	--// truy vấn sử dụng PIVOT
	SELECT 'SLSP' AS SLSP,
		   [1001],
		   [1002],
		   [1001] + [1002] AS TONG_SLSP
	FROM
	  (SELECT SOHD,
			  SL
	   FROM CTHD) A
	PIVOT (SUM(SL)
		   FOR SOHD IN ([1001], [1002])) A

 ----2.2 TÍNH TỔNG SL MASP 'BB01', 'BB02' CHO TỪNG SOHD
--WITH DAT AS (
	SELECT SOHD
	, ISNULL([BB01],0) AS BB01
	, ISNULL([BB02],0) AS BB02
	--INTO #PIVOT_TEST
	FROM (SELECT SOHD, MASP, SL FROM CTHD) A
	PIVOT
	(
		SUM(SL)
		FOR MASP IN ([BB01], [BB02])
	) A
--)

---- 2.3 TÍNH SỐ LƯỢNG MASP SẢN XUẤT TỪ SINGAPORE, THAILAN, TRUNG QUOC, USA, VIET NAM THEO MỖI CẶP TENSP, DVT
	--// truy vấn thông thường
	SELECT TENSP,
		   DVT,
		   NUOCSX,
		   COUNT(DISTINCT MASP) SLSP
	FROM SANPHAM
	GROUP BY TENSP,
			 DVT,
			 NUOCSX
	ORDER BY TENSP,
			 DVT,
			 NUOCSX
	--// truy vấn sử dụng PIVOT
	SELECT TENSP,
		   DVT,
		   [SINGAPORE],
		   [THAI LAN],
		   [TRUNG QUOC],
		   [USA],
		   [VIET NAM]
	FROM
	  (SELECT DISTINCT MASP,
					   TENSP,
					   DVT,
					   NUOCSX
	   FROM SANPHAM) A PIVOT (COUNT(MASP)
							  FOR NUOCSX IN ([SINGAPORE], [THAI LAN], [TRUNG QUOC], [USA], [VIET NAM])) A

-----------------------------------------------
-- TASK 3. UNPIVOT
-----------------------------------------------

---- UNPIVOT BẢNG TẠO RA TỪ MỆNH ĐỀ PIVOT TRONG VÍ DỤ 1 MỤC 2.1
	--// tạo bảng tạm có PIVOT
	WITH DAT AS
	  (SELECT 'SLSP' AS SLSP,
			  [1001],
			  [1002],
			  [1001] + [1002] AS TONG_SLSP
	   FROM
		 (SELECT SOHD,
				 SL
		  FROM CTHD) A PIVOT (SUM(SL)
							  FOR SOHD IN ([1001], [1002])) A)
	--// thực hiện truy vấn bảng tạm và UNPIVOT
	SELECT SOHD,
		   SLSP
	FROM
	  (SELECT [1001],
			  [1002]
	   FROM DAT) A UNPIVOT (SLSP
							FOR SOHD IN ([1001], [1002])) A