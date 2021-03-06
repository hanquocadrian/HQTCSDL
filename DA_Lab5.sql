use QuanLyLuong
go
--Example1
declare cursorNhanVien scroll cursor
for select * from NhanVien
open cursorNhanVien
while @@FETCH_STATUS=0
begin
	fetch next from cursorNhanVien
	--fetch prior from cursorNhanVien
end
close cursorNhanVien
deallocate cursorNhanVien
go
--Example2
declare cursorNhanVien2 scroll cursor
for select * from NhanVien
open cursorNhanVien2
while @@FETCH_STATUS=0
begin
	fetch next from cursorNhanVien2
	fetch prior from cursorNhanVien2
	fetch last from cursorNhanVien2
	fetch absolute 7 from cursorNhanVien2
	fetch absolute 10 from cursorNhanVien2
	fetch relative -3 from cursorNhanVien2
end
close cursorNhanVien2
deallocate cursorNhanVien2
go
--Example3
declare cursorNhanVien3 scroll cursor
for select * from NhanVien
open cursorNhanVien3
fetch next from cursorNhanVien3
while @@FETCH_STATUS=0
begin
	fetch next from cursorNhanVien3
end
close cursorNhanVien3
deallocate cursorNhanVien3
go
--Example4
declare cursorNhanVien4a scroll cursor
for select MaNhanVien, TenNhanVien, SDT from NhanVien
open cursorNhanVien4a
declare @MaNhanVien char(5),@TenNhanVien nvarchar(30), @SDT char(20)
fetch next from cursorNhanVien4a into @MaNhanVien, @TenNhanVien, @SDT
while @@FETCH_STATUS=0
begin
	print @MaNhanVien+' : '+@TenNhanVien+' : '+@SDT
	fetch next from cursorNhanVien4a into @MaNhanVien, @TenNhanVien, @SDT
end
close cursorNhanVien4a
deallocate cursorNhanVien4a
go
--Example5
declare curListPBa scroll cursor
for select MaPhongBan, TenPhongBan from PhongBan
open curListPBa
declare @MaPhongBan char(5),@TenPhongBan nvarchar(30)
fetch next from curListPBa into @MaPhongBan, @TenPhongBan
while @@FETCH_STATUS=0
begin
	--update PhongBan set MaTruongPhong=@MaPhongBan+MaTruongPhong
	update NhanVien set MaNhanVien=@MaPhongBan+MaNhanVien
	
	--MaNhanVien would be truncated because type of MaNhanVien is only char(5)
	where MaPhongBan=@MaPhongBan
	fetch next from curListPBa into @MaPhongBan, @TenPhongBan
end
close curListPBa
deallocate curListPBa
go
--Bài 1:
--Cau a
declare cur1a cursor
for select*from NhanVien
open cur1a
fetch next from cur1a
close cur1a
deallocate cur1a
go
--Cau b
declare cur1b scroll cursor
for select*from NhanVien
open cur1b
fetch last from cur1b
fetch prior from cur1b
fetch absolute 5 from cur1b
fetch absolute 4 from cur1b
fetch relative -2 from cur1b
close cur1b
deallocate cur1b
go
--Cau c
declare cur1c scroll cursor
for select*from NhanVien
open cur1c
fetch prior from cur1c
fetch last from cur1c
fetch absolute -2 from cur1c
fetch absolute -5 from cur1c
fetch relative 2 from cur1c
close cur1c
deallocate cur1c
go
--Bài 2:
--Cau a
declare cur2a scroll cursor
for select NhanVien.*
from NhanVien inner join PhongBan on NhanVien.MaPhongBan=PhongBan.MaPhongBan
where PhongBan.TenPhongBan=N'Đào Tạo'
open cur2a
fetch next from cur2a
while @@FETCH_STATUS=0
begin
	fetch next from cur2a
