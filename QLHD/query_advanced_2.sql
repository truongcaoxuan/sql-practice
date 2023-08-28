-- ***********************************
-- SQL ADVANCED 2
-- ***********************************

use [QLHD]
GO

--Sử dụng các bảng sau để tạo thủ tục yêu cầu như bên dưới:
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

---------------------------------------------------------------------------
-- TASK 1: Scalar Function
--------------------------------------------------------------------------

--1.	Tạo hàm hiển thị thứ trong tuần tương ứng với ngày khai báo
GO
	CREATE FUNCTION WEEKDAY_NAME (@VarNgay DATE) RETURNS INT AS
	BEGIN
		RETURN DATEPART(WEEKDAY,@VarNgay)
	END
GO
	-- Sử dụng Scalar Function
	SELECT dbo.WEEKDAY_NAME ('20200702') AS NAME_OF_WEEKDAY

	--DROP FUNCTION dbo.WEEKDAY_NAME

--2.	Tạo hàm xác định tuổi khách hàng tại ngày đăng ký 
--Table: [KHACHHANG]
--Tham số đầu vào: [NGSINH], [NGDK]
GO
	CREATE FUNCTION AGE_CALCULATE (@NGAYSINH DATE, @NGDK DATE) RETURNS INT AS 
	BEGIN
		RETURN DATEDIFF(YEAR,@NGAYSINH,@NGDK)
	END
GO
	-- Sử dụng Scalar Function
	SELECT dbo.AGE_CALCULATE ('19810525','20200623') AS AGE

	--DROP FUNCTION dbo.AGE_CALCULATE

--3.	Sử dụng hàm viết ra trong câu 1, 2, viết query hiển thị MAKH, TUOI (tại tk đăng ký), BIRTH_WEEKDAY (Sinh vào thứ mấy trong tuần)
--Table: [KHACHHANG]

	SELECT MAKH,
		   dbo.AGE_CALCULATE (NGSINH, NGDK) AS TUOI,
		   dbo.WEEKDAY_NAME(NGSINH) AS BIRTH_WEEKDAY
	FROM KHACHHANG

---------------------------------------------------------------------------
-- TASK 2: Table Function, Procedure with IF ELSE
--------------------------------------------------------------------------

--1.	Tìm thông tin khách hàng mua nhiều sp nhất tại ngày dd/mm/yyyy (biến đầu vào)
--Table: [CTHD], [HOADON], [KHACHHANG]
GO
	CREATE FUNCTION TOP1_KH_BY_SL (@NGAYMUA DATE) RETURNS TABLE AS 
	RETURN
	  (SELECT TOP 1 b.NGHD,
				  c.MAKH,
				  c.HOTEN,
				  SUM(SL) AS TONGSL
	   FROM CTHD a
	   LEFT JOIN HOADON b ON a.SOHD=b.SOHD
	   LEFT JOIN KHACHHANG c ON b.MAKH=c.MAKH
	   WHERE b.NGHD=@NGAYMUA
	   GROUP BY b.NGHD,
				c.MAKH,
				c.HOTEN
	   ORDER BY TONGSL DESC)

GO
	-- Sử dụng Table Function
	SELECT * FROM TOP1_KH_BY_SL('20070101')

	--DROP FUNCTION dbo.TOP1_KH_BY_SL

--2.	Tìm số lượng sp theo từng hợp đồng. Trong trường hợp: 
--Biến đầu vào = 0 thì hiển thị SLSP theo từng HĐ
--Biến đầu vào = @SOHD thì hiển SLSP của @SOHD
--	Table: [CTHD]
GO
	CREATE PROCEDURE PROC_CHECK_SOHD (@SOHD INT) AS BEGIN 
	IF @SOHD=0
		SELECT SOHD,
			   SUM(SL) AS TONGSL
		FROM CTHD
		GROUP BY SOHD 
	ELSE
		SELECT SOHD,
			   SUM(SL) AS TONGSL
		FROM CTHD
		WHERE SOHD=@SOHD
		GROUP BY SOHD END
GO
	-- Thực thi Procedure
	EXEC PROC_CHECK_SOHD 0

---------------------------------------------------------------------------
-- TASK 3: Scalar Function with IF ELSE
--------------------------------------------------------------------------

--1.	Nếu SL không có giá trị NULL va SL >= 100 thì in ra màn hình ‘[SOHD] có [SL] sản phẩm’
--Nếu SL không có giá trị NULL và SL < 100 thì in ra màn hình ‘SOHD có SLSP không đạt’
--Nếu SL có giá trị NULL thì in ra màn hình ‘SLSP chưa được ghi nhận’
--Table: [CTHD]

