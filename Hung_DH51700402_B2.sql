--QLSV
--1a
create procedure spChuoi
AS
BEGIN 
	print N'Dai Hoc CNSG'
END

Execute spChuoi

--1b
create procedure spDSSV
As
Begin 
	select * from SINHVIEN
End

exec spDSSV

--1c
Create proc SpDIEMSV
AS
BEGIN 
	SELECT * FROM SINHVIEN inner join DIEM on SINHVIEN.MASV=DIEM.MASV AND SINHVIEN.MASV = 'SV1'
END

EXEC SpDIEMSV

--2A
CREATE PROCEDURE SpCHUOI2 @khoa char(50), @chuoi char(100) output
as
begin 
	Set @chuoi = 'DHCNSG'+ @khoa
end

declare @chuoi char(100)
exec SpCHUOI2 'Khoa CNTT',@chuoi output
print @chuoi 

--2B
Create proc SpTB @a int, @b int, @c int, @TB float output
As
Begin 
	Set @TB = (@a+@b+@c)/3.0
	print N'Trung binh: '+ convert(nvarchar(50),@TB)
End

Declare @TB float
exec SpTB 2,8,4,@TB output
print @TB

--2C
create procedure SpThemSV @masv char(8), @ho varchar(40), @ten varchar(10), @ngaysinh smalldatetime, @phai char(3), @malop char(8)
as
begin
	insert into SINHVIEN (MASV,HO,TEN,NGAYSINH,PHAI,MALOP)
	values(@masv, @ho, @ten, @ngaysinh, @phai, @malop)
end

exec SpThemSV 'SV20','TRAN VAN','LONG','4/10/1985','nam','MMT2'

--2d
create proc SpXoaLop @malop char(8)
as
begin 
	if exists(select malop from LOP where malop=@malop)
	begin
		if exists(select s.malop from SINHVIEN as s, LOP as l where l.MALOP=s.MALOP and s.MALOP=@malop)
		begin
			print N'Không thể xóa vì tồn tại khóa ngoại trong SV'
			return 0
		end
		else
			delete from LOP where MALOP=@malop
			print N'Đã xóa '+ @malop
	end
	else
	begin
		print N'Không có tên mã lớp '+ @malop
		return 0
	end
end

Select * from SINHVIEN where MALOP = 'HTTT4'
exec SpXoaLop 'HTTT4'

--3a
create proc SpTongDay @n int, @sum int output
as
begin 
	DECLARE @i int
	set @i = 1 
	set @sum = 0
	While @i <= @n
	begin 
		set @sum += @i
		set @i += 1
	end
end

Declare @s int 
exec SpTongDay 3, @s output
print @sum

--3b
create proc SpNhapDiem @masv char(8),@mamh char(8),@lan int, @hocky int, @diem float
as
begin 
	if exists(select masv from SINHVIEN where MASV=@masv) and exists(select mamh from MONHOC where MAMH=@mamh)
	begin 
		Insert into Diem(masv,mamh,lan,hocky,diem)
		values(@masv,@mamh,@lan, @hocky, @diem)
	end
	else
		print 'Them diem khong thanh cong'
		return 0
end


exec SpNhapDiem'SV7','THHM',1,2,7

--3c
Create proc SpDiemLop @malop char(8)
as
begin
	if exists(Select MALOP from LOP where MALOP = @malop)
	begin 
		select SINHVIEN.MALOP, SINHVIEN.MASV, SINHVIEN.HO, SINHVIEN.TEN, DIEM.MAMH,  DIEM.LAN, DIEM.HOCKY, DIEM.DIEM 
		from SINHVIEN left join DIEM on SINHVIEN.MASV=DIEM.MASV
		where SINHVIEN.MALOP=@malop
	end
	else
		print 'Khong ton tai lop: '+@malop
		return 0		
end

exec SpDiemLop 'MMT2'

