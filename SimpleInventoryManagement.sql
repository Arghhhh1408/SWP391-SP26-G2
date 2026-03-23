USE [master]
GO

-- ======================================================================================
-- BƯỚC 1: KHỞI TẠO DATABASE
-- Nếu DB đã tồn tại thì xóa đi tạo lại để đảm bảo sạch sẽ
-- ======================================================================================
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SimpleInventoryManagement')
BEGIN
    ALTER DATABASE SimpleInventoryManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SimpleInventoryManagement;
END
GO

CREATE DATABASE [SimpleInventoryManagement]
GO

USE [SimpleInventoryManagement]
GO

/* =======================================================================================
   PHẦN 1 - BẢNG PHÂN QUYỀN
   ======================================================================================= */
CREATE TABLE [dbo].[Role](
    -- Mã vai trò
    [RoleID] INT NOT NULL,

    -- Tên vai trò
    [RoleName] NVARCHAR(50) NOT NULL,

    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([RoleID] ASC)
);
GO

/* =======================================================================================
   PHẦN 2 - BẢNG NGƯỜI DÙNG
   ======================================================================================= */
CREATE TABLE [dbo].[User](
    -- Mã người dùng tự tăng
    [UserID] INT IDENTITY(1,1) NOT NULL,

    -- Tên đăng nhập
    [Username] NVARCHAR(50) NOT NULL,

    -- Mật khẩu đã mã hóa
    [PasswordHash] NVARCHAR(255) NOT NULL,

    -- Họ tên người dùng
    [FullName] NVARCHAR(100) NULL,

    -- Mã vai trò
    [RoleID] INT NOT NULL,

    -- Email
    [Email] NVARCHAR(100) NULL,

    -- Số điện thoại
    [Phone] NVARCHAR(20) NULL,

    -- Ngày tạo tài khoản
    [CreateDate] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Trạng thái hoạt động: 1 = hoạt động, 0 = khóa/nghỉ
    [IsActive] BIT NOT NULL DEFAULT 1,

    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_User_Username] UNIQUE ([Username]),
    CONSTRAINT [FK_User_Role] FOREIGN KEY ([RoleID]) REFERENCES [dbo].[Role]([RoleID])
);
GO

/* =======================================================================================
   PHẦN 3 - BẢNG LOG HỆ THỐNG
   ======================================================================================= */
