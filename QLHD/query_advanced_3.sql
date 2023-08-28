-- ***********************************
-- SQL ADVANCED 3
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


-----------------------------------------------
--TASK 1: Table Function, Procedure
-----------------------------------------------
--CÓ NẰM TRONG DANH SÁCH TOP 3 NHÂN VIÊN CÓ DOANH SỐ BÁN HÀNG LỚN NHẤT
-- VÀ XUẤT RA TÊN NHÂN VIÊN ĐÓ
-- Table: [HOADON], [NHANVIEN] 
-- GỢI Ý: TABLE FUNCTIONS
----B1: TẠO FUNCTION LẤY RA DANH SÁCH TOP 3 NHÂN VIÊN CÓ DOANH SỐ LỚN NHÂT
----B2: KIỂM TRA NHÂN VIÊN ĐÓ CÓ NẰM TRONG TOP 3 KHÔNG, NẾU CÓ THÌ TRẢ RA KẾT QUẢ LÀ TÊN NHÂN VIÊN,NẾU KHÔNG THÌ RETURN 0 
GO
	CREATE FUNCTION FUNC_TOP3_DOANHSO_NV() RETURNS TABLE AS
	RETURN
		SELECT TOP 3 b.MANV,
				   b.HOTEN,
				   SUM(TRIGIA) AS DOANHSO
		FROM HOADON a
		LEFT JOIN NHANVIEN b ON a.MANV=b.MANV
		GROUP BY b.MANV,
				 b.HOTEN
		ORDER BY DOANHSO DESC
GO

	SELECT * FROM DBO.FUNC_TOP3_DOANHSO_NV()
	

GO
	CREATE PROCEDURE PROC_CHECK_MANV_TOP3(@MANV VARCHAR(4)) AS
	DECLARE @TENNV VARCHAR(40)
	IF @MANV IN
		(SELECT MANV
		FROM DBO.FUNC_TOP3_DOANHSO_NV())
	SET @TENNV=
		(SELECT HOTEN
		FROM DBO.FUNC_TOP3_DOANHSO_NV()
		WHERE MANV=@MANV) ELSE
	SET @TENNV='0'
	PRINT @TENNV
GO

	EXEC PROC_CHECK_MANV_TOP3 NV02

-----------------------------------------------
-- TASK 2: Scalar Function, Procedure, WHILE / CASE WHEN
-----------------------------------------------
-- TỪ TUỔI CỦA KHÁCH HÀNG 
----NẾU KH LỚN HƠN THÌ 60 CHO THU NHẬP LÀ 1000 $
----NẾU KH NHỎ HƠN 60 VÀ LỚN HƠN 50 THÌ CHO THU NHẬP LÀ 1500 $
----NGƯỢC LẠI THÌ THU NHẬP LÀ 2000 $
--Table: [KH_BACKUP] [SELECT * INTO KH_BACKUP FROM KHACHHANG]

	SELECT * INTO KH_BACKUP FROM KHACHHANG

	SELECT * FROM KH_BACKUP

GO
	-- Tạo Function tính tuổi
	CREATE FUNCTION AGE_CALCULATE (@NGAYSINH DATE, @NGDK DATE)	RETURNS INT AS
	BEGIN
		RETURN DATEDIFF(YEAR,@NGAYSINH,@NGDK)
	END
GO

