create database TaiChinh
go
use TaiChinh
go

--1
create table PhieuThu(
	MSPT char(5) primary key,
	NgayThu date,
	SoTien int
)
create table PhieuChi(
	MSPC char(5) primary key,
	NgayChi date,
	SoTien int
)
insert into PhieuThu values ('T01','01-06-2020',200)
insert into PhieuThu values ('T02','01-06-2020',100)
insert into PhieuThu values ('T03','02-06-2020',400)
insert into PhieuThu values ('T04','02-06-2020',100)

insert into PhieuChi values ('C01','01-06-2020',100)
insert into PhieuChi values ('C02','01-06-2020',50)
insert into PhieuChi values ('C03','03-06-2020',200)
insert into PhieuChi values ('C04','03-06-2020',250)

select *
from PhieuChi

select *
from PhieuThu

create view TempTongHop
as
select NgayThu as Ngay, sum(PhieuThu.SoTien) as TongThu, TongChi = 0
from PhieuThu
group by NgayThu
union 
select NgayChi as Ngay, TongChi = 0, sum(PhieuChi.SoTien) as TongChi
from PhieuChi
group by NgayChi

create view TongHop
as
select Ngay, Sum(TongThu) as TongThu,Sum(TongChi) as TongChi
from TempTongHop
group by Ngay

select *
from TongHop

--2
create proc Baocaoquy
as
begin 
	print 'Ngay: ' + space(6) + ' | ' + 'TonDauNgay' + ' | ' + 'TongThu' + ' | ' + 'TongChi' + ' | ' + 'TonCuoiNgay'
	
	declare curbaocaongay cursor
	for select * from TongHop
	open curbaocaongay
	
	declare @ngay date, @tongthu int, @tongchi int,@tondaungay int,@toncuoingay int
	
	fetch next from curbaocaongay into @ngay,@tongthu,@tongchi
	while @@FETCH_STATUS = 0
	begin
		--print 'Ngay: ' + convert(char(12),@ngay) + ' Tong Thu: ' + convert(char(6),@tongthu) + ' Tong Chi: ' + convert(char(6),@tongchi)
		if @ngay = '01-06-2020'
			set @tondaungay = 250
		else
			set @tondaungay = @toncuoingay
		set @toncuoingay = @tondaungay + @tongthu - @tongchi

		print convert(char(12),@ngay) + ' | ' +  convert(char(10),@tondaungay) + 
		' | ' +  convert(char(7),@tongthu) + ' | ' + convert(char(7),@tongchi) + 
		' | ' + convert(char(7),@toncuoingay)
		fetch next from curbaocaongay into @ngay,@tongthu,@tongchi
	end

	close curbaocaongay
	deallocate curbaocaongay
end