end
close cur2a
deallocate cur2a
go
--Cau b
declare cur2b scroll cursor
for select MaNhanVien, TenNhanVien, Luong from NhanVien
open cur2b
declare @MaNhanVien char(5),@TenNhanVien nvarchar(30), @Luong varchar(20)
fetch next from cur2b into @MaNhanVien, @TenNhanVien, @Luong
while @@FETCH_STATUS=0
begin
	print @MaNhanVien+' : '+@TenNhanVien+' : '+convert(varchar(20),@Luong)
	--Result of @Luong: 3e+006
	--How to convert float to varchar or char to print?
	fetch next from cur2b into @MaNhanVien, @TenNhanVien, @Luong
end
close cur2b
deallocate cur2b
go
--Bài 3:
--Cau a
declare cur3a scroll cursor
for select MaNhanVien from NhanVien
open cur3a
declare @MaNhanVien char(15)
fetch next from cur3a into @MaNhanVien
while @@FETCH_STATUS=0
begin
	update NhanVien set SDT='083'+SDT
	where MaNhanVien=@MaNhanVien
	fetch next from cur3a into @MaNhanVien
end
close cur3a
deallocate cur3a
go
--Cau b
declare cur3b scroll cursor
for select MaNhanVien, MaTD from NhanVien
open cur3b
declare @MaNhanVien char(15),@MaTD char(5)
fetch next from cur3b into @MaNhanVien, @MaTD
while @@FETCH_STATUS=0
begin
	if @MaTD='CD'
		update NhanVien set Luong=Luong/1.2
		where MaTD=@MaTD and MaNhanVien=@MaNhanVien
	else if @MaTD='DH'
		update NhanVien set Luong=Luong/1.5
		where MaTD=@MaTD and MaNhanVien=@MaNhanVien
	else if @MaTD='ThS'
		update NhanVien set Luong=Luong/1.8
		where MaTD=@MaTD and MaNhanVien=@MaNhanVien
	else if @MaTD='TS'
		update NhanVien set Luong=Luong/2.0
		where MaTD=@MaTD and MaNhanVien=@MaNhanVien
	else
		update NhanVien set Luong=Luong
		where MaTD=@MaTD and MaNhanVien=@MaNhanVien
	fetch next from cur3b into @MaNhanVien,@MaTD
end
close cur3b
deallocate cur3b
go
--Bài 4:
declare @MaNhanVien char(15), @TenNhanVien nvarchar(30),
		@MaPhongBan char(5), @TenPhongBan nvarchar(30),
		@ThongDiep nvarchar(70)

declare curPhongBan cursor
for select MaPhongBan, TenPhongBan
from PhongBan
order by MaPhongBan
open curPhongBan

fetch next from curPhongBan into @MaPhongBan, @TenPhongBan
while @@FETCH_STATUS=0
begin
	print '----------------------------------------------------------'
	select @ThongDiep='Danh sách nhân viên thuộc phòng '+@TenPhongBan
	print @ThongDiep
	
	declare curNhanVien cursor
	for select MaNhanVien, TenNhanVien
	from NhanVien inner join PhongBan on NhanVien.MaPhongBan=PhongBan.MaPhongBan
	where PhongBan.MaPhongBan=@MaPhongBan
	--group by MaNhanVien, TenNhanVien
	open curNhanVien
	fetch next from curNhanVien into @MaNhanVien, @TenNhanVien
	if @@FETCH_STATUS<>0
		print '------------------TRỐNG RỖNG------------------'
	while @@FETCH_STATUS=0
	begin
		select @ThongDiep=space(5)+rtrim(@MaNhanVien)+SPACE(5)+@TenNhanVien
		print @ThongDiep
		fetch next from curNhanVien into @MaNhanVien, @TenNhanVien
	end
	close curNhanVien
	deallocate curNhanVien
	
	fetch next from curPhongBan into @MaPhongBan, @TenPhongBan
end
close curPhongBan
deallocate curPhongBan
go