--GIẢI QUYẾT VÍ DỤ THEO 2 CÁCH: 
----CÁCH 1: SỬ DỤNG WHILE VÒNG LẶP

	CREATE PROCEDURE PROC_TINH_THUNHAPKH
	AS
	BEGIN

		-- Xóa các bảng tạm nếu tồn tại
		DROP TABLE IF EXISTS dbo.#BANGKETQUA1
		DROP TABLE IF EXISTS dbo.#MAKH
		DROP TABLE IF EXISTS dbo.#MAKH_CURSOR_LIST

		-- Tạo bảng tạm BANGKETQUA1
		CREATE TABLE #BANGKETQUA1 (
		MAKH VARCHAR(4),
		TUOIKH INT,
		THUNHAPKH INT
		)

		-- Tạo bảng tạm danh sách mã khách hàng không trùng lặp
		SELECT DISTINCT MAKH 
		INTO #MAKH
		FROM KH_BACKUP

		-- Tạo bảng tạm Mã khách hàng đánh số thứ tự
		SELECT MAKH, ROW_NUMBER() OVER(ORDER BY MAKH) RN 
		INTO #MAKH_CURSOR_LIST
		FROM #MAKH


		-- Tính tổng số mã khách hàng
		DECLARE @MAKH_LIST_LENGHT INT, @MAKH_ROW_NO INT =1
		SELECT @MAKH_LIST_LENGHT=COUNT(*) FROM #MAKH_CURSOR_LIST

	
		-- Chạy vòng lặp kết thúc khi chạm số tổng mã khách hàng
		WHILE @MAKH_ROW_NO <= @MAKH_LIST_LENGHT
		BEGIN
			--Step1 Xác định mã khách hàng theo số thứ tự vị trí RN
			DECLARE @MAKH VARCHAR(4)		
			SELECT @MAKH = MAKH 
			FROM #MAKH_CURSOR_LIST
			WHERE RN =@MAKH_ROW_NO

			--Step2 Xác định tuổi khách hàng ứng với MAKH ở Step1
			DECLARE @TUOIKH INT		
			SELECT @TUOIKH=DBO.AGE_CALCULATE(NGSINH,NGDK)
			FROM KH_BACKUP
			WHERE MAKH=@MAKH

			--Step3 Xác định thu nhập khách hàng ứng với số tuổi ở Step2
			DECLARE @THUNHAPKH INT	
			IF @TUOIKH > 60 
				SET @THUNHAPKH = 1000
			ELSE
				IF @TUOIKH > 50
				SET @THUNHAPKH = 1500
				ELSE 
				SET @THUNHAPKH = 2000
        
			--Step4 Nhập thông tin MAKH ở Step1, TUOIKH ở Step2, THUNHAPKH ở Step3 vào bảng BANGKETUQA1
			INSERT INTO #BANGKETQUA1(MAKH,TUOIKH,THUNHAPKH)
			VALUES (@MAKH,@TUOIKH,@THUNHAPKH)

			-- Tham chiếu tới dòng MKH tiếp theo
			SET @MAKH_ROW_NO=@MAKH_ROW_NO+1

		END -- Kết thúc vòng lặp

		SELECT a.MAKH,
			   b.HOTEN,
			   a.TUOIKH,
			   a.THUNHAPKH
		FROM #BANGKETQUA1 a
		LEFT JOIN KH_BACKUP b ON a.MAKH=b.MAKH

	END -- Kết thúc Procedure
GO

	-- THỰC THI PROC
		EXEC PROC_TINH_THUNHAPKH

----CÁCH 2: SỬ DỤNG CASE WHEN 
	SELECT MAKH,
		   HOTEN,
		   DBO.AGE_CALCULATE(NGSINH, NGDK) AS TUOIKH,
		   (CASE
				WHEN DBO.AGE_CALCULATE(NGSINH, NGDK) > 60 THEN 1000
				WHEN DBO.AGE_CALCULATE(NGSINH, NGDK) > 50 THEN 1500
				ELSE 2000
			END) AS THUNHAP
	FROM KHACHHANG

-----------------------------------------------
-- TASK 3: Create Procedure with ROW_NUMBER(), WHILE
-----------------------------------------------
--CÓ ĐƯỢC TÍNH ĐÚNG THEO SLSP VÀ ĐƠN GIÁ SP THEO TỪNG HĐ HAY KHÔNG ?
--SỬ DỤNG VÒNG LẶP ĐỂ INSERT INTO VÀO BẢNG TRÔNG HĐ KHÔNG KHỚP DOANH THU VỚI NHÃN LÀ ‘DOANH THU KHÔNG KHỚP’ 
-- VÀ SOHD KHỚP DOANH THU VỚI NHÃN LÀ ‘DOANH THU KHỚP’ 
-- TASK: CHIA THÀNH CÁC BƯỚC NHỎ, MỖI BƯỚC GÁN VỚI FUNCTION HOẶC PROCEDURE
--BẢNG KẾT QUẢ: [SOHD], [LABEL], [TRIGIA], [DOANHTHU_TINH_LAI], [TEN_KH], [SODT_KH], [TEN_NV] 

