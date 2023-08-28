-- ***********************************
-- SQL ADVANCED 1
-- ***********************************
	USE [QLHD]
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
	GO
---------------------------------------------------------------------------
-- TASK 1.	Create Procedure get sales by day
-- TẠO THỦ TỤC LẤY RA TÊN NHÂN VIÊN CÓ DOANH SỐ CAO NHẤT THEO NGÀY ?
--------------------------------------------------------------------------
	--// Start create procedure
	CREATE PROCEDURE GET_TOP1_SALE_BY_DAY @CHECKDAY DATE AS BEGIN
	-- query to get result
	SELECT TOP 1 a.HOTEN,
			   SUM(b.TRIGIA) AS DOANHSONV
	FROM NHANVIEN a
	LEFT JOIN HOADON b ON a.MANV=b.MANV
	WHERE CONVERT(DATE,b.NGHD)= @CHECKDAY
	GROUP BY a.HOTEN
	ORDER BY DOANHSONV DESC 
	END
	--// End
	GO

	EXEC GET_TOP1_SALE_BY_DAY '20061028'
	-- DROP PROCEDURE GET_TOP1_SALE_BY_DAY
	GO
--------------------------------------------------------------------------------------------------
-- TASK 2. Create Procedure get sales by CustomerID and month 
-- TẠO THỦ TỤC THỐNG KÊ DOANH SỐ BÁN HÀNG TRONG THÁNG THEO MAKH TẠI NGÀY CUỐI CÙNG CỦA THÁNG.
--------------------------------------------------------------------------------------------------
 --TRONG ĐÓ PHAN LOAI KH NEW VÀ KH OLD TRONG NĂM 2006. 
-- BIẾT RẰNG NGAYDK <= NGAYHD, KH MỚI LÀ KH CÓ LỊCH SỬ MUA HÀNG LẦN ĐẦU TIÊN

	CREATE TABLE BANGPHANLOAIKH 
	(
		MAKH VARCHAR(4),
		PHANLOAIKH VARCHAR(50)
	)
	GO

	--// Start create procedure
	CREATE PROCEDURE THONGKE_DOANHSO_KH_BY_MONTH @NGAYCUOITHANG DATE AS
	-- first delete all record from BANGPHANLOAIKH
	DELETE BANGPHANLOAIKH
	-- insert KH NEW
	INSERT INTO BANGPHANLOAIKH(MAKH, PHANLOAIKH)
	SELECT a.MAKH,
		   'KH NEW' AS PHANLOAIKH
	FROM KHACHHANG a
	LEFT JOIN HOADON b ON a.MAKH=b.MAKH
	WHERE YEAR(b.NGHD) = 2006
	  AND a.NGDK <= b.NGHD
	GROUP BY a.MAKH
	HAVING COUNT(a.MAKH)=1
	-- insert KH OLD
	INSERT INTO BANGPHANLOAIKH(MAKH, PHANLOAIKH)
	SELECT a.MAKH,
		   'KH OLD' AS PHANLOAIKH
	FROM KHACHHANG a
	LEFT JOIN HOADON b ON a.MAKH=b.MAKH
	WHERE YEAR(b.NGHD) = 2006
	  AND a.NGDK <= b.NGHD
	GROUP BY a.MAKH
	HAVING COUNT(a.MAKH)>1
	-- query to get result
	SELECT MONTH(b.NGHD) AS THANG,
		   a.MAKH,
		   SUM(b.TRIGIA) AS DOANHSOKH,
		   a.PHANLOAIKH
	FROM BANGPHANLOAIKH a
	LEFT JOIN HOADON b ON a.MAKH = b.MAKH
	WHERE CONVERT(DATE,b.NGHD) <= @NGAYCUOITHANG
	  AND MONTH(b.NGHD) = MONTH(@NGAYCUOITHANG)
	GROUP BY MONTH(b.NGHD),
			 a.MAKH,
			 a.PHANLOAIKH
	--// End
	GO

	EXECUTE THONGKE_DOANHSO_KH_BY_MONTH '20061031'
	-- DROP PROCEDURE THONGKE_DOANHSO_KH_BY_MONTH