CREATE TABLE [dbo].[SystemLog](
    -- Mã log tự tăng
    [LogID] INT IDENTITY(1,1) NOT NULL,

    -- Người thực hiện thao tác
    [UserID] INT NOT NULL,

    -- Tên hành động
    [Action] NVARCHAR(50) NOT NULL,

    -- Đối tượng bị tác động
    [TargetObject] NVARCHAR(100) NULL,

    -- Mô tả chi tiết hành động
    [Description] NVARCHAR(MAX) NULL,

    -- Thời gian ghi log
    [LogDate] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Địa chỉ IP của người thao tác
    [IPAddress] NVARCHAR(50) NULL,

    CONSTRAINT [PK_SystemLog] PRIMARY KEY CLUSTERED ([LogID] ASC),
    CONSTRAINT [FK_SystemLog_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 4 - BẢNG THÔNG BÁO
   ======================================================================================= */
CREATE TABLE [dbo].[Notifications](
    -- Mã thông báo tự tăng
    [NotificationID] INT IDENTITY(1,1) NOT NULL,

    -- Người nhận thông báo
    [UserID] INT NOT NULL,

    -- Tiêu đề thông báo
    [Title] NVARCHAR(100) NOT NULL,

    -- Nội dung thông báo
    [Message] NVARCHAR(255) NULL,

    -- Trạng thái đã đọc: 0 = chưa đọc, 1 = đã đọc
    [IsRead] BIT NOT NULL DEFAULT 0,

    -- Thời điểm tạo thông báo
    [CreatedAt] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Loại thông báo
    [Type] NVARCHAR(20) NOT NULL DEFAULT N'Info',

    CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([NotificationID] ASC),
    CONSTRAINT [FK_Notifications_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 5 - BẢNG DANH MỤC
   ======================================================================================= */
CREATE TABLE [dbo].[Categories](
    -- Mã danh mục tự tăng
    [CategoryID] INT IDENTITY(1,1) NOT NULL,

    -- Tên danh mục
    [CategoryName] NVARCHAR(100) NOT NULL,

    -- Mô tả danh mục
    [Description] NVARCHAR(255) NULL,

    -- Danh mục cha, hỗ trợ cây danh mục
    [ParentID] INT NULL,

    CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED ([CategoryID] ASC),
    CONSTRAINT [FK_Categories_Parent] FOREIGN KEY ([ParentID]) REFERENCES [dbo].[Categories]([CategoryID])
);
GO

/* =======================================================================================
   PHẦN 6 - BẢNG NHÀ CUNG CẤP
   ======================================================================================= */
CREATE TABLE [dbo].[Suppliers](
    -- Mã nhà cung cấp tự tăng
    [SupplierID] INT IDENTITY(1,1) NOT NULL,

    -- Tên nhà cung cấp
    [Name] NVARCHAR(100) NOT NULL,

    -- Số điện thoại nhà cung cấp
    [Phone] NVARCHAR(20) NULL,

    -- Địa chỉ nhà cung cấp
    [Address] NVARCHAR(255) NULL,

    -- Email nhà cung cấp
    [Email] NVARCHAR(100) NULL,

    -- Trạng thái hoạt động: 1 = còn hợp tác, 0 = ngừng hợp tác
    [IsActive] BIT NOT NULL DEFAULT 1,

    CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED ([SupplierID] ASC)
);
GO

/* =======================================================================================
   PHẦN 7 - BẢNG KHÁCH HÀNG
   ======================================================================================= */
CREATE TABLE [dbo].[Customers](
    -- Mã khách hàng tự tăng
    [CustomerID] INT IDENTITY(1,1) NOT NULL,

    -- Tên khách hàng
    [Name] NVARCHAR(100) NOT NULL,

    -- Số điện thoại khách hàng
    [Phone] NVARCHAR(20) NULL,

    -- Địa chỉ khách hàng
    [Address] NVARCHAR(255) NULL,

    -- Email khách hàng
    [Email] NVARCHAR(100) NULL,

    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);
GO

/* =======================================================================================
   PHẦN 8 - BẢNG SẢN PHẨM
   ======================================================================================= */
CREATE TABLE [dbo].[Products](
    -- Mã sản phẩm tự tăng
    [ProductID] INT IDENTITY(1,1) NOT NULL,

    -- Tên sản phẩm
    [Name] NVARCHAR(255) NOT NULL,

    -- Mã SKU duy nhất
    [SKU] NVARCHAR(50) NOT NULL,

    -- Giá vốn
    [Cost] DECIMAL(10,2) NOT NULL,

    -- Giá bán
    [Price] DECIMAL(10,2) NOT NULL,

    -- Tồn kho hiện tại
    [StockQuantity] INT NOT NULL DEFAULT 0,

    -- Đơn vị tính
    [Unit] NVARCHAR(50) NOT NULL,

    -- Danh mục sản phẩm
    [CategoryID] INT NULL,

    -- Mô tả sản phẩm
    [Description] NVARCHAR(MAX) NULL,

    -- Đường dẫn ảnh sản phẩm
    [ImageURL] NVARCHAR(MAX) NULL,

    -- Thời gian bảo hành tính theo tháng
    [WarrantyPeriod] INT NOT NULL DEFAULT 0,

    -- Trạng thái sản phẩm: Active, Deactivated, Deleted
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Active',

    -- Ngày tạo sản phẩm
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Ngày cập nhật gần nhất
    [UpdatedDate] DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [UQ_Products_SKU] UNIQUE ([SKU]),
    CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories]([CategoryID]),
    CONSTRAINT [CK_Products_Status] CHECK ([Status] IN (N'Active', N'Deactivated', N'Deleted'))
);
GO

/* =======================================================================================
   PHẦN 9 - BẢNG LIÊN KẾT NHÀ CUNG CẤP VÀ SẢN PHẨM
   Quan hệ nhiều-nhiều
   1 nhà cung cấp có nhiều sản phẩm
   1 sản phẩm có thể có nhiều nhà cung cấp
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierProduct](
    -- Mã dòng liên kết tự tăng
    [SupplierProductID] INT IDENTITY(1,1) NOT NULL,

    -- Mã nhà cung cấp
    [SupplierID] INT NOT NULL,

    -- Mã sản phẩm
    [ProductID] INT NOT NULL,

    -- Giá nhập tham khảo từ nhà cung cấp này
    [SupplyPrice] DECIMAL(10,2) NULL,

    -- Trạng thái liên kết: 1 = còn hiệu lực, 0 = ngừng cung cấp
    [IsActive] BIT NOT NULL DEFAULT 1,

    -- Ngày tạo liên kết
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Ngày cập nhật liên kết
    [UpdatedDate] DATETIME NULL,

    CONSTRAINT [PK_SupplierProduct] PRIMARY KEY CLUSTERED ([SupplierProductID] ASC),
    CONSTRAINT [UQ_SupplierProduct] UNIQUE ([SupplierID], [ProductID]),
    CONSTRAINT [FK_SupplierProduct_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_SupplierProduct_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 10 - BẢNG PHIẾU NHẬP KHO
   ======================================================================================= */
CREATE TABLE [dbo].[StockIn](
    -- Mã phiếu nhập tự tăng
    [StockInID] INT IDENTITY(1,1) NOT NULL,

    -- Nhà cung cấp của phiếu nhập
    [SupplierID] INT NOT NULL,

    -- Ngày tạo phiếu nhập
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Tổng tiền phiếu nhập
    [TotalAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,

    -- Người tạo phiếu nhập
    [CreatedBy] INT NOT NULL,

    -- Ghi chú phiếu nhập
    [Note] NVARCHAR(MAX) NULL,

    -- Trạng thái nhập kho: Pending, Completed, CancelRequested, Cancelled
    [StockStatus] NVARCHAR(20) NOT NULL DEFAULT N'Pending',

    -- Trạng thái thanh toán: Unpaid, Partial, Paid, Cancelled
    [PaymentStatus] NVARCHAR(20) NOT NULL DEFAULT N'Unpaid',

    -- Nội dung/lý do yêu cầu hủy phiếu
    [CancelRequestNote] NVARCHAR(500) NULL,

    -- Người gửi yêu cầu hủy phiếu
    [CancelRequestedBy] INT NULL,

    -- Thời điểm gửi yêu cầu hủy
    [CancelRequestedAt] DATETIME NULL,

    -- Người duyệt hủy phiếu
    [CancelApprovedBy] INT NULL,

    -- Thời điểm duyệt hủy phiếu
    [CancelApprovedAt] DATETIME NULL,

    CONSTRAINT [PK_StockIn] PRIMARY KEY CLUSTERED ([StockInID] ASC),
    CONSTRAINT [FK_StockIn_Supplier] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_StockIn_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_StockIn_CancelRequestedBy] FOREIGN KEY ([CancelRequestedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_StockIn_CancelApprovedBy] FOREIGN KEY ([CancelApprovedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_StockIn_StockStatus] CHECK ([StockStatus] IN (N'Pending', N'Completed', N'CancelRequested', N'Cancelled')),
    CONSTRAINT [CK_StockIn_PaymentStatus] CHECK ([PaymentStatus] IN (N'Unpaid', N'Partial', N'Paid', N'Cancelled'))
);
GO

/* =======================================================================================
   PHẦN 11 - BẢNG CHI TIẾT PHIẾU NHẬP
   ======================================================================================= */
CREATE TABLE [dbo].[StockInDetails](
    -- Mã chi tiết phiếu nhập tự tăng
    [DetailID] INT IDENTITY(1,1) NOT NULL,

    -- Mã phiếu nhập
    [StockInID] INT NOT NULL,

    -- Mã sản phẩm
    [ProductID] INT NOT NULL,

    -- Số lượng đặt / số lượng dự kiến nhập
    [Quantity] INT NOT NULL,

    -- Số lượng thực tế đã nhận
    [ReceivedQuantity] INT NOT NULL DEFAULT 0,

    -- Đơn giá nhập
    [UnitCost] DECIMAL(10,2) NOT NULL,

    -- Thành tiền tự tính = Quantity * UnitCost
    [SubTotal] AS ([Quantity] * [UnitCost]),

    CONSTRAINT [PK_StockInDetails] PRIMARY KEY CLUSTERED ([DetailID] ASC),
    CONSTRAINT [CK_StockInDetails_ReceivedQuantity] CHECK ([ReceivedQuantity] >= 0 AND [ReceivedQuantity] <= [Quantity]),
    CONSTRAINT [FK_StockInDetails_StockIn] FOREIGN KEY ([StockInID]) REFERENCES [dbo].[StockIn]([StockInID]) ON DELETE CASCADE,
    CONSTRAINT [FK_StockInDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 12 - VIEW TỔNG HỢP TIẾN ĐỘ NHẬP HÀNG
   ======================================================================================= */
CREATE VIEW [dbo].[vw_StockInProgress]
AS
SELECT
    si.[StockInID],
    si.[SupplierID],
    sup.[Name] AS [SupplierName],
    si.[Date],
    si.[CreatedBy],
    si.[Note],
    si.[StockStatus],
    si.[PaymentStatus],
    si.[CancelRequestNote],
    si.[CancelRequestedBy],
    si.[CancelRequestedAt],
    si.[CancelApprovedBy],
    si.[CancelApprovedAt],
    SUM(ISNULL(sid.[Quantity], 0)) AS [TotalOrderedQuantity],
    SUM(ISNULL(sid.[ReceivedQuantity], 0)) AS [TotalReceivedQuantity],
    SUM(ISNULL(sid.[Quantity], 0) - ISNULL(sid.[ReceivedQuantity], 0)) AS [TotalRemainingQuantity],
    SUM(ISNULL(sid.[Quantity] * sid.[UnitCost], 0)) AS [TotalAmountCalculated]
FROM [dbo].[StockIn] si
LEFT JOIN [dbo].[StockInDetails] sid ON si.[StockInID] = sid.[StockInID]
LEFT JOIN [dbo].[Suppliers] sup ON si.[SupplierID] = sup.[SupplierID]
GROUP BY
    si.[StockInID],
    si.[SupplierID],
    sup.[Name],
    si.[Date],
    si.[CreatedBy],
    si.[Note],
    si.[StockStatus],
    si.[PaymentStatus],
    si.[CancelRequestNote],
    si.[CancelRequestedBy],
    si.[CancelRequestedAt],
    si.[CancelApprovedBy],
    si.[CancelApprovedAt];
GO

/* =======================================================================================
   PHẦN 13 - PROCEDURE TỰ CẬP NHẬT TRẠNG THÁI PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_RefreshStockInStatus]
    @StockInID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentStatus NVARCHAR(20);
    DECLARE @TotalQty INT;
    DECLARE @TotalReceived INT;

    SELECT @CurrentStatus = [StockStatus]
    FROM [dbo].[StockIn]
    WHERE [StockInID] = @StockInID;

    IF @CurrentStatus IS NULL RETURN;

    IF @CurrentStatus IN (N'CancelRequested', N'Cancelled') RETURN;

    SELECT
        @TotalQty = ISNULL(SUM([Quantity]), 0),
        @TotalReceived = ISNULL(SUM([ReceivedQuantity]), 0)
    FROM [dbo].[StockInDetails]
    WHERE [StockInID] = @StockInID;

    UPDATE [dbo].[StockIn]
    SET [StockStatus] = CASE
        WHEN @TotalQty > 0 AND @TotalReceived >= @TotalQty THEN N'Completed'
        ELSE N'Pending'
    END
    WHERE [StockInID] = @StockInID;
END
GO

/* =======================================================================================
   PHẦN 14 - PROCEDURE NHẬN HÀNG TỪNG PHẦN
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_ReceiveStockInDetail]
    @DetailID INT,
    @ReceiveQty INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StockInID INT;
    DECLARE @ProductID INT;
    DECLARE @RemainingQty INT;

    IF @ReceiveQty IS NULL OR @ReceiveQty <= 0
    BEGIN
        RAISERROR (N'Số lượng nhận phải lớn hơn 0.', 16, 1);
        RETURN;
    END

    SELECT
        @StockInID = [StockInID],
        @ProductID = [ProductID],
        @RemainingQty = [Quantity] - [ReceivedQuantity]
    FROM [dbo].[StockInDetails]
    WHERE [DetailID] = @DetailID;

    IF @StockInID IS NULL
    BEGIN
        RAISERROR (N'Không tìm thấy chi tiết phiếu nhập.', 16, 1);
        RETURN;
    END

    IF @ReceiveQty > @RemainingQty
    BEGIN
        RAISERROR (N'Số lượng nhận vượt quá số lượng còn thiếu.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE [dbo].[StockInDetails]
        SET [ReceivedQuantity] = [ReceivedQuantity] + @ReceiveQty
        WHERE [DetailID] = @DetailID;

        UPDATE [dbo].[Products]
        SET
            [StockQuantity] = [StockQuantity] + @ReceiveQty,
            [UpdatedDate] = GETDATE()
        WHERE [ProductID] = @ProductID;

        EXEC [dbo].[sp_RefreshStockInStatus] @StockInID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* =======================================================================================
   PHẦN 15 - PROCEDURE GỬI YÊU CẦU HỦY PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_RequestCancelStockIn]
    @StockInID INT,
    @UserID INT,
    @Reason NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[StockIn]
    SET
        [StockStatus] = N'CancelRequested',
        [CancelRequestNote] = @Reason,
        [CancelRequestedBy] = @UserID,
        [CancelRequestedAt] = GETDATE()
    WHERE [StockInID] = @StockInID
      AND [StockStatus] = N'Pending';
END
GO

/* =======================================================================================
   PHẦN 16 - PROCEDURE DUYỆT HỦY PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_ApproveCancelStockIn]
    @StockInID INT,
    @ManagerID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE [dbo].[StockIn]
    SET
        [StockStatus] = N'Cancelled',
        [CancelApprovedBy] = @ManagerID,
        [CancelApprovedAt] = GETDATE()
    WHERE [StockInID] = @StockInID
      AND [StockStatus] = N'CancelRequested';
END
GO

/* =======================================================================================
   PHẦN 17 - PROCEDURE TỪ CHỐI HỦY PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_RejectCancelStockIn]
    @StockInID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalQty INT;
    DECLARE @TotalReceived INT;

    SELECT
        @TotalQty = ISNULL(SUM([Quantity]), 0),
        @TotalReceived = ISNULL(SUM([ReceivedQuantity]), 0)
    FROM [dbo].[StockInDetails]
    WHERE [StockInID] = @StockInID;

    UPDATE [dbo].[StockIn]
    SET
        [StockStatus] = CASE
            WHEN @TotalQty > 0 AND @TotalReceived >= @TotalQty THEN N'Completed'
            ELSE N'Pending'
        END,
        [CancelApprovedBy] = NULL,
        [CancelApprovedAt] = NULL
    WHERE [StockInID] = @StockInID
      AND [StockStatus] = N'CancelRequested';
END
GO

/* =======================================================================================
   PHẦN 18 - BẢNG PHIẾU XUẤT / BÁN HÀNG
   ======================================================================================= */
CREATE TABLE [dbo].[StockOut](
    -- Mã phiếu xuất tự tăng
    [StockOutID] INT IDENTITY(1,1) NOT NULL,

    -- Khách hàng của phiếu xuất
    [CustomerID] INT NULL,

    -- Ngày tạo phiếu xuất
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Tổng tiền phiếu xuất
    [TotalAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,

    -- Người tạo phiếu xuất
    [CreatedBy] INT NOT NULL,

    -- Ghi chú phiếu xuất
    [Note] NVARCHAR(MAX) NULL,

    -- Trạng thái phiếu xuất
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Completed',

    CONSTRAINT [PK_StockOut] PRIMARY KEY CLUSTERED ([StockOutID] ASC),
    CONSTRAINT [FK_StockOut_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_StockOut_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 19 - BẢNG CHI TIẾT PHIẾU XUẤT
   ======================================================================================= */
CREATE TABLE [dbo].[StockOutDetails](
    -- Mã chi tiết phiếu xuất tự tăng
    [DetailID] INT IDENTITY(1,1) NOT NULL,

    -- Mã phiếu xuất
    [StockOutID] INT NOT NULL,

    -- Mã sản phẩm
    [ProductID] INT NOT NULL,

    -- Số lượng bán
    [Quantity] INT NOT NULL,

    -- Đơn giá bán
    [UnitPrice] DECIMAL(10,2) NOT NULL,

    -- Thành tiền tự tính
    [SubTotal] AS ([Quantity] * [UnitPrice]),

    CONSTRAINT [PK_StockOutDetails] PRIMARY KEY CLUSTERED ([DetailID] ASC),
    CONSTRAINT [FK_StockOutDetails_StockOut] FOREIGN KEY ([StockOutID]) REFERENCES [dbo].[StockOut]([StockOutID]) ON DELETE CASCADE,
    CONSTRAINT [FK_StockOutDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 20 - BẢNG BẢO HÀNH
   ======================================================================================= */
CREATE TABLE [dbo].[WarrantyTickets](
    -- Mã phiếu bảo hành tự tăng
    [TicketID] INT IDENTITY(1,1) NOT NULL,

    -- Phiếu xuất gốc liên quan
    [StockOutID] INT NOT NULL,

    -- Sản phẩm bảo hành
    [ProductID] INT NOT NULL,

    -- Khách hàng yêu cầu bảo hành
    [CustomerID] INT NOT NULL,

    -- Ngày nhận bảo hành
    [ReceiveDate] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Ngày trả hàng bảo hành
    [ReturnDate] DATETIME NULL,

    -- Mô tả lỗi
    [IssueDescription] NVARCHAR(MAX) NULL,

    -- Cách xử lý
    [Solution] NVARCHAR(MAX) NULL,

    -- Trạng thái bảo hành
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Received',

    -- Người tiếp nhận bảo hành
    [CreatedBy] INT NOT NULL,

    CONSTRAINT [PK_WarrantyTickets] PRIMARY KEY CLUSTERED ([TicketID] ASC),
    CONSTRAINT [FK_WarrantyTickets_StockOut] FOREIGN KEY ([StockOutID]) REFERENCES [dbo].[StockOut]([StockOutID]),
    CONSTRAINT [FK_WarrantyTickets_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_WarrantyTickets_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_WarrantyTickets_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 20B - YÊU CẦU HOÀN HÀNG / HOÀN TIỀN (khớp entity ReturnRequest, ReturnEvent)
   Khác CustomerReturns: lưu snapshot SKU/tên SP & KH, workflow trạng thái + lịch sử sự kiện
   ======================================================================================= */
CREATE TABLE [dbo].[ReturnRequests](
    [ReturnID] INT IDENTITY(1,1) NOT NULL,

    [ReturnCode] NVARCHAR(50) NULL,

    [SKU] NVARCHAR(50) NOT NULL,
    [ProductName] NVARCHAR(255) NOT NULL,

    [CustomerName] NVARCHAR(100) NOT NULL,
    [CustomerPhone] NVARCHAR(20) NULL,

    [Reason] NVARCHAR(MAX) NULL,
    [ConditionNote] NVARCHAR(MAX) NULL,

    -- Giá trị enum Java: NEW, RECEIVED, INSPECTING, APPROVED, REJECTED, REFUNDED, COMPLETED, CANCELLED
    [Status] NVARCHAR(30) NOT NULL,

    [RefundAmount] DECIMAL(18,2) NULL,
    [RefundMethod] NVARCHAR(100) NULL,
    [RefundReference] NVARCHAR(200) NULL,
    [RefundedAt] DATETIME2(7) NULL,

    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_ReturnRequests_CreatedAt] DEFAULT (SYSUTCDATETIME()),
    [UpdatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_ReturnRequests_UpdatedAt] DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT [PK_ReturnRequests] PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    CONSTRAINT [UQ_ReturnRequests_ReturnCode] UNIQUE ([ReturnCode])
);
GO

CREATE TABLE [dbo].[ReturnEvents](
    [EventID] INT IDENTITY(1,1) NOT NULL,

    [ReturnID] INT NOT NULL,

    [EventTime] DATETIME2(7) NOT NULL CONSTRAINT [DF_ReturnEvents_EventTime] DEFAULT (SYSUTCDATETIME()),

    [Actor] NVARCHAR(100) NOT NULL,
    [Action] NVARCHAR(50) NOT NULL,
    [Note] NVARCHAR(MAX) NULL,

    CONSTRAINT [PK_ReturnEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_ReturnEvents_ReturnRequests] FOREIGN KEY ([ReturnID]) REFERENCES [dbo].[ReturnRequests]([ReturnID]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_ReturnEvents_ReturnID] ON [dbo].[ReturnEvents]([ReturnID] ASC);
GO

/* =======================================================================================
   PHẦN 20C - YÊU CẦU BẢO HÀNH (khớp entity WarrantyClaim, WarrantyClaimEvent)
   Khác WarrantyTickets: không bắt buộc liên kết StockOut/ProductID; lưu snapshot + workflow
   ======================================================================================= */
CREATE TABLE [dbo].[WarrantyClaims](
    [ClaimID] INT IDENTITY(1,1) NOT NULL,

    [ClaimCode] NVARCHAR(50) NULL,

    [SKU] NVARCHAR(50) NOT NULL,
    [ProductName] NVARCHAR(255) NOT NULL,

    [CustomerName] NVARCHAR(100) NOT NULL,
    [CustomerPhone] NVARCHAR(20) NULL,

    [IssueDescription] NVARCHAR(MAX) NULL,

    -- Giá trị enum Java: NEW, RECEIVED, IN_REPAIR, APPROVED, REJECTED, COMPLETED, CANCELLED
    [Status] NVARCHAR(30) NOT NULL,

    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_WarrantyClaims_CreatedAt] DEFAULT (SYSUTCDATETIME()),
    [UpdatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_WarrantyClaims_UpdatedAt] DEFAULT (SYSUTCDATETIME()),

    CONSTRAINT [PK_WarrantyClaims] PRIMARY KEY CLUSTERED ([ClaimID] ASC),
    CONSTRAINT [UQ_WarrantyClaims_ClaimCode] UNIQUE ([ClaimCode])
);
GO

CREATE TABLE [dbo].[WarrantyClaimEvents](
    [EventID] INT IDENTITY(1,1) NOT NULL,

    [ClaimID] INT NOT NULL,

    [EventTime] DATETIME2(7) NOT NULL CONSTRAINT [DF_WarrantyClaimEvents_EventTime] DEFAULT (SYSUTCDATETIME()),

    [Actor] NVARCHAR(100) NOT NULL,
    [Action] NVARCHAR(50) NOT NULL,
    [Note] NVARCHAR(MAX) NULL,

    CONSTRAINT [PK_WarrantyClaimEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_WarrantyClaimEvents_WarrantyClaims] FOREIGN KEY ([ClaimID]) REFERENCES [dbo].[WarrantyClaims]([ClaimID]) ON DELETE CASCADE
);
GO

CREATE NONCLUSTERED INDEX [IX_WarrantyClaimEvents_ClaimID] ON [dbo].[WarrantyClaimEvents]([ClaimID] ASC);
GO

/* =======================================================================================
   PHẦN 21 - BẢNG ĐIỀU CHỈNH KHO
   ======================================================================================= */
CREATE TABLE [dbo].[StockAdjustments](
    -- Mã điều chỉnh kho tự tăng
    [AdjustmentID] INT IDENTITY(1,1) NOT NULL,

    -- Sản phẩm điều chỉnh
    [ProductID] INT NOT NULL,

    -- Số lượng điều chỉnh
    [Quantity] INT NOT NULL,

    -- Mã lý do điều chỉnh
    [ReasonCode] NVARCHAR(50) NOT NULL,

    -- Ngày điều chỉnh
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Người tạo điều chỉnh
    [CreatedBy] INT NOT NULL,

    -- Trạng thái điều chỉnh
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Approved',

    CONSTRAINT [PK_StockAdjustments] PRIMARY KEY CLUSTERED ([AdjustmentID] ASC),
    CONSTRAINT [FK_StockAdjustments_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_StockAdjustments_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 22 - BẢNG CẢNH BÁO TỒN KHO THẤP
   ======================================================================================= */
CREATE TABLE [dbo].[LowStockAlerts](
    -- Mã cảnh báo tự tăng
    [AlertID] INT IDENTITY(1,1) NOT NULL,

    -- Sản phẩm được cấu hình cảnh báo
    [ProductID] INT NOT NULL,

    -- Mức tồn tối thiểu
    [MinStockLevel] INT NOT NULL,

    -- Đã gửi cảnh báo hay chưa
    [Notified] BIT NOT NULL DEFAULT 0,

    CONSTRAINT [PK_LowStockAlerts] PRIMARY KEY CLUSTERED ([AlertID] ASC),
    CONSTRAINT [FK_LowStockAlerts_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 23 - BẢNG KIỂM KÊ KHO
   ======================================================================================= */
CREATE TABLE [dbo].[InventoryCounts](
    -- Mã kiểm kê tự tăng
    [CountID] INT IDENTITY(1,1) NOT NULL,

    -- Sản phẩm được kiểm kê
    [ProductID] INT NOT NULL,

    -- Số lượng đếm thực tế
    [PhysicalQuantity] INT NOT NULL,

    -- Số lượng trên hệ thống
    [SystemQuantity] INT NOT NULL,

    -- Ngày kiểm kê
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Người duyệt kiểm kê
    [ApprovedBy] INT NULL,

    -- Trạng thái kiểm kê
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Pending',

    CONSTRAINT [PK_InventoryCounts] PRIMARY KEY CLUSTERED ([CountID] ASC),
    CONSTRAINT [FK_InventoryCounts_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_InventoryCounts_User] FOREIGN KEY ([ApprovedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 24 - BẢNG CÔNG NỢ NHÀ CUNG CẤP
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierDebts](
    -- Mã công nợ tự tăng
    [DebtID] INT IDENTITY(1,1) NOT NULL,

    -- Nhà cung cấp bị nợ
    [SupplierID] INT NOT NULL,

    -- Phiếu nhập liên quan đến công nợ
    [StockInID] INT NOT NULL,

    -- Số tiền nợ
    [Amount] DECIMAL(10,2) NOT NULL,

    -- Hạn thanh toán
    [DueDate] DATE NULL,

    -- Trạng thái công nợ
    [Status] NVARCHAR(20) NOT NULL DEFAULT N'Pending',

    CONSTRAINT [PK_SupplierDebts] PRIMARY KEY CLUSTERED ([DebtID] ASC),
    CONSTRAINT [FK_SupplierDebts_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_SupplierDebts_StockIn] FOREIGN KEY ([StockInID]) REFERENCES [dbo].[StockIn]([StockInID])
);
GO

/* =======================================================================================
   PHẦN 25 - BẢNG KHÁCH TRẢ HÀNG
   ======================================================================================= */
CREATE TABLE [dbo].[CustomerReturns](
    -- Mã trả hàng tự tăng
    [ReturnID] INT IDENTITY(1,1) NOT NULL,

    -- Phiếu xuất gốc
    [StockOutID] INT NOT NULL,

    -- Sản phẩm bị trả
    [ProductID] INT NOT NULL,

    -- Số lượng trả
    [Quantity] INT NOT NULL,

    -- Lý do trả hàng
    [Reason] NVARCHAR(255) NULL,

    -- Ngày trả hàng
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- Số tiền hoàn
    [RefundAmount] DECIMAL(10,2) NULL,

    CONSTRAINT [PK_CustomerReturns] PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    CONSTRAINT [FK_CustomerReturns_StockOut] FOREIGN KEY ([StockOutID]) REFERENCES [dbo].[StockOut]([StockOutID]),
    CONSTRAINT [FK_CustomerReturns_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 26 - BẢNG TRẢ HÀNG LẠI NHÀ CUNG CẤP
   ======================================================================================= */
CREATE TABLE [dbo].[ReturnToVendors](
    -- Mã trả hàng NCC tự tăng
    [RTVID] INT IDENTITY(1,1) NOT NULL,

    -- Phiếu nhập gốc
    [StockInID] INT NOT NULL,

    -- Sản phẩm trả lại
    [ProductID] INT NOT NULL,

    -- Số lượng trả
    [Quantity] INT NOT NULL,

    -- Lý do trả hàng
    [Reason] NVARCHAR(255) NULL,

    -- Ngày trả hàng
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT [PK_ReturnToVendors] PRIMARY KEY CLUSTERED ([RTVID] ASC),
    CONSTRAINT [FK_ReturnToVendors_StockIn] FOREIGN KEY ([StockInID]) REFERENCES [dbo].[StockIn]([StockInID]),
    CONSTRAINT [FK_ReturnToVendors_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 27 - BẢNG LỊCH SỬ BIẾN ĐỘNG KHO
   ======================================================================================= */
CREATE TABLE [dbo].[ProductHistories](
    -- Mã lịch sử tự tăng
    [HistoryID] INT IDENTITY(1,1) NOT NULL,

    -- Sản phẩm biến động
    [ProductID] INT NOT NULL,

    -- Loại giao dịch
    [TransactionType] NVARCHAR(50) NOT NULL,

    -- Số lượng biến động
    [Quantity] INT NOT NULL,

    -- Ngày biến động
    [Date] DATETIME NOT NULL DEFAULT GETDATE(),

    -- ID chứng từ tham chiếu
    [ReferenceID] INT NULL,

    CONSTRAINT [PK_ProductHistories] PRIMARY KEY CLUSTERED ([HistoryID] ASC),
    CONSTRAINT [FK_ProductHistories_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 28 - DỮ LIỆU MẪU
   ======================================================================================= */
INSERT INTO [dbo].[Role] ([RoleID], [RoleName]) VALUES
(0, N'Admin'),
(1, N'Warehouse Staff'),
(2, N'Manager'),
(3, N'Salesperson');
GO

INSERT INTO [dbo].[User] ([Username], [PasswordHash], [FullName], [RoleID], [Email], [Phone], [IsActive]) VALUES
(N'admin', N'202cb962ac59075b964b07152d234b70', N'Administrator', 0, N'admin@sim.com', N'0987654321', 1);
GO

INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [ParentID]) VALUES
(N'Điện tử - Điện lạnh', NULL, NULL),
(N'Gia dụng nhà bếp', NULL, NULL);
GO

INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [ParentID]) VALUES
(N'Tủ lạnh', NULL, 1),
(N'Máy giặt', NULL, 1),
(N'Nồi cơm điện', NULL, 2),
(N'Bếp từ', NULL, 2);
GO

INSERT INTO [dbo].[Suppliers] ([Name], [Phone], [Address], [Email], [IsActive]) VALUES
(N'Samsung Vina', N'0901234567', N'TP.HCM', N'samsung@supplier.com', 1),
(N'Sharp Việt Nam', N'0912345678', N'Hà Nội', N'sharp@supplier.com', 1);
GO

INSERT INTO [dbo].[Customers] ([Name], [Phone], [Address], [Email]) VALUES
(N'Khách lẻ', N'0387654321', N'Tại quầy', NULL);
GO

INSERT INTO [dbo].[Products] ([Name], [SKU], [Cost], [Price], [StockQuantity], [Unit], [CategoryID], [Description], [WarrantyPeriod], [Status]) VALUES
(N'Tủ lạnh Samsung Inverter 208L', N'SS-208L', 5000000, 6500000, 0, N'Cái', 3, NULL, 24, N'Active'),
(N'Nồi cơm điện Sharp 1.8L', N'SHARP-18', 600000, 850000, 0, N'Cái', 5, NULL, 12, N'Active');
GO

INSERT INTO [dbo].[SupplierProduct] ([SupplierID], [ProductID], [SupplyPrice], [IsActive]) VALUES
(1, 1, 5000000, 1),
(2, 2, 600000, 1);
GO

/* =======================================================================================
   PHẦN 29 - DỮ LIỆU MẪU BỔ SUNG (cho test nghiệp vụ)
   ======================================================================================= */
INSERT INTO [dbo].[User] ([Username], [PasswordHash], [FullName], [RoleID], [Email], [Phone], [IsActive]) VALUES
(N'sales01', N'202cb962ac59075b964b07152d234b70', N'Sales Test', 3, N'sales01@sim.com', N'0909000001', 1),
(N'staff01', N'202cb962ac59075b964b07152d234b70', N'Staff Kho Test', 1, N'staff01@sim.com', N'0909000002', 1),
(N'manager01', N'202cb962ac59075b964b07152d234b70', N'Manager Test', 2, N'manager01@sim.com', N'0909000003', 1);
GO

INSERT INTO [dbo].[Notifications] ([UserID], [Title], [Message], [IsRead], [Type]) VALUES
(2, N'Cảnh báo tồn kho', N'SS-208L đang ở mức thấp so với cấu hình.', 0, N'Warning'),
(2, N'Nhắc xử lý bảo hành', N'Có yêu cầu bảo hành mới cần theo dõi.', 0, N'Info');
GO

INSERT INTO [dbo].[SystemLog] ([UserID], [Action], [TargetObject], [Description], [IPAddress]) VALUES
(1, N'INIT_DATA', N'DATABASE', N'Khởi tạo dữ liệu mẫu phục vụ test', N'127.0.0.1');
GO

INSERT INTO [dbo].[StockIn] ([SupplierID], [Date], [TotalAmount], [CreatedBy], [Note], [StockStatus], [PaymentStatus]) VALUES
(1, DATEADD(DAY, -40, GETDATE()), 10000000, 3, N'Nhập hàng đợt 1', N'Completed', N'Paid'),
(2, DATEADD(DAY, -10, GETDATE()), 3000000, 3, N'Nhập hàng đợt 2', N'Pending', N'Partial');
GO

INSERT INTO [dbo].[StockInDetails] ([StockInID], [ProductID], [Quantity], [ReceivedQuantity], [UnitCost]) VALUES
(1, 1, 2, 2, 5000000),
(2, 2, 5, 2, 600000);
GO

INSERT INTO [dbo].[SupplierDebts] ([SupplierID], [StockInID], [Amount], [DueDate], [Status]) VALUES
(2, 2, 1800000, DATEADD(DAY, 20, CAST(GETDATE() AS DATE)), N'Pending');
GO

INSERT INTO [dbo].[StockOut] ([CustomerID], [Date], [TotalAmount], [CreatedBy], [Note], [Status]) VALUES
-- Đơn còn hạn bảo hành (SS-208L warranty 24 tháng)
(1, DATEADD(MONTH, -2, GETDATE()), 6500000, 2, N'Bán lẻ tủ lạnh Samsung', N'Completed'),
-- Đơn đã hết hạn bảo hành (SHARP-18 warranty 12 tháng)
(1, DATEADD(MONTH, -14, GETDATE()), 850000, 2, N'Bán lẻ nồi cơm điện Sharp', N'Completed');
GO

INSERT INTO [dbo].[StockOutDetails] ([StockOutID], [ProductID], [Quantity], [UnitPrice]) VALUES
(1, 1, 1, 6500000),
(2, 2, 1, 850000);
GO

INSERT INTO [dbo].[WarrantyTickets] ([StockOutID], [ProductID], [CustomerID], [ReceiveDate], [IssueDescription], [Solution], [Status], [CreatedBy]) VALUES
(1, 1, 1, DATEADD(DAY, -5, GETDATE()), N'Máy chạy ồn', N'Đang kiểm tra linh kiện', N'Received', 1);
GO

INSERT INTO [dbo].[WarrantyClaims] ([ClaimCode], [SKU], [ProductName], [CustomerName], [CustomerPhone], [IssueDescription], [Status], [CreatedAt], [UpdatedAt]) VALUES
(N'WC-1001', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321', N'Làm lạnh yếu', N'NEW', DATEADD(DAY, -3, SYSUTCDATETIME()), DATEADD(DAY, -3, SYSUTCDATETIME())),
(N'WC-1002', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321', N'Nồi không vào điện', N'REJECTED', DATEADD(DAY, -20, SYSUTCDATETIME()), DATEADD(DAY, -18, SYSUTCDATETIME()));
GO

INSERT INTO [dbo].[WarrantyClaimEvents] ([ClaimID], [EventTime], [Actor], [Action], [Note]) VALUES
(1, DATEADD(DAY, -3, SYSUTCDATETIME()), N'sales01', N'CREATE', N'Tạo yêu cầu bảo hành'),
(1, DATEADD(DAY, -2, SYSUTCDATETIME()), N'admin', N'NOTE', N'Đã tiếp nhận kiểm tra'),
(2, DATEADD(DAY, -20, SYSUTCDATETIME()), N'sales01', N'CREATE', N'Tạo yêu cầu bảo hành'),
(2, DATEADD(DAY, -18, SYSUTCDATETIME()), N'admin', N'STATUS', N'Từ chối do quá thời hạn bảo hành');
GO

INSERT INTO [dbo].[CustomerReturns] ([StockOutID], [ProductID], [Quantity], [Reason], [Date], [RefundAmount]) VALUES
(2, 2, 1, N'Sản phẩm lỗi ngay khi mở hộp', DATEADD(DAY, -12, GETDATE()), 850000);
GO

INSERT INTO [dbo].[ReturnRequests] ([ReturnCode], [SKU], [ProductName], [CustomerName], [CustomerPhone], [Reason], [ConditionNote], [Status], [RefundAmount], [RefundMethod], [RefundReference], [RefundedAt], [CreatedAt], [UpdatedAt]) VALUES
(N'RT-1001', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321', N'Không hoạt động', N'Vỏ còn nguyên, đầy đủ phụ kiện', N'REFUNDED', 850000, N'Cash', N'RF-1001', DATEADD(DAY, -11, SYSUTCDATETIME()), DATEADD(DAY, -12, SYSUTCDATETIME()), DATEADD(DAY, -11, SYSUTCDATETIME())),
(N'RT-1002', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321', N'Không đúng nhu cầu', N'Đã mở thùng', N'NEW', NULL, NULL, NULL, NULL, DATEADD(DAY, -1, SYSUTCDATETIME()), DATEADD(DAY, -1, SYSUTCDATETIME()));
GO

INSERT INTO [dbo].[ReturnEvents] ([ReturnID], [EventTime], [Actor], [Action], [Note]) VALUES
(1, DATEADD(DAY, -12, SYSUTCDATETIME()), N'sales01', N'CREATE', N'Tạo yêu cầu trả hàng'),
(1, DATEADD(DAY, -11, SYSUTCDATETIME()), N'admin', N'REFUND', N'Đã hoàn tiền cho khách'),
(2, DATEADD(DAY, -1, SYSUTCDATETIME()), N'sales01', N'CREATE', N'Tạo yêu cầu trả hàng');
GO

INSERT INTO [dbo].[ReturnToVendors] ([StockInID], [ProductID], [Quantity], [Reason], [Date]) VALUES
(2, 2, 1, N'Hàng lỗi từ nhà cung cấp', DATEADD(DAY, -2, GETDATE()));
GO

INSERT INTO [dbo].[StockAdjustments] ([ProductID], [Quantity], [ReasonCode], [Date], [CreatedBy], [Status]) VALUES
(1, -1, N'Damaged', DATEADD(DAY, -4, GETDATE()), 3, N'Approved'),
(2, 2, N'Recount', DATEADD(DAY, -3, GETDATE()), 3, N'Approved');
GO

INSERT INTO [dbo].[LowStockAlerts] ([ProductID], [MinStockLevel], [Notified]) VALUES
(1, 2, 1),
(2, 3, 0);
GO

INSERT INTO [dbo].[InventoryCounts] ([ProductID], [PhysicalQuantity], [SystemQuantity], [Date], [ApprovedBy], [Status]) VALUES
(1, 1, 0, DATEADD(DAY, -6, GETDATE()), 4, N'Approved'),
(2, 2, 0, DATEADD(DAY, -6, GETDATE()), 4, N'Approved');
GO

INSERT INTO [dbo].[ProductHistories] ([ProductID], [TransactionType], [Quantity], [Date], [ReferenceID]) VALUES
(1, N'STOCK_IN', 2, DATEADD(DAY, -40, GETDATE()), 1),
(2, N'STOCK_IN', 2, DATEADD(DAY, -10, GETDATE()), 2),
(1, N'STOCK_OUT', -1, DATEADD(MONTH, -2, GETDATE()), 1),
(2, N'STOCK_OUT', -1, DATEADD(MONTH, -14, GETDATE()), 2),
(2, N'CUSTOMER_RETURN', 1, DATEADD(DAY, -12, GETDATE()), 1);
GO

SELECT N'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS [Status];
GO