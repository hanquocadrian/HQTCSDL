--Lap 6
use QuanLyLuong
--2a
create trigger trUp_PB_2a on PhongBan
for Update
as
begin
	select * from deleted
end

drop trigger trUp_PB_2a

--2b
create trigger trUp_PB_2b on PhongBan
for Update
as
begin
	Declare @mapb_new char(5), @tenpb_new varchar(50)

	select @mapb_new = MaPhongBan from inserted
	select @tenpb_new = TenPhongBan from PhongBan where MaPhongBan = @mapb_new

	select *, @tenpb_new as TenPBMoi from deleted
end

drop trigger trUp_PB_2b

--2c
create trigger trUp_PB_2c on PhongBan
for Update
as
begin
	Declare @mapb_old char(5), @tenpb_old varchar(50)

	select @mapb_old = MaPhongBan from deleted
	select @tenpb_old = TenPhongBan from PhongBan where MaPhongBan = @mapb_old

	select *, @tenpb_old as TenPBCu from deleted
end

drop trigger trUp_PB_2c

--2d
create trigger trUp_PB_2d on PhongBan
for Update
as
begin
	Declare @mapb_new char(5), @tenpb_new varchar(50)
	Declare @mapb_old char(5), @tenpb_old varchar(50)

	select @mapb_new = MaPhongBan from inserted
	select @tenpb_new = TenPhongBan from PhongBan where MaPhongBan = @mapb_new
	select @mapb_old = MaPhongBan from deleted
	select @tenpb_old = TenPhongBan from PhongBan where MaPhongBan = @mapb_old

	select *, @tenpb_new as TenPBMoi, @tenpb_old as TenPBCu from deleted
end

drop trigger trUp_PB_2d

--3
alter table PhongBan
add SoLuong int

create trigger trInsOrUpd_NV on NhanVien
after insert, delete
as
begin
	Declare @mapb char(5), @sl int
	if (Select COUNT(*) from inserted) > 0
	begin
		Select @mapb = MaPhongBan from inserted
		Select @sl = COUNT(MaNhanVien) from NhanVien where MaPhongBan = @mapb
		update PhongBan set SoLuong = @sl where MaPhongBan = @mapb
	end
	else
	begin
		Select @mapb = MaPhongBan from deleted
		Select @sl = COUNT(MaNhanVien) from NhanVien where MaPhongBan = @mapb
		update PhongBan set SoLuong = @sl where MaPhongBan = @mapb
	end
end

drop trigger trInsOrUpd_NV

--5a
create trigger trIns_PB on PhongBan
for insert
as
begin
	declare @tenPB varchar(50)
	select @tenPB = TenPhongBan from inserted
	if exists (select TenPhongBan from PhongBan where TenPhongBan = @tenPB)
	begin
		print 'Ton Tai PB nay'
	end
end

drop trigger trIns_PB

--5b
create trigger trIns_PB_5b on PhongBan
for insert
as
begin
	declare @tenPB varchar(50)
	select @tenPB = TenPhongBan from inserted
	if exists (select TenPhongBan from PhongBan where TenPhongBan = @tenPB)
	begin
		print 'Ton Tai PB nay'
		rollback
		return
	end
end

drop trigger trIns_PB_5b

--Lab 7
use QuanLyLuong