-- Cách 1:
GO
	CREATE FUNCTION FUNC_CHECK_SL (@SOHD INT,@SL INT) RETURNS NVARCHAR(MAX) AS
	BEGIN
		DECLARE @KETLUAN NVARCHAR(MAX)
		IF @SL IS NULL
			SET @KETLUAN= N'SLSP CHƯA ĐƯỢC GHI NHẬN'
		ELSE
			IF @SL>=100
				SET @KETLUAN = CONVERT(NVARCHAR,@SOHD)+N' CÓ '+CONVERT(NVARCHAR,@SL) +N' SẢN PHẨM'
			ELSE
				SET @KETLUAN =CONVERT(NVARCHAR,@SOHD)+N' CÓ SLSP KHÔNG ĐẠT'
		RETURN @KETLUAN
	END
GO
	-- Sử dụng Function
	SELECT DBO.FUNC_CHECK_SL(SOHD, SUM(SL)) AS KETLUAN
	FROM CTHD
	GROUP BY SOHD

	--DROP FUNCTION FUNC_CHECK_SL

-- Cách 2:
GO
	CREATE FUNCTION CHECK_SL(@SOHD INT, @THRESHOLD INT) RETURNS NVARCHAR(MAX) AS
	BEGIN
		DECLARE @SLSP INT
		SET @SLSP = (SELECT SUM(SL) SLSP FROM CTHD WHERE SOHD = @SOHD)

		DECLARE @NOTI NVARCHAR(MAX)

		IF @SLSP IS NULL
			SET @NOTI = N'SLSP CHƯA ĐƯỢC GHI NHẬN'
			--PRINT @NOTI
		ELSE
			IF @SLSP < @THRESHOLD
				SET @NOTI = CONVERT(NVARCHAR(MAX),@SOHD) + ' CÓ SLSP KHÔNG ĐAT'
				--PRINT @NOTI
			ELSE
				SET @NOTI = CONVERT(NVARCHAR(MAX),@SOHD) + ' CÓ ' + CONVERT(NVARCHAR(MAX),@SLSP) + ' SAN PHAM'
				--PRINT @NOTI
		RETURN @NOTI
	END
GO

	SELECT DBO.CHECK_SL(SOHD,SUM(SL)) AS KETLUAN
	FROM CTHD
	GROUP BY SOHD
---------------------------------------------------------------------------
--TASK 4: Table Function with CASE WHEN
--------------------------------------------------------------------------

--1.	Đánh dấu khách hàng mới cũ theo từng năm
--Table: [HOADON]

-- Cách 1
GO
	CREATE FUNCTION FUNC_PHANLOAI_KH(@YEAR INT) RETURNS TABLE AS
	RETURN
	(
		SELECT MAKH,YEAR(NGHD) AS NAM_HD_DAU_TIEN,
				CASE
					WHEN MIN(YEAR(NGHD)) >= @YEAR THEN 'New'
					ELSE 'Existing'
				END
				AS 'PHANLOAIKH'
		FROM HOADON
		GROUP BY MAKH, YEAR(NGHD)
	)
GO

	SELECT * FROM DBO.FUNC_PHANLOAI_KH(2007)

	--DROP FUNCTION FUNC_PHANLOAI_KH

-- Cách 2
GO
	WITH DAT AS (
	SELECT DISTINCT MAKH,
					YEAR(NGHD) NAM_HD
	FROM HOADON
	--ORDER BY MAKH, YEAR(NGHD)
	)

	SELECT MAKH,
		   NAM_HD,
		   CASE
			   WHEN RN = 1 THEN 'NEW'
			   ELSE 'EXISTING'
		   END AS KH_CU_MOI
	FROM
	  (SELECT A.*,
			  ROW_NUMBER() OVER(PARTITION BY MAKH
								ORDER BY NAM_HD ASC) AS RN
	   FROM DAT A) A


--2.	Điền trị giá cho HĐ có mã 1200, 1300, 1400, 2000 lần lượt là 1.200.000, 1.300.000, 1.400.000 và 1.500.000 - Using CASE in an UPDATE statement
--Table: [HOADON_2] (SELECT * INTO HOADON_2 FROM HOADON)

	SELECT * INTO HOADON_2 FROM HOADON

	UPDATE HOADON_2
	SET TRIGIA = (CASE
					WHEN SOHD=1200 THEN 1200000
					WHEN SOHD=1300 THEN 1300000
					WHEN SOHD=1400 THEN 1400000
					WHEN SOHD=2000 THEN 1500000
					ELSE TRIGIA
					END)

	SELECT * FROM HOADON_2
