-- ***********************************
-- SQL BASIC
-- ***********************************

USE [QLBH]
GO

-- ======================================================
-- TASK 1: SELECT, UPDATE
-- ======================================================

    --1.1. Từ bảng dữ liệu BANHANG trong database QLBH thực hiện truy vấn lấy ra các bản ghi của "STORE 1" trong bảng BANHANG
		SELECT *
		FROM BANHANG
		WHERE BANHANG.[Store ID]='STORE 1'

	--1.2. Lấy ra các bản ghi của khách hàng có mã khách hàng là MKH611084 và phân loại khách hàng "Nhóm 1"
		ALTER TABLE QLBH..KHACHHANG
		ADD [Phân loại KH] NVARCHAR(100)

		UPDATE QLBH..KHACHHANG
		SET [Phân loại KH] = N'Nhóm 1'
		WHERE QLBH..KHACHHANG.[Mã KH]='MKH611084'

		SELECT *
		FROM KHACHHANG
		WHERE KHACHHANG.[Mã KH]='MKH611084'

	--1.3. Lấy ra các giao dịch có mã khách hàng là MKH806962 và bán mới sale_man có id là 717-06-2405
		SELECT *
		FROM BANHANG
		WHERE BANHANG.[Mã khách hàng]='MKH806962' AND BANHANG.Sale_man_ID='717-06-2405'
	
	--1.4. Lấy ra các bản ghi có tên hàng hóa là "Seat Lug" và bán tại "STORE 3"
		SELECT *
		FROM QLBH..BANHANG
		WHERE QLBH..BANHANG.[Loại hàng hóa]='Seat Lug' AND QLBH..BANHANG.[Store ID]='STORE 3'

	--1.5. Lấy ra các bản ghi có tên khách hàng bắt đầu bằng 'J'
		SELECT *
		FROM QLBH..KHACHHANG
		WHERE QLBH..KHACHHANG.[Tên khách hàng] LIKE 'J%'

	--1.6. Lấy ra các bản ghi có tên khách hàng kết thúc tên bằng 'Z'
		SELECT *
		FROM QLBH..KHACHHANG
		WHERE QLBH..KHACHHANG.[Tên khách hàng] LIKE '%Z'

-- ======================================================
-- TASK 2: SELECT INTO, ALTER TABLE, UPDATE
-- ======================================================

	-- Từ bảng dữ liệu BANHANG tạo ra bảng BANHANG_BACKUP bao gồm các trường thông tin sau 
	-- "Store ID", "Trans_Time", "Loại tiền", "Số tiền mua hàng nguyên tệ", "Hoa hồng"
		SELECT [Store ID],
			   [Trans_Time],
			   [Loại tiền],
			   [Số tiền Mua hàng nguyên tệ],
			   [Hoa hồng] INTO QLBH..BANHANG_BACKUP
		FROM QLBH..BANHANG

	--2.1. Tạo thêm 2 cột "Số lượng hàng hóa", "Phí hoa hồng" vào bảng BANHANG_BACKUP
		ALTER TABLE QLBH..BANHANG_BACKUP
		ADD [Số lượng hàng hóa] FLOAT, 
		    [Phí hoa hồng] FLOAT;
		
	--2.2. Cập nhật dữ liệu vào cột "Số lượng hàng hóa" biết rằng 
	--   "Số lượng hàng hóa" = "Số tiền mua hàng nguyên tệ"/"Unit price"
		UPDATE QLBH..BANHANG_BACKUP
		SET [Số lượng hàng hóa] = ROUND(QLBH..BANHANG.[Số tiền Mua hàng nguyên tệ]/NULLIF(QLBH..BANHANG.[Unit Price], 0), 0)
		FROM QLBH..BANHANG
		WHERE QLBH..BANHANG_BACKUP.[Số tiền Mua hàng nguyên tệ]= QLBH..BANHANG.[Số tiền Mua hàng nguyên tệ]

	--2.3. Cập nhật cột phí hoa hồng biết rằng 
	--   "Phí hoa hồng" = "Hoa hồng" * "Số tiền mua hàng nguyên tệ" * 5%
		UPDATE QLBH..BANHANG_BACKUP
		SET [Phí hoa hồng] = [Hoa hồng]*[Số tiền Mua hàng nguyên tệ]*0.05

