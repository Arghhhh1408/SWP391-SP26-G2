-- ============================================================
-- PATCH: Inventory Adjustment Tables
-- Chạy script này trên database SimpleInventoryManagement
-- ============================================================
USE [SimpleInventoryManagement];
GO

-- Bảng phiếu điều chỉnh tồn kho
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InventoryAdjustments')
BEGIN
    CREATE TABLE [dbo].[InventoryAdjustments] (
        [AdjustmentID]   INT           IDENTITY(1,1) NOT NULL,
        [AdjustmentCode] NVARCHAR(50)  NOT NULL,
        [AdjustmentDate] NVARCHAR(20)  NOT NULL,
        [Warehouse]      NVARCHAR(100) NULL,
        [CreatedBy]      INT           NOT NULL,
        [GeneralReason]  NVARCHAR(100) NULL,
        [Note]           NVARCHAR(MAX) NULL,
        [Status]         NVARCHAR(20)  NOT NULL DEFAULT N'Draft',
        [CreatedAt]      DATETIME      NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_InventoryAdjustments]      PRIMARY KEY CLUSTERED ([AdjustmentID] ASC),
        CONSTRAINT [UQ_InventoryAdjustments_Code] UNIQUE ([AdjustmentCode]),
        CONSTRAINT [FK_InventoryAdjustments_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
        CONSTRAINT [CK_InventoryAdjustments_Status] CHECK ([Status] IN (N'Draft', N'Confirmed'))
    );
    PRINT 'Created table InventoryAdjustments';
END
GO

-- Bảng dòng chi tiết của phiếu điều chỉnh
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'InventoryAdjustmentItems')
BEGIN
    CREATE TABLE [dbo].[InventoryAdjustmentItems] (
        [ItemID]         INT           IDENTITY(1,1) NOT NULL,
        [AdjustmentID]   INT           NOT NULL,
        [ProductID]      INT           NOT NULL,
        [OldQuantity]    INT           NOT NULL,
        [NewQuantity]    INT           NOT NULL,
        [Variance]       INT           NOT NULL,
        [Reason]         NVARCHAR(100) NULL,
        [ItemNote]       NVARCHAR(500) NULL,
        CONSTRAINT [PK_InventoryAdjustmentItems]           PRIMARY KEY CLUSTERED ([ItemID] ASC),
        CONSTRAINT [FK_InventoryAdjustmentItems_Adj]       FOREIGN KEY ([AdjustmentID]) REFERENCES [dbo].[InventoryAdjustments]([AdjustmentID]) ON DELETE CASCADE,
        CONSTRAINT [FK_InventoryAdjustmentItems_Products]  FOREIGN KEY ([ProductID])    REFERENCES [dbo].[Products]([ProductID])
    );
    PRINT 'Created table InventoryAdjustmentItems';
END
GO

-- Dữ liệu mẫu cho bảng InventoryAdjustments (5 dòng)
IF NOT EXISTS (SELECT 1 FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-001')
BEGIN
    INSERT INTO [dbo].[InventoryAdjustments]
        ([AdjustmentCode], [AdjustmentDate], [Warehouse], [CreatedBy], [GeneralReason], [Note], [Status])
    VALUES
        (N'IA-20260327-001', N'2026-03-27', N'Kho TP.HCM', 3, N'Kiểm kê định kỳ', N'Điều chỉnh sau kiểm kê cuối tuần', N'Confirmed'),
        (N'IA-20260327-002', N'2026-03-27', N'Kho TP.HCM', 3, N'Hàng lỗi kỹ thuật', N'Giảm tồn sản phẩm lỗi', N'Confirmed'),
        (N'IA-20260327-003', N'2026-03-27', N'Kho Hà Nội', 2, N'Nhập bù tồn kho', N'Tăng tồn theo biên bản bàn giao', N'Confirmed'),
        (N'IA-20260327-004', N'2026-03-27', N'Kho Hà Nội', 2, N'Sai lệch khi nhập liệu', N'Điều chỉnh theo số liệu thực tế', N'Draft'),
        (N'IA-20260327-005', N'2026-03-27', N'Kho TP.HCM', 1, N'Kiểm kê đột xuất', N'Chờ duyệt xác nhận điều chỉnh', N'Draft');
END
GO

-- Dữ liệu mẫu cho bảng InventoryAdjustmentItems (5 dòng)
IF NOT EXISTS (
    SELECT 1
    FROM [dbo].[InventoryAdjustmentItems] i
    INNER JOIN [dbo].[InventoryAdjustments] a ON a.[AdjustmentID] = i.[AdjustmentID]
    WHERE a.[AdjustmentCode] = N'IA-20260327-001'
)
BEGIN
    INSERT INTO [dbo].[InventoryAdjustmentItems]
        ([AdjustmentID], [ProductID], [OldQuantity], [NewQuantity], [Variance], [Reason], [ItemNote])
    VALUES
        ((SELECT [AdjustmentID] FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-001'), 1, 10, 9, -1, N'Mất mát khi kiểm kê', N'Thiếu 1 sản phẩm'),
        ((SELECT [AdjustmentID] FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-002'), 2, 20, 18, -2, N'Hàng lỗi không bán được', N'Loại bỏ 2 sản phẩm lỗi'),
        ((SELECT [AdjustmentID] FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-003'), 1, 9, 12, 3, N'Nhập bù từ kho tổng', N'Tăng tồn do bàn giao nội bộ'),
        ((SELECT [AdjustmentID] FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-004'), 2, 18, 19, 1, N'Đếm thiếu lần trước', N'Điều chỉnh +1 theo kiểm đếm lại'),
        ((SELECT [AdjustmentID] FROM [dbo].[InventoryAdjustments] WHERE [AdjustmentCode] = N'IA-20260327-005'), 1, 12, 11, -1, N'Khấu hao hàng trưng bày', N'Giảm 1 sản phẩm trưng bày');
END
GO

PRINT 'Patch applied successfully.';
GO