--4
alter trigger trUpd_BangLuong on BangLuong
after Update
as
begin 
	declare @thangcapnhat datetime, @songaycong int
	select @thangcapnhat = NgayTinhLuong, @songaycong = SoNgayCong from inserted
	if MONTH(@thangcapnhat) != MONTH(GETDATE())
	begin
		raiserror(N'Không cho phép Update ngày công tháng cũ đã tính lương',16,1)
		rollback
		return
	end
	if @songaycong < 0
	begin
		raiserror(N'Số Ngày Công < 0, không hợp lệ',16,1)
		rollback
		return
	end
	else
	begin
		declare @msbl int, @manv char(10), @tu money, @ht money, @lcb money, @ltl money
		select @msbl= MSBL, @manv= MaNhanVien, @tu = TienTamUng, @ht = TienHoanTra from inserted
		select @lcb = LuongCoBan from NhanVien where MaNhanVien = @manv
		if (@lcb*@songaycong) < (@tu-@ht)
		begin
			declare @tontamung money = (@tu-@ht)-(@lcb*@songaycong)
			set @ht += (@lcb*@songaycong)
			set @tu = @tontamung
			set @ltl = 0
			update BangLuong set TienHoanTra = @ht, TienTamUng = @tu, LuongThucLanh = @ltl where MSBL = @msbl
		end
		else
		begin
			set @ltl = (@lcb*@songaycong)-(@tu-@ht)
			update BangLuong set TienHoanTra = 0, TienTamUng = 0, LuongThucLanh = @ltl where MSBL = @msbl
		end
	end
end

drop trigger trUpd_BangLuong

--5
create trigger trUpd_TinhTien on BangLuong
after update
as
begin
	declare @ht money, @msbl int
	select @ht = TienHoanTra, @msbl = MSBL from inserted
	if @ht <=0 
	begin
		raiserror('So tien khong hop le',16,1)
		rollback
		return
	end
	else
	begin
		if cast(cast(@ht/1000 as int)*1000 as float) < 1000
		begin
			raiserror('So tien khong hop le',16,1)
			rollback
			return
		end
		else
		begin 
			update BangLuong set TienTamUng = TienTamUng - @ht where MSBL = @msbl
			update BangLuong set TienHoanTra = TienHoanTra + @ht where MSBL = @msbl
		end
	end
end

drop trigger trUpd_TinhTien

--6
create trigger trDel_NhanVien on NhanVien
instead of Delete
as
begin 
	declare @manv char(10)
	select @manv = MaNhanVien from inserted
	if not exists (select * from NhanVien where MaNhanVien = @manv)
	begin
		raiserror('Ma NV khong ton tai trong ds',16,1)
		rollback
		return
	end
	else
	begin
		if exists (select MaNhanVien from BangLuong where MaNhanVien = @manv)
		begin
			raiserror('Ma NV ton tai trong bang luong',16,1)
			rollback
			return
		end
		else
		begin 
			delete NhanVien where MaNhanVien = @manv
		end
	end
end

drop trigger trDel_NhanVien

--7
create trigger trUpd_LCB_NhanVien on NhanVien
after update
as
begin
	declare @lcbold money, @lcbnew money, @manv char(10)
	select @lcbold = LuongCoBan from deleted
	select @lcbnew = LuongCoBan, @manv = MaNhanVien from inserted
	if @lcbold > @lcbnew
		print N'LCB mới thấp hơn LCB cũ'
	if @lcbold < @lcbnew
		print N'LCB mới lớn hơn LCB cũ'
	else 
		print N'LCB mới bằng LCB cũ'
	if @lcbnew != @lcbold
	begin
		declare @msbl int, @tu money, @ht money, @snc int, @ltl money
		select @msbl= MSBL, @snc = SoNgayCong, @tu = TienTamUng, @ht = TienHoanTra from BangLuong where MaNhanVien = @manv and MONTH(GETDATE()) = MONTH(NgayTinhLuong)
		if (@lcbnew*@snc) < (@tu-@ht)
		begin
			declare @tontamung money = (@tu-@ht)-(@lcbnew*@snc)
			set @ht += (@lcbnew*@snc)
			set @tu = @tontamung
			set @ltl = 0
			update BangLuong set TienHoanTra = @ht, TienTamUng = @tu, LuongThucLanh = @ltl where MSBL = @msbl
		end
		else
		begin
			set @ltl = (@lcbnew*@snc)-(@tu-@ht)
			update BangLuong set TienHoanTra = 0, TienTamUng = 0, LuongThucLanh = @ltl where MSBL = @msbl
		end
	end
end

drop trigger trUpd_LCB_NhanVien

--IV.1
use QuanLyLuong
go