-- ======================================================	
-- TASK 3: CREATE TABLE, INSERT INTO, DELETE, TRUNCATE
-- ======================================================

	-- Tạo bảng hàng hóa test (HH_TEST) bao gồm các trường thông tin "STT", "Loại sản phẩm", "Giá"
		CREATE TABLE QLBH..HH_TEST
		(
			STT INT,
			[Loại sản phẩm] VARCHAR (100),
			[Giá] FLOAT
		)

	--3.1. Từ dữ liệu bảng HANGHOA, thực hiện insert into các loại mặt hàng có "Giá" hơn lớn hơn 300 vào bảng HH_TEST
		INSERT INTO QLBH..HH_TEST ([STT], [Loại sản phẩm], [Giá])
		SELECT [STT],
			   [Product],
			   [Price]
		FROM QLBH..[HANGHOA]
		WHERE QLBH..[HANGHOA].[Price]>300

		SELECT *
		FROM QLBH..HH_TEST
		Order BY QLBH..HH_TEST.[Giá] ASC

	--3.2. Thực hiện xóa tất cả các thông tin vừa insert into vào bảng HH_TEST
		DELETE FROM QLBH..HH_TEST
		TRUNCATE TABLE QLBH..HH_TEST
	
	--3.3. Thực hiện insert into các loại mặt hàng bắt đầu bằng "METAL" vào bảo HH_TEST và xóa mặt hàng có "Giá" nhỏ hơn 500
		INSERT INTO QLBH..HH_TEST ([STT], [Loại sản phẩm], [Giá])
		SELECT [STT],
			   [Product],
			   [Price]
		FROM QLBH..[HANGHOA]
		WHERE QLBH..[HANGHOA].[Product] LIKE 'METAL%'

		DELETE
		FROM QLBH..HH_TEST
		WHERE QLBH..HH_TEST.[Giá]<500

-- ======================================================
-- TASK 4: CREATE TABLE, INSERT INTO, UPDATE
-- ======================================================

	--4.1. Từ bảng NHANVIEN lấy các nhân viên có "Hệ số lương" lớn hơn 10 
		SELECT *
		FROM QLBH..NHANVIEN
		WHERE QLBH..NHANVIEN.[Hệ số lương] > 10

	--4.2. Tạo bảng tính lương (BANGLUONG) cho nhân viên bao gồm các trường thông tin sau: 
	--     Mã nhân viên, Tên nhân viên, Ngày vào công ty, Hệ số lương, Lương 
		CREATE TABLE QLBH..BANGLUONG
		([Mã nhân viên] VARCHAR (50),
		[Tên nhân viên] NVARCHAR (100),
		[Ngày vào công ty] DATE,
		[Hệ số lương] FLOAT,
		[Lương] FLOAT
		)

	--4.3. Thực hiện insert into các trường thông tin trong BANGLUONG cho nhân viên tạo ở mục 4.2 từ dữ liệu bảng NHANVIEN
		INSERT INTO QLBH..BANGLUONG([Mã nhân viên], [Tên nhân viên], [Ngày vào công ty], [Hệ số lương])
		SELECT [Mã Nhân viên],
			   [Name],
			   [Ngày vào công ty],
			   [Hệ số lương]
		FROM QLBH..NHANVIEN

	--4.4. Thực hiện update trường lương biết rằng 
	--     Lương = hệ số lương * lương cơ bản (biết lương cơ bản là 5.600.000)
		UPDATE QLBH..BANGLUONG
		SET QLBH..BANGLUONG.[Lương] = QLBH..BANGLUONG.[Hệ số lương]*5600000

	--4.5. Từ bảng tính lương, lấy ra các nhân viên có lương lớn hơn 80 triệu  
		SELECT *
		FROM QLBH..BANGLUONG
		WHERE QLBH..BANGLUONG.[Lương] > 80000000

