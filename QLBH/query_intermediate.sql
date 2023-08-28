-- ***********************************
-- SQL INTERMEDIATE
-- ***********************************

--SỬ DỤNG DATABASE [QLBH]
--(HAI BẢNG SẼ SỬ DỤNG LÀ BẢNG BANHANG VÀ TYGIA)
	USE [QLBH]
	GO

--=====================================================
--TASK 1: ALTER TABLE, UPDATE
--=====================================================
--TỪ BẢNG BÁN HÀNG THỰC HIỆN ADD THÊM MỘT CỘT TỶ GIÁ (TY_GIA)

	ALTER TABLE [QLBH]..BANHANG
	ADD TY_GIA FLOAT

--SAU ĐÓ UPDATE TỶ GIÁ TỪ BẢNG TỶ GIÁ VÀO CỘT TỶ GIÁ (TY_GIA) VỪA TẠO RA, 
--BIẾT RẰNG TỶ GIÁ MỖI ĐỒNG TIỀN MỖI NGÀY LÀ KHÁC NHAU VÀ LOẠI TIỀN VND CÓ TỶ GIÁ LÀ 1
--DÙNG CÂU LỆNH UPDATE VỚI ĐIỀU KIỆN 
-- NGÀY TRANS_TIME TRONG BẢNG BÁN HÀNG = NGÀY TRONG BẢNG TỶ GIÁ 
-- VÀ LOẠI TIỀN TRONG BẢNG BÁN HÀNG = LOẠI TIỀN TRONG BẢNG TỶ GIÁ
    
	SELECT * FROM [QLBH]..TYGIA
	WHERE [Loại tiền]='USD'

	UPDATE [QLBH]..BANHANG
	SET [QLBH]..BANHANG.TY_GIA = [QLBH]..TYGIA.[Tỷ giá]
	FROM [QLBH]..TYGIA
	WHERE [QLBH]..BANHANG.[Loại tiền]=[QLBH]..TYGIA.[Loại tiền]
	  AND CONVERT(DATE,[QLBH]..BANHANG.Trans_Time) = CONVERT(DATE,[QLBH]..TYGIA.[Ngày]) 
	--(1 rows affected)

	UPDATE [QLBH]..BANHANG
	SET TY_GIA = 1 
	WHERE [QLBH]..BANHANG.[Loại tiền]='VND'
	-- (186 rows affected)

	-- Check tỷ giá USD
	SELECT *
	FROM [QLBH]..BANHANG
	WHERE [Loại tiền]='USD'
	-- 14 rows
		
	-- Check tỷ giá VND	
	SELECT *
	FROM [QLBH]..BANHANG
	WHERE [Loại tiền]='VND'
	AND [Mã khách hàng]='MKH320511'
	-- 2 rows

--=====================================================
-- TASK 2: ALTER TABLE, UPDATE, ROW_NUMBER()
--=====================================================
--TỪ BẢNG BÁN HÀNG ĐÃ BỔ SUNG THÊM CỘT TỶ GIÁ. 
--THỰC HIỆN ADD CỘT SỐ TIỀN BÁN HÀNG QUY ĐỔI (SO_TIEN_QUY_DOI)

	ALTER TABLE [QLBH]..BANHANG
	ADD SO_TIEN_QUY_DOI FLOAT

--UPDATE SỐ TIỀN BÁN HÀNG QUY ĐỔI 
----BIẾT RẰNG SO_TIEN_QUY_DOI = SỐ TIỀN MUA HÀNG NGUYÊN TỆ * TỶ GIÁ (TY_GIA)

	UPDATE [QLBH]..BANHANG
	SET SO_TIEN_QUY_DOI = TY_GIA * [Số tiền Mua hàng nguyên tệ]
	--(200 rows affected)

    -- Check SO_TIEN_QUY_DOI với tỷ giá USD
	SELECT *
	FROM [QLBH]..BANHANG
	WHERE [Loại tiền]='USD'

--THỐNG KÊ TỔNG SỐ TIỀN BÁN HÀNG QUY ĐỔI CỦA TỪNG NHÂN VIÊN THEO THÁNG TRONG NĂM 2019 (SỬ DỤNG GROUP BY)
	SELECT MONTH(Trans_Time) AS THANG,
		   Sale_man_ID,
		   Sale_man,
		   SUM(SO_TIEN_QUY_DOI) AS TONG_TIEN_QUY_DOI
	FROM [QLBH]..BANHANG
	WHERE YEAR(Trans_Time) = 2019
	GROUP BY Sale_man_ID,
			 Sale_man,
			 MONTH(Trans_Time)
	ORDER BY TONG_TIEN_QUY_DOI DESC