--4
Create proc SpSuaMaSV @masv_old char(8), @masv_new char(8)
as
begin 
	if exists(Select masv from SINHVIEN where MASV=@masv_old)
	begin
		--copy thằng sv vào temp1
		select * into Temp_SV from SINHVIEN where MASV = @masv_old
		if exists(Select masv from DIEM where MASV=@masv_old)
		begin
			select * into Temp_Diem from DIEM where MASV = @masv_old
			delete from SINHVIEN where MASV=@masv_old
			delete from DIEM where MASV=@masv_old
			Update Temp_Diem set MASV = @masv_new
			Update Temp_SV set MASV = @masv_new
			Insert into SINHVIEN Select * from Temp_SV
			Insert into DIEM Select * from Temp_Diem
			Drop table Temp_SV
			Drop table Temp_Diem
		end
		else
		begin
			delete from SINHVIEN where MASV=@masv_old
			Update Temp_SV set MASV = @masv_new
			Insert into SINHVIEN Select * from Temp_SV
			Drop table Temp_SV
		end
	end
	else
		print 'Khong ton tai masv: '+@masv_old
		return 0	
end

--5a
create proc SpCheckSNT @n int, @r int out
as 
begin 
	declare @count int
	declare @i int
	set @count = 0
	set @i = 1
	while @i <= @n
	begin
		if @n % @i = 0
			set @count = @count + 1
		set @i = @i + 1
	end
	if @count = 2
		set @r = 1
	else
		set @r = 0
end

create proc SpSoNguyenTo @n int
as
begin
	declare @i int = 1
	print 'Cac SNT tu 1 den '+ Convert(char(10),@n)
	while @i <= @n
	begin
		declare @check int
		exec SpCheckSNT @i,@check out 
		if @check = 1
			print @i
		set @i = @i+1
	end
end

exec SpSoNguyenTo 10

--5b
create proc SpTenMon1
as
begin
	SELECT MAMH, 
		iif(MAMH = 'MAV','Anh Van',
			iif (MAMH = 'MKTCT','Kinh Te Chinh Tri',
				iif (MAMH = 'MKTLT','KY THUAT LAP TRINH',
					iif (MAMH = 'ML', 'LY',
						iif (MAMH = 'MMMT', 'MANG MAY TINH',
							iif (MAMH = 'MT','Toan','TIN HOC DAI CUONG')
						)	
					)
				)
			)
		) AS TenMonHoc
	FROM MONHOC
end

exec SpTenMon1

--5c
alter proc SpTenMon
as
begin
	SELECT MAMH, 
		(CASE
			WHEN MAMH = 'MAV' THEN 'Anh Van'
			WHEN MAMH = 'MKTCT' THEN 'Kinh Te Chinh Tri'
			WHEN MAMH = 'MKTLT' THEN 'KY THUAT LAP TRINH'
			WHEN MAMH = 'ML' THEN 'LY'
			WHEN MAMH = 'MMMT' THEN 'MANG MAY TINH'
			WHEN MAMH = 'MT' THEN 'Toan'
			ELSE 'TIN HOC DAI CUONG'
		 END) AS TenMonHoc
	FROM MONHOC
end

exec SpTenMon

--6
create proc SpSuaMaMonHoc @mamh_old char(8), @mamh_new char(8)
as
begin 
	if exists(select MAMH from MONHOC where MAMH=@mamh_old)
	begin
		select * into Temp_MH from MONHOC where MAMH=@mamh_old
		if exists(select MAMH from DIEM where MAMH=@mamh_old)
		begin
			select * into Temp_D from DIEM where MAMH=@mamh_old

			delete from MONHOC where MAMH=@mamh_old
			delete from DIEM where MAMH=@mamh_old
			update Temp_D set MAMH = @mamh_new
			update Temp_MH set MAMH = @mamh_new
			Insert into MONHOC Select * from Temp_MH
			Insert into DIEM Select * from Temp_MH
			Drop table Temp_MH
			Drop table Temp_D
		end
		else
		begin
			delete from MONHOC where MAMH=@mamh_old
			update Temp_MH set MAMH = @mamh_new
			Insert into MONHOC Select * from Temp_MH
			Drop table Temp_MH
		end
	end
	else
		print 'Khong ton tai masv: '+@mamh_old
		return 0
end

