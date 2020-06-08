--1
create function tong (@a int, @b int)
returns int
as
begin 
	declare @kq int
	set @kq = @a + @b
	return @kq
end

select dbo.tong(4,6) as Tong

drop function dbo.tong

--2
create function tinhTongSoTiet ()
returns @bang table (MSMH char(8),TenMH char(30),SoTiet_LT int, SoTiet_TH int, TongSoTiet int)
as
begin
	insert into @bang
	select MAMH, TENMH, SOTIET_LT, SOTIET_TH, (select dbo.tong(SOTIET_LT, SOTIET_TH))
	from MONHOC
	return
end

select * 
from tinhTongSoTiet ()

drop function tinhTongSoTiet 

--3
create function showSVDKMH()
returns @bang table (MaMH char(8),TenMH char(30),NamHoc int, HocKy int, Dot int, SoLuong int)
as
begin
	insert into @bang
	select MONHOC.MAMH,MONHOC.TENMH,PHIEUDANGKY_DIEM.NAMHOC,PHIEUDANGKY_DIEM.HOCKY,PHIEUDANGKY_DIEM.DOTDK,Count(MASV)
	from MONHOC left join PHIEUDANGKY_DIEM on MONHOC.MAMH = PHIEUDANGKY_DIEM.MAMH
	group by MONHOC.MAMH,MONHOC.TENMH,PHIEUDANGKY_DIEM.NAMHOC,PHIEUDANGKY_DIEM.HOCKY,PHIEUDANGKY_DIEM.DOTDK
	return
end

select *
from showSVDKMH()

drop function showSVDKMH

select *
from PHIEUDANGKY_DIEM
where MAMH = 'MAV'