alter trigger trDel_PB on PhongBan
instead of delete
as
begin
	declare @mapb varchar(50)
	select @mapb = MaPhongBan from deleted
	if exists (select MaPhongBan from PhongBan where MaPhongBan = @mapb)
	begin
		declare @countnv int
		select @countnv = COUNT(MaNhanVien) from NhanVien where MaPhongBan = @mapb
		if @countnv = 0
		-- PB Ko có NV
		begin 
			delete from PhongBan where MaPhongBan = @mapb
			print 'Da xoa thanh cong PB khong co NV, sl NV:' + convert(varchar(10),@countnv)
			return
		end
		else
		begin
			-- PB có NV
			-- Xóa NV trc nếu có Lương -> rollback
			declare curlistNV cursor
			for select MaNhanVien from NhanVien where MaPhongBan = @mapb
			open curlistNV
			declare @manv varchar(50)
			fetch next from curlistNV into @manv
			while @@FETCH_STATUS = 0
			begin
				if not exists (select MaNhanVien from BangLuong where MaNhanVien = @manv)
				begin
					delete from NhanVien where MaNhanVien = @manv
				end
				else
				begin
					raiserror('Ko the xoa PB nay, vi ton tai NV co Bang Luong',16,1)
					rollback tran
					return
				end
				fetch next from curlistNV into @manv
			end
			close curlistNV
			deallocate curlistNV

			-- Xóa xong NV -> Xóa PB
			delete from PhongBan where MaPhongBan = @mapb
			print 'Da xoa thanh cong PB co NV nhung NV ko co Bang Luong'
			return
		end
	end
	else
	begin
		raiserror('Khong ton tai phong ban nay',16,1)
		return
	end
end

drop trigger trDel_PB

delete from PhongBan where MaPhongBan = 'PB4'

insert into PhongBan(MaPhongBan) values('PB4')
insert into NhanVien(MaNhanVien,MaPhongBan) values('NV11','PB4')
insert into NhanVien(MaNhanVien,MaPhongBan) values('NV111','PB4')
insert into BangLuong(MSBL,MaNhanVien) values(15,'NV111')

select *
from PhongBan
select *
from NhanVien
select *
from BangLuong

--IV.2
create trigger trUpd_TD on TrinhDo
instead of update
as
begin
	declare @lcb money, @matd char(5)
	select @lcb = LuongCB, @matd = MaTD from inserted
	
	if @lcb < 0
	begin
		raiserror('CLB trong TD kkhong the am',16,1)
		return
	end
	else
	begin
		if cast(cast(@lcb/1000 as int)*1000 as float) < 1000
		begin
			raiserror('Nhap sai kq',16,1)
			return			
		end
		else
		begin
			--Sua LCB tai Table NV nhờ MSNV
			declare curlistLCB_NV cursor
			for select MaNhanVien from NhanVien where MaTD = @matd
			open curlistLCB_NV
			declare @manv int
			fetch next from curlistLCB_NV into @manv
			while @@FETCH_STATUS = 0
			begin
				update NhanVien set LuongCoBan = @lcb where MaNhanVien = @manv
				
				--Sua LCB tai BangLuong nhờ MSBL Lấy Từ MSNV
				declare curlistTL_BL cursor
				for select MSBL,SoNgayCong,TienTamUng,TienHoanTra from BangLuong where MaNhanVien = @manv
				open curlistNV
				declare @msbl int, @snc int, @tu money, @ht money
				fetch next from curlistBL into @msbl, @snc, @tu, @ht 
				while @@FETCH_STATUS = 0
				begin
					update BangLuong set LuongThucLanh = (@lcb * @snc)/24-@tu+@ht where MSBL = @msbl 
					fetch next from curlistBL into @msbl, @snc, @tu, @ht 
				end
				close curlistNV
				deallocate curlistNV	

				fetch next from curlistLCB_NV into @manv
			end
			close curlistLCB_NV
			deallocate curlistLCB_NV

		end
	end
end

drop trigger trUpd_TD 