use QLKDHH
go

create table HangHoa(
	MSHH char(5) primary key,
	TenHH nchar(20),

	TonKho int 
)

create table PhieuNhap(
	MSPN char(5) primary key,
	NgayNhap date,

	TriGiaPN int
)

create table ChiTietPhieuNhap(
	MSPN char(5) CONSTRAINT FK_CTPN_PN FOREIGN KEY(MSPN) REFERENCES PhieuNhap(MSPN),
	MSHH char(5) CONSTRAINT FK_CTPN_HH FOREIGN KEY(MSHH) REFERENCES HangHoa(MSHH),
	SoLuong int,
	DonGia int,

	ThanhTien int
)

create table KhachHang(
	MSKH char(5) primary key,
	TenKH nchar(30),

	CongNo int
)

create table HoaDon(
	MSHD char(5) primary key,
	NgayHD date,

	TriGiaHD int
)

create table ChiTietHoaDon(
	MSKH char(5) CONSTRAINT FK_CTHD_KH FOREIGN KEY(MSKH) REFERENCES KhachHang(MSKH),
	MSHD char(5) CONSTRAINT FK_CTHD_HD FOREIGN KEY(MSHD) REFERENCES HoaDon(MSHD),
	SoLuong int,
	DonGia int,

	ThanhTien int
)

create table PhieuThu(
	MSPT char(5) primary key,
	NgayThu date,
	MSKH char(5) CONSTRAINT FK_PT_KH FOREIGN KEY(MSKH) REFERENCES KhachHang(MSKH),
	SoTien int
)

--
insert into HangHoa values ('H01',N'Bánh',0)
insert into HangHoa values ('H02',N'Kẹo',0)
insert into HangHoa values ('H03',N'Sữa',0)


insert into KhachHang values ('K01',N'Lê Minh',0)
insert into KhachHang values ('K02',N'Nguyễn Thị Mai',0)
insert into KhachHang values ('K03',N'Trần Văn Hùng',0)

--
create trigger trInCTPN
on ChiTietPhieuNhap 
for insert
as
declare @sl int, @dg int ,@mspn char(5),@mshh char(5),@tongthanhTien int = 0
begin
	select @sl = SoLuong, @dg = DonGia, @mspn = MSPN, @mshh= MSHH from inserted
	update ChiTietPhieuNhap set ThanhTien = @sl * @dg where MSPN = @mspn and MSHH = @mshh
	
	select @tongthanhTien = sum(ThanhTien) 
	from ChiTietPhieuNhap 
	where MSPN = @mspn
	group by MSPN
	update PhieuNhap set TriGiaPN = @tongthanhTien where MSPN = @mspn

	update HangHoa set TonKho = TonKho + @sl where MSHH = @mshh
end

insert into PhieuNhap values ('PN01','01/01/2020',0)
insert into PhieuNhap values ('PN02','02/01/2020',0)

insert into ChiTietPhieuNhap (MSPN,MSHH,SoLuong,DonGia) values ('PN01','H01',10,5000)
insert into ChiTietPhieuNhap (MSPN,MSHH,SoLuong,DonGia) values ('PN01','H02',5,10000)
insert into ChiTietPhieuNhap (MSPN,MSHH,SoLuong,DonGia) values ('PN02','H01',50,5000)

delete from ChiTietPhieuNhap where MSPN = 'PN01' and MSHH = 'H01'

select * from ChiTietPhieuNhap
select * from PhieuNhap
select * from HangHoa


create trigger trDeCTPN
on ChiTietPhieuNhap 
for delete
as
declare @thanhtien int, @sl int, @mspn char(5),@mshh char(5)
begin
	select @thanhtien = ThanhTien, @sl = SoLuong, @mspn = MSPN, @mshh= MSHH from deleted
	
	update PhieuNhap set TriGiaPN = TriGiaPN - @thanhtien where MSPN = @mspn

	update HangHoa set TonKho = TonKho - @sl where MSHH = @mshh
end

drop trigger trInCTPN
drop trigger trUpCTPN
drop trigger trDeCTPN

create trigger trUpCTPN
on ChiTietPhieuNhap 
for update
as
declare @thanhtiencu int, @slcu int, @mspncu char(5),@mshhcu char(5)
declare @thanhtienmoi int, @slmoi int, @dgmoi int, @mspnmoi char(5),@mshhmoi char(5)
begin
	select @slmoi = SoLuong, @dgmoi = DonGia, @mspnmoi = MSPN, @mshhmoi = MSHH from inserted
	select @thanhtiencu = ThanhTien, @slcu = SoLuong, @mspncu = MSPN, @mshhcu= MSHH from deleted

	update ChiTietPhieuNhap set ThanhTien = @slmoi * @dgmoi where MSPN = @mspnmoi and MSHH = @mshhmoi


	update PhieuNhap set TriGiaPN = TriGiaPN - @thanhtiencu where MSPN = @mspncu
	update PhieuNhap set TriGiaPN = TriGiaPN + (@slmoi * @dgmoi) where MSPN = @mspnmoi

	update HangHoa set TonKho = TonKho - @slcu where MSHH = @mshhcu
	update HangHoa set TonKho = TonKho + @slmoi where MSHH = @mshhmoi
end

update ChiTietPhieuNhap set SoLuong = 20 where MSPN = 'PN01' and MSHH = 'H01'