-----
GO
	CREATE PROCEDURE PROC_CHECK_DOANHTHU_SOHD AS
	BEGIN
	DROP TABLE IF EXISTS dbo.#BANGTAM1

	CREATE TABLE #BANGTAM1
	(SOHD INT,
	[LABEL] NVARCHAR(MAX)

	)

	SELECT DISTINCT SOHD
	INTO #SOHD
	FROM HOADON

	SELECT SOHD,
		   ROW_NUMBER() OVER(
							 ORDER BY SOHD) AS RN INTO #SOHD_RN
	FROM #SOHD

	DECLARE @SOHD_TOTAL INT, @SOHD_ROW_NO INT = 1
	SELECT @SOHD_TOTAL=COUNT(*) FROM #SOHD_RN

		WHILE @SOHD_ROW_NO<=@SOHD_TOTAL
		BEGIN
			DECLARE @SOHD INT
			SELECT @SOHD=SOHD
			FROM #SOHD_RN
			WHERE RN=@SOHD_ROW_NO

			INSERT INTO #BANGTAM1 (SOHD,[LABEL])
			SELECT BT.SOHD,
					CASE
					WHEN BT.TRIGIA=DOANHTHU_TINH_LAI THEN N'DOANH THU KHỚP'
					ELSE N'DOANH THU KHÔNG KHỚP'
					END
			FROM (
				SELECT a.SOHD,
						b.TRIGIA,
						SUM(a.SL*c.GIA) AS DOANHTHU_TINH_LAI,
						d.HOTEN AS TEN_KH,
						d.SODT AS SODT_KH,
						e.HOTEN AS TEN_NV
				FROM CTHD a
				LEFT JOIN HOADON b ON a.SOHD=b.SOHD
				LEFT JOIN SANPHAM c ON a.MASP=c.MASP
				LEFT JOIN KHACHHANG d ON b.MAKH=d.MAKH
				LEFT JOIN NHANVIEN e ON b.MANV=e.MANV
				GROUP BY a.SOHD,
							b.TRIGIA,
							d.HOTEN,
							d.SODT,
							e.HOTEN	) BT
			WHERE BT.SOHD=@SOHD

		SET @SOHD_ROW_NO=@SOHD_ROW_NO+1
		END --- Kết thúc While

	SELECT aa.SOHD,
		   aa.LABEL,
		   bb.TRIGIA,
		   bb.DOANHTHU_TINH_LAI,
		   bb.TEN_KH,
		   bb.SODT_KH,
		   bb.TEN_NV
	FROM #BANGTAM1 aa
	LEFT JOIN
	  (SELECT a.SOHD,
			  b.TRIGIA,
			  SUM(a.SL*c.GIA) AS DOANHTHU_TINH_LAI,
			  d.HOTEN AS TEN_KH,
			  d.SODT AS SODT_KH,
			  e.HOTEN AS TEN_NV
	   FROM CTHD a
	   LEFT JOIN HOADON    b ON a.SOHD=b.SOHD
	   LEFT JOIN SANPHAM   c ON a.MASP=c.MASP
	   LEFT JOIN KHACHHANG d ON b.MAKH=d.MAKH
	   LEFT JOIN NHANVIEN  e ON b.MANV=e.MANV
	   GROUP BY a.SOHD,
				b.TRIGIA,
				d.HOTEN,
				d.SODT,
				e.HOTEN) bb ON aa.SOHD=bb.SOHD

	END--- Kết thúc PROCEDURE

GO

	EXEC PROC_CHECK_DOANHTHU_SOHD
	