--1
create proc Sp_ThemMH
	@mamh char(8), @tenmh varchar(30), @stlt int, @stth int
as
begin
	if exists(select mamh from MONHOC where MAMH = @mamh)
	begin 
		print N'MAMH: '+@mamh+N' đã tồn tại'
		return -1
	end
	else
	begin
		insert into MONHOC (MAMH,TENMH,SOTIET_LT,SOTIET_TH)
		values (@mamh, @tenmh, @stlt, @stth)
	end
end
 
exec Sp_ThemMH 'MH10','TLLT',15,30

--2
create proc Sp_SuaDiem
	@masv char(8), @mamh char(8), @lan int, @diemsua float
as
begin
	if exists(select * from DIEM where MASV = @masv and MAMH = @mamh and LAN = @lan)
	begin
		update DIEM set DIEM = @diemsua where  MASV = @masv and MAMH = @mamh and LAN = @lan
		print N'Sửa điểm thành công'
	end
	else
	begin
		print N'MASV va MAMH không tồn tại'
		return -1
	end
end

exec Sp_SuaDiem 'SV1','MAV',1,6.0
select * from DIEM where MASV ='SV1'

--3
create proc Sp_XuatSiSo
as
begin
	select LOP.MALOP, LOP.TENLOP, COUNT(SINHVIEN.MASV) as SiSo
	from SINHVIEN inner join LOP on SINHVIEN.MALOP = LOP.MALOP
	group by LOP.MALOP, LOP.TENLOP
end

exec Sp_XuatSiSo

--4
alter proc Sp_XuatLop
as
begin
	select LOP.MALOP, LOP.TENLOP
	from SINHVIEN right join LOP on SINHVIEN.MALOP = LOP.MALOP
	group by LOP.MALOP, LOP.TENLOP
	HAVING COUNT(SINHVIEN.MASV) = 0
end

exec Sp_XuatLop
Select * from LOP

--5
alter proc Sp_ThongKe
as
begin
	select LOP.MALOP, LOP.TENLOP, Sum(Case when SINHVIEN.PHAI = 'nam' then 1 else 0 end)'So Nam',
	Sum(Case when SINHVIEN.PHAI = 'nu' then 1 else 0 end)'So Nu'
	from SINHVIEN inner join LOP on SINHVIEN.MALOP = LOP.MALOP
	group by LOP.MALOP, LOP.TENLOP
	order by LOP.MALOP
end

exec Sp_ThongKe