----LẤY RA TOP 3 NHÂN VIÊN CÓ TỔNG SỐ TIỀN BÁN HÀNG QUY ĐỔI LỚN NHẤT TRONG NĂM 2019
	SELECT TOP 3 Sale_man_ID,
			   Sale_man,
			   SUM(SO_TIEN_QUY_DOI) AS TONG_TIEN_QUY_DOI
	FROM [QLBH]..BANHANG
	WHERE YEAR(Trans_Time) = 2019
	GROUP BY Sale_man_ID,
			 Sale_man
	ORDER BY TONG_TIEN_QUY_DOI DESC

----LẤY RA NHÂN VIÊN CÓ TỔNG SỐ TIỀN BÁN HÀNG QUY ĐỔI LỚN NHẤT THEO TỪNG THÁNG (SỬ DỤNG ROW_NUMBER)
	WITH BANG1 AS
	  (SELECT ROW_NUMBER() OVER(PARTITION BY MONTH(Trans_Time)
								ORDER BY SUM(SO_TIEN_QUY_DOI) DESC) AS RN,
			  Sale_man_ID,
			  Sale_man,
			  MONTH(Trans_Time) AS THANG,
			  SUM(SO_TIEN_QUY_DOI) AS TONG_TIEN_QUY_DOI
	   FROM [QLBH]..BANHANG
	   WHERE YEAR(Trans_Time) = 2019
	   GROUP BY Sale_man_ID,
				Sale_man,
				MONTH(Trans_Time))
	SELECT THANG,
		   Sale_man_ID,
		   Sale_man,
		   TONG_TIEN_QUY_DOI
	FROM BANG1
	WHERE RN=1


--=====================================================
--TASK 3: CREATE PROCEDURE WITH PARAMETERS
--=====================================================
-- TỪ BẢNG BÁN HÀNG (ĐÃ CÓ CỘT SỐ TIỀN QUY ĐỔI) 
-- TẠO THỦ TỤC LẤY RA TOP 3 CỬA HÀNG (STORE) CÓ TỔNG SỐ TIỀN BÁN HÀNG QUY ĐỔI LỚN NHẤT THEO NGÀY
-- BẢNG TẠO RA BAO GỒM NGÀY THỐNG KÊ, TÊN STORE, TỔNG SỐ TIỀN BÁN HÀNG QUY ĐỔI (NGAYTHONGKE DATE, STORE_NAME, SO_TIEN_BH_QUY_DOI)
-- LẤY RA DANH SÁCH TOP 3 CỬA HÀNG CÓ SỐ TIỀN BÁN HÀNG QUY ĐỔI LỚN NHẤT TẠI NGÀY '20190628'
-- VÀ XUẤT RA EXCEL
-- ================================================
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO

	CREATE PROCEDURE GetTop3StoreByDate -- Add the parameters for the stored procedure here
	 @NGAYTHONGKE DATE AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from

	SET NOCOUNT ON; -- Insert statements for procedure here
	WITH BT2 AS
	  (
	   SELECT ROW_NUMBER() OVER(PARTITION BY CONVERT(DATE,Trans_Time)
							  ORDER BY SUM(SO_TIEN_QUY_DOI) DESC) AS RN,
			[Store ID],
			SUM(SO_TIEN_QUY_DOI) AS TONG_TIEN_QUY_DOI_NGAY
	   FROM [QLBH]..BANHANG
	   GROUP BY CONVERT(DATE,Trans_Time),
				[Store ID]
	   HAVING CONVERT(DATE,Trans_Time)=(@NGAYTHONGKE)) 
   
	--PRINT 'Step1: TẠO BẢNG THỐNG KÊ TỔNG TIỀN QUY ĐỔI THEO NGÀY VÀ ĐÁNH SỐ SẮP XẾP THỨ TỰ GIẢM DẦN'
	SELECT @NGAYTHONGKE AS NGAYTHONGKE_DATE,
		   [Store ID],
		   TONG_TIEN_QUY_DOI_NGAY
	FROM BT2
	WHERE RN IN (1, 2, 3) 
	--PRINT 'Step2: TOP 3 CỬA HÀNG CÓ SỐ TIỀN BÁN HÀNG QUY ĐỔI LỚN NHẤT THEO NGÀY TRUY XUẤT' 
	END 
		  
	GO

-- Thực hiện PROCEDURE GetTop3StoreByDate
	EXECUTE GetTop3StoreByDate '20190628'

-- Xóa PROCEDURE GetTop3StoreByDate
	DROP PROCEDURE GetTop3StoreByDate