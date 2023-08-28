-- ***********************************
-- SQL INTERMEDIATE
-- ***********************************
USE [QLHD]
GO

--====================================
--TASK 1: JOIN
--====================================

	--1. TÌM TOP 3 KHÁCH HÀNG CÓ NHIỀU ĐƠN HÀNG NHẤT TRONG NĂM 2006 VÀ 
	-- LẤY RA TÊN KH ĐÓ (DÙNG BẢNG HOADON VÀ KHACHHANG)
		SELECT TOP 3 b.HOTEN
		FROM QLHD..HOADON a
		FULL OUTER JOIN QLHD..KHACHHANG b ON a.MAKH=b.MAKH
		WHERE YEAR(a.NGHD)=2006
		GROUP BY b.HOTEN
		ORDER BY COUNT(a.SOHD) DESC


	--2. THỐNG KÊ DOANH SỐ BÁN HÀNG CỦA NHÂN VIÊN THEO THÁNG TRONG NĂM 2006 
	-- (BAO GỒM CẢ HỌ VÀ TÊN, NGÀY VÀO LÀM VIỆC)
		SELECT MONTH(b.NGHD) AS THANG,
			   a.MANV,
			   a.HOTEN,
			   a.NGVL,
			   SUM(CONVERT(FLOAT,b.TRIGIA)) AS DOANHSO
		FROM QLHD..NHANVIEN a
		FULL OUTER JOIN QLHD..HOADON b ON a.MANV=b.MANV
		WHERE YEAR(b.NGHD)=2006
		GROUP BY MONTH(b.NGHD),
				 a.MANV,
				 a.HOTEN,
				 a.NGVL
		ORDER BY MONTH(b.NGHD) ASC


	--3. TÌM TÊN SẢN PHẨM BÁN CHẠY NHẤT TRONG BẢNG CTHD 
	-- (TÊN SẢN PHẨM LẤY TỪ BẢNG SẢN PHẨM)
		SELECT TOP 1 a.TENSP,
				   SUM(CONVERT(INT,b.SL)) AS TONGSL
		FROM QLHD..SANPHAM a
		RIGHT JOIN QLHD..CTHD b ON a.MASP=b.MASP
		GROUP BY a.TENSP
		ORDER BY TONGSL DESC

	--4: TÌM NGHD VÀ GIÁ CỦA CÁC SẢN PHẨM CỦA MÃ HOA DON 1004 
	-- (DÙNG 3 BẢNG CTHD,HOADON, SANPHAM)
		SELECT a.SOHD,
			   b.NGHD,
			   c.TENSP,
			   c.GIA
		FROM QLHD..CTHD a
		LEFT JOIN QLHD..HOADON b ON a.SOHD=b.SOHD
		LEFT JOIN QLHD..SANPHAM c ON a.MASP=c.MASP
		WHERE a.SOHD=1004

	--5: TỪ BẢNG HOADON ĐẾM XEM CÓ BN HOADON CHỨA CÁC SẢN PHẨM BÚT BI 
	--(SỬ DỤNG KẾT HỢP 2 BẢNG CTHD VÀ SANPHAM)
		SELECT b.TENSP,
			   COUNT(a.SOHD) AS TONGSOHD
		FROM QLHD..CTHD a
		LEFT JOIN QLHD..SANPHAM b ON a.MASP=b.MASP
		WHERE b.TENSP='BUT BI'
		GROUP BY b.TENSP

	--6: XÁC ĐỊNH CÁC MÃ SẢN PHẨM ĐƯỢC BÁN BỞI NHÂN VIÊN CÓ MÃ NV03, 
	-- LẤY RA TÊN SẢN PHẨM ĐÓ (SỬ DỤNG BẢNG HOADON, CTHD, SANPHAM)
		SELECT b.MANV,
			   a.MASP,
			   c.TENSP
		FROM QLHD..CTHD a
		LEFT JOIN QLHD..HOADON b ON a.SOHD = b.SOHD
		LEFT JOIN QLHD..SANPHAM c ON a.MASP=c.MASP
		WHERE b.MANV='NV03'

	--7: TÌM MÃ SẢN PHẨM ĐƯỢC BÁN NHIỀU NHẤT TRONG BẢNG CTHD VÀ LẤY RA TÊN SẢN PHẨM ĐÓ
		SELECT TOP 1 a.MASP,
				   b.TENSP,
				   SUM(CONVERT(INT,a.SL)) AS TONGSL
		FROM QLHD..CTHD a
		LEFT JOIN QLHD..SANPHAM b ON a.MASP=b.MASP
		GROUP BY a.MASP,
				 b.TENSP
		ORDER BY TONGSL DESC


	--8: LẤY RA TÊN NHÂN VIÊN, NGVL CỦA NHÂN VIÊN BIẾT RẰNG NHÂN VIÊN ĐÓ BÁN ĐƯỢC ÍT ĐƠN HÀNG NHẤT
		SELECT TOP 1 b.HOTEN,
				   b.NGVL
		FROM QLHD..HOADON a
		LEFT JOIN QLHD..NHANVIEN b ON a.MANV=b.MANV
		WHERE b.HOTEN IS NOT NULL
		GROUP BY b.HOTEN,
				 b.NGVL
		ORDER BY COUNT(a.SOHD) ASC


