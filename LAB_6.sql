-- 1.a
CREATE TRIGGER  trg_checkSalary15000
   ON NHANVIEN
   FOR INSERT, UPDATE
AS
   IF (SELECT LUONG FROM inserted)<15000
   BEGIN
      PRINT N'Lương > 15000';
	  ROLLBACK TRAN;
   END;
SELECT * FROM NHANVIEN
INSERT INTO [dbo].[NHANVIEN] ([HONV],[TENLOT],[TENNV],[MANV],[NGSINH],[DCHI],[PHAI],[LUONG],[MA_NQL],[PHG])
VALUES(N'Lê',N'Văn',N'Thái','098','11-14-1985','Cộng Hòa - HCM','Nam',6000,'005',1)
GO
-- 1.b
CREATE TRIGGER trg_CheckValidAge
   on NHANVIEN
   FOR INSERT
AS
   DECLARE @age INT;
   SELECT @age = DATEDIFF(YEAR, NGSINH, GETDATE())+1 FROM inserted;
   IF @age <18 or @age >65
   BEGIN
      PRINT N'Tuổi của nhân viên không hợp lệ 18 <= tuổi <= 65';
	  ROLLBACK TRANSACTION;
   END

INSERT INTO [dbo].[NHANVIEN] ([HONV],[TENLOT],[TENNV] ,[MANV] ,[NGSINH],[DCHI],[PHAI],[LUONG],[MA_NQL],[PHG])
     VALUES(N'Nguyễn',N'Thành',N'Đạt','045','05-14-2002','Cộng Hòa - HCM','Nam',30000,'005',1)
GO
-- 1.c
CREATE TRIGGER trg_CheckUpdateOnAddress
   ON NHANVIEN
   FOR UPDATE
AS
   IF EXISTS (SELECT DCHI FROM inserted where DCHI LIKE '%HCM%')
   BEGIN
      PRINT N'Không thể cập nhật nhân viên ở HCM';
	  ROLLBACK TRAN;
   END;

UPDATE [dbo].[NHANVIEN]
   SET [PHAI] = 'Nam'
 WHERE MaNV = '001';
GO

-- 2.a
CREATE TRIGGER trg_SumEmps
   ON NHANVIEN
   AFTER INSERT
AS
   DECLARE @male INT, @female INT;
   SELECT @female = count(Manv) FROM NHANVIEN WHERE PHAI = N'Nữ';
   SELECT @male = count(Manv) FROM NHANVIEN WHERE PHAI = N'Nam';
   PRINT N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
   PRINT N'Tổng số nhân viên là nam: ' + cast(@male as varchar);


INSERT INTO [dbo].[NHANVIEN]([HONV],[TENLOT],[TENNV],[MANV],[NGSINH],[DCHI],[PHAI],[LUONG],[MA_NQL],[PHG])
VALUES ('A','B','C','345','7-12-1999','HCM','Nam',600000,'005',1)
GO
 -- 2.b
CREATE TRIGGER trg_SumEmpsForUpdate
ON NHANVIEN
AFTER update
AS
IF (select top 1 PHAI FROM deleted) != (select top 1 PHAI FROM inserted)
   BEGIN
      Declare @male int, @female int;
      SELECT @female = count(Manv) from NHANVIEN where PHAI = N'Nữ';
      SELECT @male = count(Manv) from NHANVIEN where PHAI = N'Nam';
      PRINT N'Tổng số nhân viên là nữ: ' + cast(@female as varchar);
      PRINT N'Tổng số nhân viên là nam: ' + cast(@male as varchar);
   END;

UPDATE [dbo].[NHANVIEN]
   SET [HONV] = 'Tín'
      ,[PHAI] = N'Nữ'
 WHERE  MaNV = '345'
GO
-- 2.c
CREATE TRIGGER trg_SumForDelete
   on DEAN
   AFTER DELETE
AS
   SELECT MA_NVIEN, COUNT(MaDA) as 'Tổng sô đề án đã tham gia' from PHANCONG
      GROUP BY MA_NVIEN
GO

-- 3.a
CREATE TRIGGER trg_deleteNhanThanNV ON NHANVIEN
INSTEAD OF DELETE 
AS
BEGIN
   DELETE FROM THANNHAN WHERE MA_NVIEN IN (SELECT MANV FROM deleted)
   DELETE FROM NHANVIEN WHERE MANV IN (SELECT MANV FROM deleted)
END

DELETE NHANVIEN WHERE MANV='001'
SELECT * FROM THANNHAN

-- 3.b
CREATE TRIGGER trg_NhanVien3b ON NHANVIEN
ALTER INSERT
AS 
BEGIN 
INSERT INTO PHANCONG VALUES((SELECT MANV FROM INSERTED),1,1,100)
END
INSERT INTO NHANVIEN
VALUES(N'Nguyễn',N'Thành',N'Đạt','045','05-14-2002','Cộng Hòa - HCM','Nam',30000,'005',1)