---------------------------------------------------------------------------
-- TASK 5: WHILE, CURSOR
--------------------------------------------------------------------------
/*
--1.	Sử dụng vòng lặp để INSERT INTO vào bảng trống theo từng tháng các thông tin sau:
	MONTH		: Tháng thống kê
	REVENUE		: Doanh số theo tháng
	TENSP		: Ten SP bán được số lượng nhiều nhất trong tháng
	SLSP		: Số lượng sp bán tương ứng với TENSP
	SP_DOANHSO	: Doanh số TENSP bán được nhiều nhất trong tháng
	MAKH		: Mã KH có doanh số cao nhất theo tháng
	TENKH		: Tên KH có doanh số cao nhất theo tháng
	TUOI		: Tuổi KH có doanh số cao nhất theo tháng
	MANV		: Mã NV có doanh số cao nhất theo tháng
	TENNV		: Tên NV có doanh số cao nhất theo tháng
*/

	CREATE TABLE BANGTEST3(
		MONTH_ INT,
		REVENUE_ FLOAT,
		TENSP_ NVARCHAR(40),
		SLSP_ INT,
		SP_DOANHSO_ FLOAT,
		MAKH_ VARCHAR(4),
		TENKH_ VARCHAR(40),
		TUOIKH_ INT,
		MANV_ VARCHAR(4),
		TENNV_ VARCHAR(40)
	)

	DECLARE BT3_CURSOR CURSOR FOR
		SELECT DISTINCT MONTH(NGHD) FROM HOADON --- EDIT

	DECLARE @THANG INT --- EDIT

	OPEN BT3_CURSOR
	FETCH NEXT FROM BT3_CURSOR INTO @THANG

	WHILE @@FETCH_STATUS = 0 ---- CÓ GIÁ TRỊ KHI CHUYỂN CON TRỎ CURSOR
	BEGIN
		---- EDIT
		DECLARE @REVENUE FLOAT
		SET @REVENUE = (SELECT SUM(TRIGIA) FROM HOADON WHERE MONTH(NGHD) = @THANG)

		DECLARE @TENSP NVARCHAR(MAX)
		SET @TENSP = (SELECT TOP 1 c.TENSP 
						FROM CTHD a
							LEFT JOIN HOADON  b ON a.SOHD=b.SOHD
							LEFT JOIN SANPHAM c ON a.MASP=c.MASP
						WHERE MONTH(b.NGHD)=@THANG
						GROUP BY c.TENSP
						ORDER BY SUM(SL) DESC
					  )
		DECLARE @SLSP INT
		SET @SLSP = (SELECT SUM(SL)
					FROM CTHD a
						LEFT JOIN SANPHAM b ON a.MASP=b.MASP
					WHERE b.TENSP=@TENSP
					)
		DECLARE @SP_DOANHSO FLOAT
		SET @SP_DOANHSO = (SELECT SUM(TRIGIA)
							FROM CTHD a
								LEFT JOIN HOADON  b ON a.SOHD=b.SOHD
								LEFT JOIN SANPHAM c ON a.MASP=c.MASP
							WHERE c.TENSP=@TENSP
							)
		DECLARE @MAKH VARCHAR(4)
		SET @MAKH=(SELECT TOP 1 MAKH 
					FROM HOADON
					WHERE MONTH(NGHD)=@THANG
					GROUP BY MAKH
					ORDER BY SUM(TRIGIA) DESC
		)

		DECLARE @TENKH VARCHAR(40)
		SET @TENKH =(SELECT HOTEN
						FROM KHACHHANG
						WHERE MAKH=@MAKH
		)

		DECLARE @TUOIKH INT
		SET @TUOIKH = (SELECT dbo.AGE_CALCULATE (NGSINH,NGDK)
						FROM KHACHHANG
						WHERE MAKH=@MAKH
		)

		DECLARE @MANV VARCHAR(4)
		SET @MANV = (SELECT TOP 1 MANV
						FROM HOADON
						WHERE MONTH(NGHD)=@THANG
						GROUP BY MANV
						ORDER BY SUM(TRIGIA) DESC
					
		)

		DECLARE @TENNV VARCHAR(40)
		SET @TENNV = (SELECT HOTEN
						FROM NHANVIEN
						WHERE MANV=@MANV
		)

		INSERT INTO BANGTEST3(MONTH_,REVENUE_,TENSP_,SLSP_,SP_DOANHSO_,MAKH_,TENKH_,TUOIKH_,MANV_,TENNV_) 
		VALUES(@THANG,@REVENUE,@TENSP,@SLSP,@SP_DOANHSO,@MAKH,@TENKH,@TUOIKH,@MANV,@TENNV)
		---- END
		FETCH NEXT FROM BT3_CURSOR INTO @THANG
	END



	SELECT * FROM BANGTEST3

	-- DELETE BANGTEST3

	CLOSE BT3_CURSOR
	DEALLOCATE BT3_CURSOR


	