--====================================
--TASK 2: ALTER TABLE, UPDATE, SUM, CONVERT
--====================================

	-- TỪ BẢNG HOADON TẠO BẢNG HOADON_BK_1, 
		SELECT * INTO QLHD..HOADON_BK_1
		FROM QLHD..HOADON

	-- THÊM CỘT COMMISION VÀ UPDATE CỘT COMMISION BIẾT RẰNG COMMISION = TRỊ GIÁ * 10%
		ALTER TABLE QLHD..HOADON_BK_1
		ADD COMMISION FLOAT

		UPDATE QLHD..HOADON_BK_1
		SET COMMISION = TRIGIA*0.1

		SELECT *
		FROM QLHD..HOADON_BK_1

	-- THỰC HIỆN THỐNG KÊ COMMSION THEO TỪNG MÃ NHÂN VIÊN VÀ 
	-- LẤY RA NHÂN VIÊN ĐƯỢC NHÂN COMMISSION NHIỀU NHẤT TRONG NĂM 2006
		SELECT MANV,
			   SUM(CONVERT(FLOAT,COMMISION)) AS TONGCOMM
		FROM QLHD..HOADON_BK_1
		WHERE YEAR(NGHD)=2006
		GROUP BY MANV
		ORDER BY TONGCOMM DESC


	-- SAU ĐÓ THỰC HIỆN JOIN VÀO BẢNG NHÂN VIÊN LẤY RA TÊN NHÂN VIÊN VÀ NGVL
		SELECT TOP 1 a.MANV,
				   b.HOTEN,
				   SUM(CONVERT(FLOAT,a.COMMISION)) AS TONGCOMM
		FROM QLHD..HOADON_BK_1 a
		LEFT JOIN QLHD..NHANVIEN b ON a.MANV=b.MANV
		WHERE YEAR(a.NGHD)=2006
		GROUP BY a.MANV,
				 b.HOTEN
		ORDER BY TONGCOMM DESC

--====================================
--TASK 3: WITH AS, ROW_NUMBER()
--====================================

	--1. TỪ BẢNG HÓA ĐƠN LẤY RA MANV CÓ DOANH SỐ BÁN HÀNG CAO NHẤT TRONG MỖI THÁNG 
	-- (DOANH SỐ BÁN HÀNG BẰNG TỔNG TRỊ GIÁ) VÀ LẤY RA TÊN NHÂN VIÊN ĐÓ 

		-- Cách 1  dùng WITH AS
		WITH BANGTAM AS
		  (SELECT ROW_NUMBER() OVER(PARTITION BY MONTH(a.NGHD)
									ORDER BY SUM(CONVERT(FLOAT,a.TRIGIA)) DESC) AS RN,
				  a.MANV,
				  b.HOTEN,
				  MONTH(a.NGHD) AS THANG,
				  SUM(CONVERT(FLOAT,a.TRIGIA)) AS DOANHSO
		   FROM QLHD..HOADON a
		   LEFT JOIN QLHD..NHANVIEN b ON a.MANV=b.MANV
		   GROUP BY a.MANV,
					b.HOTEN,
					MONTH(a.NGHD))
		SELECT THANG,
			   MANV,
			   HOTEN,
			   DOANHSO
		FROM BANGTAM
		WHERE RN=1

		-- Cách 2  dùng Truy vấn lồng

		SELECT *
		FROM
		  (SELECT MONTH(NGHD) AS THANG,
				  a.MANV,
				  b.HOTEN,
				  SUM(a.TRIGIA) AS DOANHSO,
				  RN = ROW_NUMBER() OVER(PARTITION BY MONTH(a.NGHD)
										 ORDER BY SUM(a.TRIGIA) DESC)
		   FROM QLHD..HOADON a
		   LEFT JOIN QLHD..NHANVIEN b ON a.MANV=b.MANV
		   GROUP BY MONTH(a.NGHD),
					a.MANV,
					b.HOTEN) A
		WHERE RN = 1


	--2. TỪ BẢNG HÓA ĐƠN LẤY RA MANV CÓ DOANH SỐ BÁN HÀNG KÉM NHẤT TRONG MỖI THÁNG 
	-- (DOANH SỐ BÁN HÀNG BẰNG TỔNG TRỊ GIÁ) VÀ LẤY RA TÊN NHÂN VIÊN ĐÓ 

		-- Cách 1  dùng WITH AS
		WITH BANGTONGHOP AS
		  (SELECT MONTH(NGHD) AS THANG,
				  MANV,
				  SUM(TRIGIA) AS TOTAL_TRIGIA,
				  RN = ROW_NUMBER() OVER(PARTITION BY MONTH(NGHD)
										 ORDER BY SUM(TRIGIA) ASC)
		   FROM QLHD..HOADON
		   GROUP BY MONTH(NGHD),
					MANV)
		SELECT *
		FROM BANGTONGHOP
		WHERE RN = 1

		-- Cách 2  dùng Truy vấn lồng
		SELECT *
		FROM
		  (SELECT MONTH(NGHD) AS THANG,
				  MANV,
				  SUM(TRIGIA) AS TOTAL_TRIGIA,
				  RN = ROW_NUMBER() OVER(PARTITION BY MONTH(NGHD)
										 ORDER BY SUM(TRIGIA) ASC)
		   FROM QLHD..HOADON
		   GROUP BY MONTH(NGHD),
					MANV) a
		WHERE A.RN = 1