---------------------------------------------------------------------------
-- TASK 3: Create Procedure get Commision for Employee
-- TẠO THỦ TỤC TÍNH HOA HỒNG CHO TỪNG NHÂN VIÊN TRONG THÁNG BIẾT RẰNG COMMISION RATE NHƯ SAU:
--------------------------------------------------------------------------
-- BÁN CÁC SP TỪ 'VIET NAM'   > COMMISION RATE 10%
-- BÁN CÁC SP TỪ 'TRUNG QUOC' > COMMISION RATE 12 %
-- BÁN CÁC SP OTHER COUNTRIES > COMMISION RATE 8%
	GO
	--// Start create procedure
	CREATE PROCEDURE HOAHONG_NV_BY_MONTH @NAMTHONGKE INT AS
	SELECT MONTH(c.NGHD) AS THANG,
		   c.MANV,
		   SUM(CASE
				   WHEN NUOCSX ='VIET NAM' THEN 0.01*SL*GIA
				   WHEN NUOCSX ='TRUNG QUOC' THEN 0.012*SL*GIA
				   ELSE 0.008*SL*GIA
			   END) AS HOAHONG
	FROM CTHD a
	LEFT JOIN SANPHAM b ON b.MASP=a.MASP
	LEFT JOIN HOADON c ON c.SOHD=a.SOHD
	WHERE YEAR(c.NGHD)=@NAMTHONGKE
	GROUP BY MONTH(c.NGHD),
			 c.MANV
	ORDER BY THANG
	--// End

	EXECUTE HOAHONG_NV_BY_MONTH 2006
	-- DROP PROCEDURE HOAHONG_NV_BY_MONTH
	GO
---------------------------------------------------------------------------
-- TASK 4: Create Procedure get top 3 product
-- TẠO THỦ TỤC TINH TOP 3 SP BIẾN ĐỘNG SL MAX/MIN GIỮA CÁC NGÀY
--------------------------------------------------------------------------
	GO
	CREATE TABLE BANGKETQUA4
	(	MASP VARCHAR(4),
		BIENDONGSL INT,
		TOPMINMAX VARCHAR(50)
	)

	GO

	-- --------------------------------------------
	-- TOP 3 SP BIẾN ĐỘNG SL MIN GIỮA CÁC NGÀY
	-- --------------------------------------------
	--// Start create procedure
	CREATE PROCEDURE TOP3_SP_BIENDONGSL_MIN @NGAY1 DATE, @NGAY2 DATE AS
	DELETE BANGKETQUA4
	INSERT INTO BANGKETQUA4(MASP, BIENDONGSL, TOPMINMAX)
	SELECT TOP 3 c.MASP,
			   ABS(TONGSL2-TONGSL1) AS BIENDONGSL,
			   'TOP 3 MIN' AS TOPMINMAX
	FROM
	  (SELECT MASP,
			  SUM(SL) AS TONGSL1
	   FROM CTHD a
	   LEFT JOIN HOADON b ON a.SOHD = b.SOHD
	   WHERE CONVERT(DATE,NGHD) = @NGAY1
	   GROUP BY a.MASP) c
	INNER JOIN
	  (SELECT MASP,
			  SUM(SL) AS TONGSL2
	   FROM CTHD a
	   LEFT JOIN HOADON b ON a.SOHD = b.SOHD
	   WHERE CONVERT(DATE,NGHD) = @NGAY2
	   GROUP BY a.MASP) d ON c.MASP = d.MASP
	ORDER BY BIENDONGSL ASC
	SELECT *
	FROM BANGKETQUA4
	--// End

	GO
	EXEC TOP3_SP_BIENDONGSL_MIN '20061028', '20070113'
	-- DROP TOP3_SP_BIENDONGSL_MIN
	GO
	-- --------------------------------------------
	-- TOP 3 SP BIẾN ĐỘNG SL MAX GIỮA CÁC NGÀY
	-- --------------------------------------------
	--// Start create procedure
	CREATE PROCEDURE TOP3_SP_BIENDONGSL_MAX @NGAY1 DATE, @NGAY2 DATE AS
	DELETE BANGKETQUA4
	INSERT INTO BANGKETQUA4(MASP, BIENDONGSL, TOPMINMAX)
	SELECT TOP 3 c.MASP,
			   ABS(TONGSL2-TONGSL1) AS BIENDONGSL,
			   'TOP 3 MAX' AS TOPMINMAX
	FROM
	  (SELECT MASP,
			  SUM(SL) AS TONGSL1
	   FROM CTHD a
	   LEFT JOIN HOADON b ON a.SOHD = b.SOHD
	   WHERE CONVERT(DATE,NGHD) = @NGAY1
	   GROUP BY a.MASP) c
	INNER JOIN
	  (SELECT MASP,
			  SUM(SL) AS TONGSL2
	   FROM CTHD a
	   LEFT JOIN HOADON b ON a.SOHD = b.SOHD
	   WHERE CONVERT(DATE,NGHD) = @NGAY2
	   GROUP BY a.MASP) d ON c.MASP = d.MASP
	ORDER BY BIENDONGSL DESC
	SELECT *
	FROM BANGKETQUA4
	--// End

	GO

	EXEC TOP3_SP_BIENDONGSL_MAX '20061028', '20070113'
	-- DROP TOP3_SP_BIENDONGSL_MAX
	GO
