--1a
create function sfunc1 (@a int,@b int, @c int)
returns int 
as
begin
	declare @max int
	set @max= @a
	if @max < @b set @max = @b
	if @max < @c set @max = @c
	return @max
end

select dbo.sfunc1(5,3,8)

--1b
create function ifunc2 (@thang int)
returns table
as
	return (select * from BangLuong where month(BangLuong.NgayTinhLuong)=@thang)

select * from ifunc2(1)

--1c
create function dbo.m_func3()
returns @danhsach table (MaPhongBang varchar(10), sonv int)
as
begin
	Insert into @danhsach
	select NhanVien.MaPhongBan, count(NhanVien.MaNhanVien)
	from NhanVien 
	group by NhanVien.MaPhongBan
	return
end

select * from dbo.m_func3()

--2a
create function TinhTong (@a int, @b int)
returns int
as
begin
	Declare @kq int
	set @kq = @a+@b
	return @kq
end

select dbo.TinhTong (3,4)

--2b
alter function GiaiPTBac1 (@a int, @b int)
returns nchar(15)
as
begin 
	declare @kq nchar(15)
	if @a=0
		set @kq = N'PT vô nghiệm'
	if @a=0 and @b=0
		set @kq = N'PT vô số nghiệm'
	else
		set @kq = convert(nchar(15),-@b/@a)
	return @kq
end

select dbo.GiaiPTBac1(1,1)

--2c
alter function TinhTuoi(@ngaysinh datetime)
returns int
as
begin
	declare @kq int
	declare @namhientai int 
	set @namhientai = YEAR(GETDATE())
	set @kq = @namhientai- Year(@ngaysinh)
	return @kq
end

select dbo.TinhTuoi('11/23/1999') as Tuoi

--2d
create proc TinhTuoi_NV
as
begin 
	select MaNhanVien,TenNhanVien, (Select dbo.TinhTuoi(NgaySinh)) as Tuoi from NhanVien
end

exec TinhTuoi_NV

--3a
create function TinhTuoiNV ()
returns table
as
return (
	select MaNhanVien,TenNhanVien, (Select dbo.TinhTuoi(NgaySinh)) as Tuoi
	from NhanVien
)

select * from TinhTuoiNV()

--3b
create function TongTamUng()
returns table 
as
return (
	select NhanVien.MaNhanVien,NhanVien.TenNhanVien,sum(BangLuong.TienTamUng) as TamUng
	from BangLuong inner join NhanVien on BangLuong.MaNhanVien=NhanVien.MaNhanVien
	group by NhanVien.MaNhanVien,NhanVien.TenNhanVien
)

select * from TongTamUng()

--3c
create function TongTamUng_Thang(@thang int)
returns table 
as
return (
	select NhanVien.MaNhanVien,NhanVien.TenNhanVien,sum(BangLuong.TienTamUng) as TamUng
	from BangLuong inner join NhanVien on BangLuong.MaNhanVien=NhanVien.MaNhanVien
	where MONTH(NgayMuon) = @thang
	group by NhanVien.MaNhanVien,NhanVien.TenNhanVien
)

select * from TongTamUng_Thang(1)

--4a
create function BangTongCong()
returns @BangTongCong table (MaNV nvarchar(50),TenNV nvarchar(30),TongNgayCong int)
as
begin 
	insert into @BangTongCong
	select NhanVien.MaNhanVien,NhanVien.TenNhanVien, sum(BangLuong.SoNgayCong)
	from NhanVien inner join BangLuong on BangLuong.MaNhanVien= NhanVien.MaNhanVien
	group by NhanVien.MaNhanVien,NhanVien.TenNhanVien
	return 
end 

select * from BangTongCong()

--4b
alter function BangLuong_Thang(@thang int)
returns @BangThang table (MaNV nvarchar(50),TenNV nvarchar(30), NgayThang datetime,Luong int)
as
begin 
	insert into @BangThang
	select NhanVien.MaNhanVien,NhanVien.TenNhanVien, BangLuong.NgayTinhLuong, NhanVien.LuongCoBan
	from NhanVien inner join BangLuong on BangLuong.MaNhanVien= NhanVien.MaNhanVien
	where month(BangLuong.NgayTinhLuong) = @thang
	group by NhanVien.MaNhanVien,NhanVien.TenNhanVien, BangLuong.NgayTinhLuong, NhanVien.LuongCoBan
	return 
end 

Select * from BangLuong_Thang(2)

--5
create function Tinh(@luong int, @TamUng int ,@ngaycong int, @hoantra int)
returns int 
as 
begin 
	declare @tra int 
	set @tra = (@luong*@ngaycong)/24 - @TamUng + @hoantra
	return @tra
end

create function BnagLuongThang(@thang int)
returns @BangLuong table (MaNV char(5), TenNV nchar(30),NgayThang datetime,Luong int)
as
begin 
	Insert into @BangLuong
	Select NhanVien.MaNhanVien,NhanVien.TenNhanVien, BangLuong.NgayTinhLuong, (select dbo.Tinh(NhanVien.LuongCoBan,BangLuong.TienTamUng,BangLuong.SoNgayCong,BangLuong.TienHoanTra))
	from NhanVien inner join BangLuong on BangLuong.MaNhanVien= NhanVien.MaNhanVien
	where  month(BangLuong.NgayTinhLuong) = @thang
	group by NhanVien.MaNhanVien,NhanVien.TenNhanVien, BangLuong.NgayTinhLuong, NhanVien.LuongCoBan,BangLuong.TienTamUng,BangLuong.SoNgayCong,BangLuong.TienHoanTra
	return
end

select * from BnagLuongThang(2)