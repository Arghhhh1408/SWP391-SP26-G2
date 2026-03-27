USE [master]
GO

-- ======================================================================================
-- BƯỚC 1: KHỞI TẠO DATABASE
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
   FILE ĐÃ GỘP PATCH: supplier_email_api_patch.sql
   NGUYÊN TẮC GỘP: không dùng ALTER/UPDATE hậu kỳ cho các phần patch,
   mà chèn trực tiếp vào CREATE TABLE / CREATE INDEX / INSERT dữ liệu mẫu liên quan.
   Các vị trí thêm mới đều được đánh dấu bằng comment [PATCH MERGE].
   ======================================================================================= */

/* =======================================================================================
   PHẦN 1 - BẢNG PHÂN QUYỀN
   ======================================================================================= */
CREATE TABLE [dbo].[Role](
    [RoleID]   INT          NOT NULL,
    [RoleName] NVARCHAR(50) NOT NULL,
    CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([RoleID] ASC)
);
GO

/* =======================================================================================
   PHẦN 2 - BẢNG NGƯỜI DÙNG
   ======================================================================================= */
CREATE TABLE [dbo].[User](
    [UserID]       INT           IDENTITY(1,1) NOT NULL,
    [Username]     NVARCHAR(50)  NOT NULL,
    [PasswordHash] NVARCHAR(255) NOT NULL,
    [FullName]     NVARCHAR(100) NULL,
    [RoleID]       INT           NOT NULL,
    [Email]        NVARCHAR(100) NULL,
    [Phone]        NVARCHAR(20)  NULL,
    [CreateDate]   DATETIME      NOT NULL DEFAULT GETDATE(),
    [IsActive]     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_User]          PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_User_Username] UNIQUE ([Username]),
    CONSTRAINT [FK_User_Role]     FOREIGN KEY ([RoleID]) REFERENCES [dbo].[Role]([RoleID])
);
GO

/* =======================================================================================
   PHẦN 3 - BẢNG LOG HỆ THỐNG
   ======================================================================================= */
CREATE TABLE [dbo].[SystemLog](
    [LogID]        INT           IDENTITY(1,1) NOT NULL,
    [UserID]       INT           NOT NULL,
    [Action]       NVARCHAR(50)  NOT NULL,
    [TargetObject] NVARCHAR(100) NULL,
    [Description]  NVARCHAR(MAX) NULL,
    [LogDate]      DATETIME      NOT NULL DEFAULT GETDATE(),
    [IPAddress]    NVARCHAR(50)  NULL,
    CONSTRAINT [PK_SystemLog]      PRIMARY KEY CLUSTERED ([LogID] ASC),
    CONSTRAINT [FK_SystemLog_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 4 - BẢNG THÔNG BÁO  ← ĐÃ SỬA CỘT TYPE VÀ MESSAGE
   ======================================================================================= */
CREATE TABLE [dbo].[Notifications](
    [NotificationID] INT           IDENTITY(1,1) NOT NULL,
    [UserID]         INT           NOT NULL,
    [Title]          NVARCHAR(255) NOT NULL,
    [Message]        NVARCHAR(MAX) NULL,
    [IsRead]         BIT           NOT NULL DEFAULT 0,
    [CreatedAt]      DATETIME      NOT NULL DEFAULT GETDATE(),
    [Type]           NVARCHAR(50)  NOT NULL DEFAULT N'Info',
    CONSTRAINT [PK_Notifications]      PRIMARY KEY CLUSTERED ([NotificationID] ASC),
    CONSTRAINT [FK_Notifications_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 5 - BẢNG DANH MỤC
   ======================================================================================= */
CREATE TABLE [dbo].[Categories](
    [CategoryID]   INT           IDENTITY(1,1) NOT NULL,
    [CategoryName] NVARCHAR(100) NOT NULL,
    [Description]  NVARCHAR(255) NULL,
    [ParentID]     INT           NULL,
    CONSTRAINT [PK_Categories]        PRIMARY KEY CLUSTERED ([CategoryID] ASC),
    CONSTRAINT [FK_Categories_Parent] FOREIGN KEY ([ParentID]) REFERENCES [dbo].[Categories]([CategoryID])
);
GO

/* =======================================================================================
   PHẦN 6 - BẢNG NHÀ CUNG CẤP
   ======================================================================================= */
CREATE TABLE [dbo].[Suppliers](
    [SupplierID]              INT           IDENTITY(1,1) NOT NULL,
    [Name]                    NVARCHAR(100) NOT NULL,
    [Phone]                   NVARCHAR(20)  NULL,
    [Address]                 NVARCHAR(255) NULL,
    [Email]                   NVARCHAR(100) NULL,
    [IsActive]                BIT           NOT NULL DEFAULT 1,
    [LinkedUserID]            INT           NULL,
    -- [PATCH MERGE] Thêm nhóm cột xác thực email nhà cung cấp từ supplier_email_api_patch.sql
    [IsEmailVerified]         BIT           NOT NULL DEFAULT 0,
    [VerificationStatus]      NVARCHAR(20)  NOT NULL DEFAULT N'Pending',
    [VerificationToken]       NVARCHAR(120) NULL,
    [VerificationTokenExpiry] DATETIME      NULL,
    [LastVerificationSentAt]  DATETIME      NULL,
    CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED ([SupplierID] ASC),
    CONSTRAINT [FK_Suppliers_User] FOREIGN KEY ([LinkedUserID]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 6A - YÊU CẦU CẬP NHẬT NHÀ CUNG CẤP  [PATCH MERGE]
   ĐÃ THÊM: bảng SupplierUpdateRequests để lưu yêu cầu cập nhật thông tin supplier
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierUpdateRequests](
    [RequestID]        INT           IDENTITY(1,1) NOT NULL,
    [SupplierID]       INT           NOT NULL,
    [RequestedBy]      INT           NOT NULL,
    [ProposedName]     NVARCHAR(100) NOT NULL,
    [ProposedPhone]    NVARCHAR(20)  NULL,
    [ProposedAddress]  NVARCHAR(255) NULL,
    [ProposedEmail]    NVARCHAR(100) NULL,
    [Token]            NVARCHAR(120) NOT NULL,
    [Status]           NVARCHAR(20)  NOT NULL DEFAULT N'Pending',
    [RequestedAt]      DATETIME      NOT NULL DEFAULT GETDATE(),
    [RespondedAt]      DATETIME      NULL,
    CONSTRAINT [PK_SupplierUpdateRequests]           PRIMARY KEY CLUSTERED ([RequestID] ASC),
    CONSTRAINT [FK_SupplierUpdateRequests_Supplier]  FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_SupplierUpdateRequests_User]      FOREIGN KEY ([RequestedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [UQ_SupplierUpdateRequests_Token]     UNIQUE ([Token])
);
GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_Suppliers_LinkedUserID]
    ON [dbo].[Suppliers]([LinkedUserID])
    WHERE [LinkedUserID] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_User_IsActive_Email]
    ON [dbo].[User]([IsActive], [Email])
    WHERE [Email] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_User_IsActive_Phone]
    ON [dbo].[User]([IsActive], [Phone])
    WHERE [Phone] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_Suppliers_IsActive_Email]
    ON [dbo].[Suppliers]([IsActive], [Email])
    WHERE [Email] IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX [IX_Suppliers_IsActive_Phone]
    ON [dbo].[Suppliers]([IsActive], [Phone])
    WHERE [Phone] IS NOT NULL;
GO

-- [PATCH MERGE] Thêm index phục vụ xác thực email supplier
CREATE NONCLUSTERED INDEX [IX_Suppliers_VerificationToken]
    ON [dbo].[Suppliers]([VerificationToken])
    WHERE [VerificationToken] IS NOT NULL;
GO

-- [PATCH MERGE] Thêm index phục vụ tra cứu token yêu cầu cập nhật supplier
CREATE NONCLUSTERED INDEX [IX_SupplierUpdateRequests_Token]
    ON [dbo].[SupplierUpdateRequests]([Token])
    WHERE [Token] IS NOT NULL;
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_Suppliers_BlockActiveContactConflictWithUsers]
ON [dbo].[Suppliers]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN [dbo].[User] u ON u.[IsActive] = 1
        WHERE i.[IsActive] = 1
          AND (
                (NULLIF(LTRIM(RTRIM(i.[Phone])), '') IS NOT NULL AND LTRIM(RTRIM(i.[Phone])) = LTRIM(RTRIM(u.[Phone])))
             OR (NULLIF(LTRIM(RTRIM(i.[Email])), '') IS NOT NULL AND LOWER(LTRIM(RTRIM(i.[Email]))) = LOWER(LTRIM(RTRIM(u.[Email]))))
          )
    )
    BEGIN
        THROW 51001, N'Nhà cung cấp đang hoạt động không được trùng số điện thoại hoặc email với User đang hoạt động.', 1;
    END
END
GO

CREATE OR ALTER TRIGGER [dbo].[TRG_Users_BlockActiveContactConflictWithSuppliers]
ON [dbo].[User]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN [dbo].[Suppliers] s ON s.[IsActive] = 1
        WHERE i.[IsActive] = 1
          AND (
                (NULLIF(LTRIM(RTRIM(i.[Phone])), '') IS NOT NULL AND LTRIM(RTRIM(i.[Phone])) = LTRIM(RTRIM(s.[Phone])))
             OR (NULLIF(LTRIM(RTRIM(i.[Email])), '') IS NOT NULL AND LOWER(LTRIM(RTRIM(i.[Email]))) = LOWER(LTRIM(RTRIM(s.[Email]))))
          )
    )
    BEGIN
        THROW 51002, N'User đang hoạt động không được trùng số điện thoại hoặc email với nhà cung cấp đang hoạt động.', 1;
    END
END
GO

/* =======================================================================================
   PHẦN 7 - BẢNG KHÁCH HÀNG
   ======================================================================================= */
CREATE TABLE [dbo].[Customers](
    [CustomerID] INT           IDENTITY(1,1) NOT NULL,
    [Name]       NVARCHAR(100) NOT NULL,
    [Phone]      NVARCHAR(20)  NULL,
    [Address]    NVARCHAR(255) NULL,
    [Email]      NVARCHAR(100) NULL,
    [Debt]       DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);
GO

/* =======================================================================================
   PHẦN 8 - BẢNG SẢN PHẨM
   ======================================================================================= */
CREATE TABLE [dbo].[Products](
    [ProductID]      INT           IDENTITY(1,1) NOT NULL,
    [Name]           NVARCHAR(255) NOT NULL,
    [SKU]            NVARCHAR(50)  NOT NULL,
    [Cost]           DECIMAL(10,2) NOT NULL,
    [Price]          DECIMAL(10,2) NOT NULL,
    [StockQuantity]  INT           NOT NULL DEFAULT 0,
    [Unit]           NVARCHAR(50)  NOT NULL,
    [CategoryID]     INT           NULL,
    [Description]    NVARCHAR(MAX) NULL,
    [ImageURL]       NVARCHAR(MAX) NULL,
    [WarrantyPeriod] INT           NOT NULL DEFAULT 0,
    [Status]         NVARCHAR(20)  NOT NULL DEFAULT N'Active',
    [CreatedDate]    DATETIME      NOT NULL DEFAULT GETDATE(),
    [UpdatedDate]    DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_Products]            PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [UQ_Products_SKU]        UNIQUE ([SKU]),
    CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories]([CategoryID]),
    CONSTRAINT [CK_Products_Status]     CHECK ([Status] IN (N'Active', N'Deactivated', N'Deleted'))
);
GO

/* =======================================================================================
   PHẦN 9 - BẢNG LIÊN KẾT NHÀ CUNG CẤP VÀ SẢN PHẨM
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierProduct](
    [SupplierProductID] INT           IDENTITY(1,1) NOT NULL,
    [SupplierID]        INT           NOT NULL,
    [ProductID]         INT           NOT NULL,
    [SupplyPrice]       DECIMAL(10,2) NULL,
    [IsActive]          BIT           NOT NULL DEFAULT 1,
    [CreatedDate]       DATETIME      NOT NULL DEFAULT GETDATE(),
    [UpdatedDate]       DATETIME      NULL,
    CONSTRAINT [PK_SupplierProduct]          PRIMARY KEY CLUSTERED ([SupplierProductID] ASC),
    CONSTRAINT [UQ_SupplierProduct]          UNIQUE ([SupplierID], [ProductID]),
    CONSTRAINT [FK_SupplierProduct_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_SupplierProduct_Products]  FOREIGN KEY ([ProductID])  REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 10 - BẢNG PHIẾU NHẬP KHO
   ======================================================================================= */
CREATE TABLE [dbo].[StockIn](
    [StockInID]          INT           IDENTITY(1,1) NOT NULL,
    [SupplierID]         INT           NOT NULL,
    [Date]               DATETIME      NOT NULL DEFAULT GETDATE(),
    [TotalAmount]        DECIMAL(18,2) NOT NULL DEFAULT 0,
    [InitialPaidAmount]  DECIMAL(18,2) NOT NULL DEFAULT 0,
    [CreatedBy]          INT           NOT NULL,
    [Note]               NVARCHAR(MAX) NULL,
    [StockStatus]        NVARCHAR(20)  NOT NULL DEFAULT N'Pending',
    [PaymentStatus]      NVARCHAR(20)  NOT NULL DEFAULT N'Unpaid',
    [CancelRequestNote]  NVARCHAR(500) NULL,
    [CancelRequestedBy]  INT           NULL,
    [CancelRequestedAt]  DATETIME      NULL,
    [CancelApprovedBy]   INT           NULL,
    [CancelApprovedAt]   DATETIME      NULL,
    CONSTRAINT [PK_StockIn]                   PRIMARY KEY CLUSTERED ([StockInID] ASC),
    CONSTRAINT [FK_StockIn_Supplier]          FOREIGN KEY ([SupplierID])        REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_StockIn_User]              FOREIGN KEY ([CreatedBy])          REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_StockIn_CancelRequestedBy] FOREIGN KEY ([CancelRequestedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_StockIn_CancelApprovedBy]  FOREIGN KEY ([CancelApprovedBy])  REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_StockIn_StockStatus]       CHECK ([StockStatus]   IN (N'Pending', N'Completed', N'CancelRequested', N'Cancelled')),
    CONSTRAINT [CK_StockIn_PaymentStatus]     CHECK ([PaymentStatus] IN (N'Unpaid', N'Partial', N'Paid', N'Cancelled'))
);
GO

/* =======================================================================================
   PHẦN 11 - BẢNG CHI TIẾT PHIẾU NHẬP
   ======================================================================================= */
CREATE TABLE [dbo].[StockInDetails](
    [DetailID]         INT           IDENTITY(1,1) NOT NULL,
    [StockInID]        INT           NOT NULL,
    [ProductID]        INT           NOT NULL,
    [Quantity]         INT           NOT NULL,
    [ReceivedQuantity] INT           NOT NULL DEFAULT 0,
    [UnitCost]         DECIMAL(10,2) NOT NULL,
    [SubTotal]         AS ([Quantity] * [UnitCost]),
    CONSTRAINT [PK_StockInDetails]                    PRIMARY KEY CLUSTERED ([DetailID] ASC),
    CONSTRAINT [CK_StockInDetails_ReceivedQuantity]   CHECK ([ReceivedQuantity] >= 0 AND [ReceivedQuantity] <= [Quantity]),
    CONSTRAINT [FK_StockInDetails_StockIn]            FOREIGN KEY ([StockInID])  REFERENCES [dbo].[StockIn]([StockInID]) ON DELETE CASCADE,
    CONSTRAINT [FK_StockInDetails_Products]           FOREIGN KEY ([ProductID])  REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 12 - VIEW TỔNG HỢP TIẾN ĐỘ NHẬP HÀNG (QUAN TRỌNG ĐỂ XEM DANH SÁCH)
   ======================================================================================= */
CREATE VIEW [dbo].[vw_StockInProgress]
AS
SELECT
    si.[StockInID],
    si.[SupplierID],
    sup.[Name]                                                      AS [SupplierName],
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
    SUM(ISNULL(sid.[Quantity], 0))                                  AS [TotalOrderedQuantity],
    SUM(ISNULL(sid.[ReceivedQuantity], 0))                         AS [TotalReceivedQuantity],
    SUM(ISNULL(sid.[Quantity], 0) - ISNULL(sid.[ReceivedQuantity], 0)) AS [TotalRemainingQuantity],
    SUM(ISNULL(sid.[Quantity] * sid.[UnitCost], 0))                AS [TotalAmountCalculated]
FROM [dbo].[StockIn] si
LEFT JOIN [dbo].[StockInDetails] sid ON si.[StockInID] = sid.[StockInID]
LEFT JOIN [dbo].[Suppliers]      sup ON si.[SupplierID] = sup.[SupplierID]
GROUP BY
    si.[StockInID], si.[SupplierID], sup.[Name], si.[Date], si.[CreatedBy],
    si.[Note], si.[StockStatus], si.[PaymentStatus],
    si.[CancelRequestNote], si.[CancelRequestedBy], si.[CancelRequestedAt],
    si.[CancelApprovedBy], si.[CancelApprovedAt];
GO

/* =======================================================================================
   PHẦN 13 - PROCEDURES CẬP NHẬT / NHẬN HÀNG PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_RefreshStockInStatus]
    @StockInID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentStatus NVARCHAR(20);
    DECLARE @TotalQty      INT;
    DECLARE @TotalReceived INT;

    SELECT @CurrentStatus = [StockStatus] FROM [dbo].[StockIn] WHERE [StockInID] = @StockInID;
    IF @CurrentStatus IS NULL RETURN;
    IF @CurrentStatus IN (N'CancelRequested', N'Cancelled') RETURN;

    SELECT
        @TotalQty      = ISNULL(SUM([Quantity]), 0),
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

CREATE PROCEDURE [dbo].[sp_ReceiveStockInDetail]
    @DetailID   INT,
    @ReceiveQty INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @StockInID    INT;
    DECLARE @ProductID    INT;
    DECLARE @RemainingQty INT;

    IF @ReceiveQty IS NULL OR @ReceiveQty <= 0
    BEGIN RAISERROR(N'Số lượng nhận phải lớn hơn 0.', 16, 1); RETURN; END

    SELECT
        @StockInID    = [StockInID],
        @ProductID    = [ProductID],
        @RemainingQty = [Quantity] - [ReceivedQuantity]
    FROM [dbo].[StockInDetails]
    WHERE [DetailID] = @DetailID;

    IF @StockInID IS NULL
    BEGIN RAISERROR(N'Không tìm thấy chi tiết phiếu nhập.', 16, 1); RETURN; END

    IF @ReceiveQty > @RemainingQty
    BEGIN RAISERROR(N'Số lượng nhận vượt quá số lượng còn thiếu.', 16, 1); RETURN; END

    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE [dbo].[StockInDetails]
        SET [ReceivedQuantity] = [ReceivedQuantity] + @ReceiveQty
        WHERE [DetailID] = @DetailID;

        UPDATE [dbo].[Products]
        SET [StockQuantity] = [StockQuantity] + @ReceiveQty, [UpdatedDate] = GETDATE()
        WHERE [ProductID] = @ProductID;

        EXEC [dbo].[sp_RefreshStockInStatus] @StockInID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* =======================================================================================
   PHẦN 14 - PROCEDURES HỦY PHIẾU NHẬP
   ======================================================================================= */
CREATE PROCEDURE [dbo].[sp_RequestCancelStockIn]
    @StockInID INT,
    @UserID    INT,
    @Reason    NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (
            SELECT 1 FROM StockIn
            WHERE StockInID = @StockInID AND StockStatus = 'Pending'
        )
        BEGIN
            RAISERROR(N'Chỉ có thể yêu cầu hủy phiếu đang Pending.', 16, 1);
            ROLLBACK TRANSACTION; RETURN;
        END

        UPDATE StockIn
        SET StockStatus       = 'CancelRequested',
            CancelRequestNote = @Reason,
            CancelRequestedBy = @UserID,
            CancelRequestedAt = GETDATE()
        WHERE StockInID = @StockInID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_ApproveCancelStockIn]
    @StockInID INT,
    @ManagerID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (
            SELECT 1 FROM StockIn
            WHERE StockInID = @StockInID AND StockStatus = 'CancelRequested'
        )
        BEGIN
            RAISERROR(N'Phiếu nhập không ở trạng thái chờ duyệt hủy.', 16, 1);
            ROLLBACK TRANSACTION; RETURN;
        END

        UPDATE StockIn
        SET StockStatus     = 'Cancelled',
            PaymentStatus   = 'Cancelled',
            CancelApprovedBy  = @ManagerID,
            CancelApprovedAt  = GETDATE()
        WHERE StockInID = @StockInID;

        UPDATE SupplierDebts
        SET Status = 'Cancelled'
        WHERE StockInID = @StockInID
          AND Status IN ('Pending', 'Partial', 'Paid', 'Overdue');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE [dbo].[sp_RejectCancelStockIn]
    @StockInID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (
            SELECT 1 FROM StockIn
            WHERE StockInID = @StockInID AND StockStatus = 'CancelRequested'
        )
        BEGIN
            RAISERROR(N'Phiếu nhập không ở trạng thái chờ duyệt hủy.', 16, 1);
            ROLLBACK TRANSACTION; RETURN;
        END

        UPDATE StockIn
        SET StockStatus       = 'Pending',
            CancelRequestNote = NULL,
            CancelRequestedBy = NULL,
            CancelRequestedAt = NULL
        WHERE StockInID = @StockInID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

/* =======================================================================================
   PHẦN 15 - BẢNG PHIẾU XUẤT / BÁN HÀNG
   ======================================================================================= */
CREATE TABLE [dbo].[StockOut](
    [StockOutID]  INT           IDENTITY(1,1) NOT NULL,
    [CustomerID]  INT           NULL,
    [Date]        DATETIME      NOT NULL DEFAULT GETDATE(),
    [TotalAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [CreatedBy]   INT           NOT NULL,
    [Note]        NVARCHAR(MAX) NULL,
    [Status]      NVARCHAR(20)  NOT NULL DEFAULT N'Completed',
    CONSTRAINT [PK_StockOut]           PRIMARY KEY CLUSTERED ([StockOutID] ASC),
    CONSTRAINT [FK_StockOut_Customers] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_StockOut_User]      FOREIGN KEY ([CreatedBy])  REFERENCES [dbo].[User]([UserID])
);
GO

CREATE TABLE [dbo].[StockOutDetails](
    [DetailID]   INT           IDENTITY(1,1) NOT NULL,
    [StockOutID] INT           NOT NULL,
    [ProductID]  INT           NOT NULL,
    [Quantity]   INT           NOT NULL,
    [UnitPrice]  DECIMAL(10,2) NOT NULL,
    [SubTotal]   AS ([Quantity] * [UnitPrice]),
    CONSTRAINT [PK_StockOutDetails]         PRIMARY KEY CLUSTERED ([DetailID] ASC),
    CONSTRAINT [FK_StockOutDetails_StockOut] FOREIGN KEY ([StockOutID]) REFERENCES [dbo].[StockOut]([StockOutID]) ON DELETE CASCADE,
    CONSTRAINT [FK_StockOutDetails_Products] FOREIGN KEY ([ProductID])  REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 16 - CÁC BẢNG QUẢN LÝ KHÁC
   ======================================================================================= */
CREATE TABLE [dbo].[WarrantyTickets](
    [TicketID]         INT           IDENTITY(1,1) NOT NULL,
    [StockOutID]       INT           NOT NULL,
    [ProductID]        INT           NOT NULL,
    [CustomerID]       INT           NOT NULL,
    [ReceiveDate]      DATETIME      NOT NULL DEFAULT GETDATE(),
    [ReturnDate]       DATETIME      NULL,
    [IssueDescription] NVARCHAR(MAX) NULL,
    [Solution]         NVARCHAR(MAX) NULL,
    [Status]           NVARCHAR(20)  NOT NULL DEFAULT N'Received',
    [CreatedBy]        INT           NOT NULL,
    CONSTRAINT [PK_WarrantyTickets]          PRIMARY KEY CLUSTERED ([TicketID] ASC),
    CONSTRAINT [FK_WarrantyTickets_StockOut]  FOREIGN KEY ([StockOutID])  REFERENCES [dbo].[StockOut]([StockOutID]),
    CONSTRAINT [FK_WarrantyTickets_Products]  FOREIGN KEY ([ProductID])   REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_WarrantyTickets_Customers] FOREIGN KEY ([CustomerID])  REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_WarrantyTickets_User]      FOREIGN KEY ([CreatedBy])   REFERENCES [dbo].[User]([UserID])
);
GO

CREATE TABLE [dbo].[StockAdjustments](
    [AdjustmentID] INT          IDENTITY(1,1) NOT NULL,
    [ProductID]    INT          NOT NULL,
    [Quantity]     INT          NOT NULL,
    [ReasonCode]   NVARCHAR(50) NOT NULL,
    [Date]         DATETIME     NOT NULL DEFAULT GETDATE(),
    [CreatedBy]    INT          NOT NULL,
    [Status]       NVARCHAR(20) NOT NULL DEFAULT N'Approved',
    CONSTRAINT [PK_StockAdjustments]         PRIMARY KEY CLUSTERED ([AdjustmentID] ASC),
    CONSTRAINT [FK_StockAdjustments_Products] FOREIGN KEY ([ProductID])  REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_StockAdjustments_User]     FOREIGN KEY ([CreatedBy])  REFERENCES [dbo].[User]([UserID])
);
GO

CREATE TABLE [dbo].[LowStockAlerts](
    [AlertID]       INT IDENTITY(1,1) NOT NULL,
    [ProductID]     INT NOT NULL,
    [MinStockLevel] INT NOT NULL,
    [Notified]      BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_LowStockAlerts]          PRIMARY KEY CLUSTERED ([AlertID] ASC),
    CONSTRAINT [FK_LowStockAlerts_Products]  FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 17 - BẢNG KIỂM KÊ KHO (LƯU Ý: ĐÃ THÊM CreatedBy VÀ KHÓA NGOẠI)
   ======================================================================================= */
CREATE TABLE [dbo].[InventoryCounts](
    [CountID]          INT           IDENTITY(1,1) NOT NULL,
    [ProductID]        INT           NOT NULL,
    [PhysicalQuantity] INT           NOT NULL,
    [SystemQuantity]   INT           NOT NULL,
    [Date]             DATETIME      NOT NULL DEFAULT GETDATE(),
    [ApprovedBy]       INT           NULL,
    [Status]           NVARCHAR(20)  NOT NULL DEFAULT N'Pending',
    [SessionCode]      NVARCHAR(50)  NULL,
    [Reason]           NVARCHAR(500) NULL,
    [CreatedBy]        INT           NULL,
    [ApprovedAt]       DATETIME      NULL,
    CONSTRAINT [PK_InventoryCounts]          PRIMARY KEY CLUSTERED ([CountID] ASC),
    CONSTRAINT [FK_InventoryCounts_Products]  FOREIGN KEY ([ProductID])   REFERENCES [dbo].[Products]([ProductID]),
    CONSTRAINT [FK_InventoryCounts_User]      FOREIGN KEY ([ApprovedBy])  REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [FK_InventoryCounts_Creator]   FOREIGN KEY ([CreatedBy])   REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 18 - CÔNG NỢ & THANH TOÁN
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierDebts](
    [DebtID]     INT           IDENTITY(1,1) NOT NULL,
    [SupplierID] INT           NOT NULL,
    [StockInID]  INT           NOT NULL,
    [Amount]     DECIMAL(18,2) NOT NULL,
    [DueDate]    DATE          NULL,
    [Status]     NVARCHAR(20)  NOT NULL DEFAULT N'Pending',
    CONSTRAINT [PK_SupplierDebts]           PRIMARY KEY CLUSTERED ([DebtID] ASC),
    CONSTRAINT [FK_SupplierDebts_Suppliers]  FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID]),
    CONSTRAINT [FK_SupplierDebts_StockIn]    FOREIGN KEY ([StockInID])  REFERENCES [dbo].[StockIn]([StockInID])
);
GO

CREATE TABLE [dbo].[SupplierDebtPayment](
    [PaymentID]   INT           IDENTITY(1,1) PRIMARY KEY,
    [DebtID]      INT           NOT NULL,
    [Amount]      DECIMAL(18,2) NOT NULL,
    [PaymentDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    [Note]        NVARCHAR(500) NULL,
    [CreatedBy]   INT           NOT NULL,
    CONSTRAINT [FK_SupplierDebtPayment_Debt] FOREIGN KEY ([DebtID])     REFERENCES [dbo].[SupplierDebts]([DebtID]),
    CONSTRAINT [FK_SupplierDebtPayment_User] FOREIGN KEY ([CreatedBy])  REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 18A - NHẬT KÝ GỬI NHẮC NỢ NHÀ CUNG CẤP  [PATCH MERGE]
   ĐÃ THÊM: bảng SupplierDebtReminderAudit để audit việc gửi nhắc nợ
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierDebtReminderAudit](
    [AuditID]       INT           IDENTITY(1,1) NOT NULL,
    [DebtID]        INT           NOT NULL,
    [UserID]        INT           NOT NULL,
    [ReminderType]  NVARCHAR(30)  NOT NULL,
    [SentAt]        DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_SupplierDebtReminderAudit]          PRIMARY KEY CLUSTERED ([AuditID] ASC),
    CONSTRAINT [FK_SupplierDebtReminderAudit_Debt]     FOREIGN KEY ([DebtID]) REFERENCES [dbo].[SupplierDebts]([DebtID]),
    CONSTRAINT [FK_SupplierDebtReminderAudit_User]     FOREIGN KEY ([UserID]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [UQ_SupplierDebtReminderAudit]          UNIQUE ([DebtID], [UserID], [ReminderType])
);
GO

-- [PATCH MERGE] Thêm trigger chặn tổng công nợ đang mở của 1 supplier vượt 1 tỷ
CREATE TRIGGER [dbo].[TR_SupplierDebts_EnforceMaxOutstanding]
ON [dbo].[SupplierDebts]
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM (
            SELECT [SupplierID],
                   SUM(CASE WHEN [Status] IN (N'Pending', N'Partial', N'Overdue') THEN [Amount] ELSE 0 END) AS [Outstanding]
            FROM [dbo].[SupplierDebts]
            WHERE [SupplierID] IN (SELECT DISTINCT [SupplierID] FROM inserted)
            GROUP BY [SupplierID]
        ) x
        WHERE x.[Outstanding] > 1000000000
    )
    BEGIN
        RAISERROR(N'Tổng công nợ đang mở của một nhà cung cấp không được vượt quá 1.000.000.000.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TABLE [dbo].[DebtPayments](
    [PaymentId]   INT            IDENTITY(1,1) PRIMARY KEY,
    [CustomerId]  INT            NULL,
    [Amount]      DECIMAL(18,2)  NOT NULL,
    [StaffId]     INT            NULL,
    [Note]        NVARCHAR(MAX)  NULL,
    [PaymentDate] DATETIME       NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_DebtPayments_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers]([CustomerID])
);
GO

CREATE TABLE [dbo].[DebtPaymentHistory](
    [Id]          INT           IDENTITY(1,1) PRIMARY KEY,
    [CustomerId]  INT           NOT NULL,
    [Amount]      DECIMAL(18,2) NOT NULL,
    [StaffId]     INT           NOT NULL,
    [Note]        NVARCHAR(255) NULL,
    [PaymentDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_DebtPaymentHistory_Customers] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customers]([CustomerID]),
    CONSTRAINT [FK_DebtPaymentHistory_User]      FOREIGN KEY ([StaffId])    REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 19 - TRẢ HÀNG & LỊCH SỬ
   ======================================================================================= */
CREATE TABLE [dbo].[CustomerReturns](
    [ReturnID]     INT           IDENTITY(1,1) NOT NULL,
    [StockOutID]   INT           NOT NULL,
    [ProductID]    INT           NOT NULL,
    [Quantity]     INT           NOT NULL,
    [Reason]       NVARCHAR(255) NULL,
    [Date]         DATETIME      NOT NULL DEFAULT GETDATE(),
    [RefundAmount] DECIMAL(10,2) NULL,
    CONSTRAINT [PK_CustomerReturns]           PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    CONSTRAINT [FK_CustomerReturns_StockOut]   FOREIGN KEY ([StockOutID]) REFERENCES [dbo].[StockOut]([StockOutID]),
    CONSTRAINT [FK_CustomerReturns_Products]   FOREIGN KEY ([ProductID])  REFERENCES [dbo].[Products]([ProductID])
);
GO

CREATE TABLE [dbo].[ReturnToVendors] (
    [RTVID] INT IDENTITY(1,1) PRIMARY KEY,
    [ReturnCode] NVARCHAR(50) NOT NULL,
    [SupplierID] INT NOT NULL,
    [StockInID] INT NOT NULL,
    [CreatedBy] INT NOT NULL,
    [ApprovedBy] INT NULL,
    [CompletedBy] INT NULL,
    [CreatedDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [ApprovedDate] DATETIME NULL,
    [CompletedDate] DATETIME NULL,
    [Status] NVARCHAR(30) NOT NULL DEFAULT 'Pending',
    [Reason] NVARCHAR(255) NULL,
    [Note] NVARCHAR(500) NULL,
    [TotalAmount] DECIMAL(18,2) NOT NULL DEFAULT 0,
    [SettlementType] NVARCHAR(30) NULL, -- REFUND / OFFSET_DEBT / REPLACEMENT
    [RelatedDebtID] INT NULL,
    [IsInventoryAdjusted] BIT NOT NULL DEFAULT 0,
    [IsFinancialAdjusted] BIT NOT NULL DEFAULT 0,

    CONSTRAINT FK_RTV_Supplier FOREIGN KEY ([SupplierID]) REFERENCES [Suppliers]([SupplierID]),
    CONSTRAINT FK_RTV_StockIn FOREIGN KEY ([StockInID]) REFERENCES [StockIn]([StockInID]),
    CONSTRAINT FK_RTV_CreatedBy FOREIGN KEY ([CreatedBy]) REFERENCES [User]([UserID]),
    CONSTRAINT FK_RTV_ApprovedBy FOREIGN KEY ([ApprovedBy]) REFERENCES [User]([UserID]),
    CONSTRAINT FK_RTV_CompletedBy FOREIGN KEY ([CompletedBy]) REFERENCES [User]([UserID]),
    CONSTRAINT FK_RTV_RelatedDebt FOREIGN KEY ([RelatedDebtID]) REFERENCES [SupplierDebts]([DebtID])
);
GO

CREATE TABLE [dbo].[ReturnToVendorDetails] (
    [RTVDetailID] INT IDENTITY(1,1) PRIMARY KEY,
    [RTVID] INT NOT NULL,
    [StockInDetailID] INT NOT NULL,
    [ProductID] INT NOT NULL,
    [Quantity] INT NOT NULL,
    [UnitCost] DECIMAL(18,2) NOT NULL,
    [LineTotal] DECIMAL(18,2) NOT NULL,
    [ReasonDetail] NVARCHAR(255) NULL,
    [ItemCondition] NVARCHAR(100) NULL,

    CONSTRAINT FK_RTVDetail_RTV FOREIGN KEY ([RTVID]) REFERENCES [ReturnToVendors]([RTVID]),
    CONSTRAINT FK_RTVDetail_StockInDetail FOREIGN KEY ([StockInDetailID]) REFERENCES [StockInDetails]([DetailID]),
    CONSTRAINT FK_RTVDetail_Product FOREIGN KEY ([ProductID]) REFERENCES [Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 19A - NHẬN HÀNG THAY THẾ CHO RTV  [PATCH MERGE]
   ĐÃ THÊM: bảng RTVReplacementReceipts để theo dõi số lượng hàng thay thế nhà cung cấp đã giao lại
   ======================================================================================= */
CREATE TABLE [dbo].[RTVReplacementReceipts](
    [ReceiptID]     INT           IDENTITY(1,1) NOT NULL,
    [RTVDetailID]   INT           NOT NULL,
    [Quantity]      INT           NOT NULL,
    [ReceivedDate]  DATETIME      NOT NULL DEFAULT GETDATE(),
    [Note]          NVARCHAR(500) NULL,
    [CreatedBy]     INT           NOT NULL,
    CONSTRAINT [PK_RTVReplacementReceipts]             PRIMARY KEY CLUSTERED ([ReceiptID] ASC),
    CONSTRAINT [FK_RTVReplacementReceipts_RTVDetail]   FOREIGN KEY ([RTVDetailID]) REFERENCES [dbo].[ReturnToVendorDetails]([RTVDetailID]),
    CONSTRAINT [FK_RTVReplacementReceipts_User]        FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID]),
    CONSTRAINT [CK_RTVReplacementReceipts_Qty]         CHECK ([Quantity] > 0)
);
GO

-- [PATCH MERGE] Thêm index phục vụ thống kê/tra cứu phiếu nhận hàng thay thế theo dòng RTV
CREATE NONCLUSTERED INDEX [IX_RTVReplacementReceipts_RTVDetailID]
    ON [dbo].[RTVReplacementReceipts]([RTVDetailID], [ReceivedDate] DESC);
GO

CREATE TABLE [dbo].[ProductHistories](
    [HistoryID]       INT          IDENTITY(1,1) NOT NULL,
    [ProductID]       INT          NOT NULL,
    [TransactionType] NVARCHAR(50) NOT NULL,
    [Quantity]        INT          NOT NULL,
    [Date]            DATETIME     NOT NULL DEFAULT GETDATE(),
    [ReferenceID]     INT          NULL,
    CONSTRAINT [PK_ProductHistories]          PRIMARY KEY CLUSTERED ([HistoryID] ASC),
    CONSTRAINT [FK_ProductHistories_Products]  FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 19B - BẢNG BẢO HÀNH / ĐỔI TRẢ (khớp entity/DAO trong code)
   ======================================================================================= */
CREATE TABLE [dbo].[WarrantyClaims](
    [ClaimID]          INT            IDENTITY(1,1) NOT NULL,
    [ClaimCode]       NVARCHAR(50)  NULL,
    [SKU]              NVARCHAR(50)  NOT NULL,
    [ProductName]      NVARCHAR(255) NOT NULL,
    [CustomerName]     NVARCHAR(100) NOT NULL,
    [CustomerPhone]    NVARCHAR(20)  NOT NULL,
    [IssueDescription] NVARCHAR(MAX) NULL,
    [Status]           NVARCHAR(30)  NOT NULL DEFAULT N'NEW',
    [CreatedAt]        DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]        DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_WarrantyClaims] PRIMARY KEY CLUSTERED ([ClaimID] ASC),
    CONSTRAINT [FK_WarrantyClaims_Products] FOREIGN KEY ([SKU]) REFERENCES [dbo].[Products]([SKU])
);
GO

CREATE TABLE [dbo].[WarrantyClaimEvents](
    [EventID]   INT           IDENTITY(1,1) NOT NULL,
    [ClaimID]   INT           NOT NULL,
    [EventTime] DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    [Actor]     NVARCHAR(100) NOT NULL,
    [Action]    NVARCHAR(50)  NOT NULL,
    [Note]      NVARCHAR(MAX) NULL,
    CONSTRAINT [PK_WarrantyClaimEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_WarrantyClaimEvents_Claims] FOREIGN KEY ([ClaimID]) REFERENCES [dbo].[WarrantyClaims]([ClaimID]) ON DELETE CASCADE
);
GO

CREATE TABLE [dbo].[ReturnRequests](
    [ReturnID]        INT           IDENTITY(1,1) NOT NULL,
    [ReturnCode]      NVARCHAR(50)  NULL,
    [SKU]             NVARCHAR(50)  NOT NULL,
    [ProductName]     NVARCHAR(255) NOT NULL,
    [CustomerName]    NVARCHAR(100) NOT NULL,
    [CustomerPhone]   NVARCHAR(20)  NOT NULL,
    [Reason]          NVARCHAR(MAX) NULL,
    [ConditionNote]   NVARCHAR(MAX) NULL,
    [Status]          NVARCHAR(30)  NOT NULL DEFAULT N'NEW',
    [RefundAmount]    DECIMAL(18,2) NULL,
    [RefundMethod]    NVARCHAR(50)  NULL,
    [RefundReference] NVARCHAR(100) NULL,
    [RefundedAt]      DATETIME2(3)  NULL,
    [CreatedAt]       DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]       DATETIME2(3)  NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_ReturnRequests] PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    CONSTRAINT [FK_ReturnRequests_Products] FOREIGN KEY ([SKU]) REFERENCES [dbo].[Products]([SKU])
);
GO

CREATE TABLE [dbo].[ReturnEvents](
    [EventID]   INT           IDENTITY(1,1) NOT NULL,
    [ReturnID]  INT           NOT NULL,
    [EventTime] DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    [Actor]     NVARCHAR(100) NOT NULL,
    [Action]    NVARCHAR(50)  NOT NULL,
    [Note]      NVARCHAR(MAX) NULL,
    CONSTRAINT [PK_ReturnEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_ReturnEvents_ReturnRequests] FOREIGN KEY ([ReturnID]) REFERENCES [dbo].[ReturnRequests]([ReturnID]) ON DELETE CASCADE
);
GO

/* =======================================================================================
   PHẦN 20 - DỮ LIỆU MẪU (ROLE & USERS & DATA)
   ======================================================================================= */
INSERT INTO [dbo].[Role] ([RoleID], [RoleName]) VALUES
(0, N'Admin'),
(1, N'Warehouse Staff'),
(2, N'Manager'),
(3, N'Salesperson');
GO

-- Password mặc định: '123' (hash md5: 202cb962ac59075b964b07152d234b70)
INSERT INTO [dbo].[User] ([Username], [PasswordHash], [FullName], [RoleID], [Email], [Phone], [IsActive]) VALUES
(N'admin',   N'202cb962ac59075b964b07152d234b70', N'Hệ Thống Admin', 0, N'admin@sim.com',   N'000', 1),
(N'manager', N'202cb962ac59075b964b07152d234b70', N'Nguyễn Quản Lý', 2, N'manager@sim.com', N'111', 1),
(N'staff',   N'202cb962ac59075b964b07152d234b70', N'Trần Nhân Viên', 1, N'staff@sim.com',   N'222', 1),
(N'sale',    N'202cb962ac59075b964b07152d234b70', N'Lê Bán Hàng',   3, N'sale@sim.com',    N'333', 1);
GO

INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [ParentID]) VALUES
(N'Điện tử - Điện lạnh', NULL, NULL),
(N'Gia dụng nhà bếp',    NULL, NULL);
GO

INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [ParentID]) VALUES
(N'Tủ lạnh',       NULL, 1),
(N'Máy giặt',      NULL, 1),
(N'Nồi cơm điện',  NULL, 2),
(N'Bếp từ',        NULL, 2);
GO

-- [PATCH MERGE] Chèn trực tiếp trạng thái xác thực email cho dữ liệu mẫu supplier, thay cho câu lệnh UPDATE trong file patch
INSERT INTO [dbo].[Suppliers] ([Name], [Phone], [Address], [Email], [IsActive], [IsEmailVerified], [VerificationStatus]) VALUES
(N'Samsung Vina',      N'0901234567', N'TP.HCM',  N'samsung@supplier.com', 1, 1, N'Verified'),
(N'Sharp Việt Nam',    N'0912345678', N'Hà Nội',  N'sharp@supplier.com',   1, 1, N'Verified');
GO

INSERT INTO [dbo].[Customers] ([Name], [Phone], [Address], [Email]) VALUES
(N'Khách lẻ', N'0387654321', N'Tại quầy', NULL);
GO

INSERT INTO [dbo].[Products] ([Name], [SKU], [Cost], [Price], [StockQuantity], [Unit], [CategoryID], [Description], [WarrantyPeriod], [Status]) VALUES
(N'Tủ lạnh Samsung Inverter 208L', N'SS-208L',   5000000, 6500000, 10, N'Cái', 3, NULL, 24, N'Active'),
(N'Nồi cơm điện Sharp 1.8L',      N'SHARP-18',   600000,  850000, 20, N'Cái', 5, NULL, 12, N'Active');
GO

INSERT INTO [dbo].[SupplierProduct] ([SupplierID], [ProductID], [SupplyPrice], [IsActive]) VALUES
(1, 1, 5000000, 1),
(2, 2,  600000, 1);
GO

/* =======================================================================================
   DỮ LIỆU MẪU: Bảo hành / Đổi trả (5 dòng / mỗi bảng)
   ======================================================================================= */
SET IDENTITY_INSERT [dbo].[WarrantyClaims] ON;
INSERT INTO [dbo].[WarrantyClaims] (
    [ClaimID], [ClaimCode], [SKU], [ProductName], [CustomerName], [CustomerPhone],
    [IssueDescription], [Status], [CreatedAt], [UpdatedAt]
) VALUES
(1, N'WC-1', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Lỗi quạt/khả năng làm lạnh', N'NEW', DATEADD(day, -12, SYSUTCDATETIME()), DATEADD(day, -3, SYSUTCDATETIME())),
(2, N'WC-2', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Bảng điều khiển nháy', N'RECEIVED', DATEADD(day, -11, SYSUTCDATETIME()), DATEADD(day, -2, SYSUTCDATETIME())),
(3, N'WC-3', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321',
    N'Không giữ nhiệt', N'IN_REPAIR', DATEADD(day, -10, SYSUTCDATETIME()), DATEADD(day, -6, SYSUTCDATETIME())),
(4, N'WC-4', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321',
    N'Bị chập nguồn', N'APPROVED', DATEADD(day, -9, SYSUTCDATETIME()), DATEADD(day, -1, SYSUTCDATETIME())),
(5, N'WC-5', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Rò rỉ nước', N'REJECTED', DATEADD(day, -8, SYSUTCDATETIME()), DATEADD(day, -4, SYSUTCDATETIME()));
SET IDENTITY_INSERT [dbo].[WarrantyClaims] OFF;
GO

INSERT INTO [dbo].[WarrantyClaimEvents] ([ClaimID], [EventTime], [Actor], [Action], [Note]) VALUES
(1, DATEADD(day, -3, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu bảo hành'),
(2, DATEADD(day, -2, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu bảo hành'),
(3, DATEADD(day, -6, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu bảo hành'),
(4, DATEADD(day, -1, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu bảo hành'),
(5, DATEADD(day, -4, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu bảo hành');
GO

SET IDENTITY_INSERT [dbo].[ReturnRequests] ON;
INSERT INTO [dbo].[ReturnRequests] (
    [ReturnID], [ReturnCode], [SKU], [ProductName], [CustomerName], [CustomerPhone],
    [Reason], [ConditionNote], [Status],
    [RefundAmount], [RefundMethod], [RefundReference], [RefundedAt],
    [CreatedAt], [UpdatedAt]
) VALUES
(1, N'RT-1', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Lỗi vận hành', N'Đã kiểm tra ngoại quan', N'NEW',
    NULL, NULL, NULL, NULL,
    DATEADD(day, -7, SYSUTCDATETIME()), DATEADD(day, -1, SYSUTCDATETIME())),
(2, N'RT-2', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Ký gửi nhầm', N'Chưa sử dụng', N'APPROVED',
    NULL, NULL, NULL, NULL,
    DATEADD(day, -6, SYSUTCDATETIME()), DATEADD(day, -2, SYSUTCDATETIME())),
(3, N'RT-3', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321',
    N'Không lên điện', N'Có mùi khét nhẹ', N'RECEIVED',
    NULL, NULL, NULL, NULL,
    DATEADD(day, -5, SYSUTCDATETIME()), DATEADD(day, -4, SYSUTCDATETIME())),
(4, N'RT-4', N'SHARP-18', N'Nồi cơm điện Sharp 1.8L', N'Khách lẻ', N'0387654321',
    N'Hỏng sau 3 ngày', N'Đã đóng gói lại', N'REFUNDED',
    850000, N'Tiền mặt', N'', SYSUTCDATETIME(),
    DATEADD(day, -4, SYSUTCDATETIME()), DATEADD(day, -3, SYSUTCDATETIME())),
(5, N'RT-5', N'SS-208L', N'Tủ lạnh Samsung Inverter 208L', N'Khách lẻ', N'0387654321',
    N'Xin hủy yêu cầu', N'', N'CANCELLED',
    NULL, NULL, NULL, NULL,
    DATEADD(day, -3, SYSUTCDATETIME()), DATEADD(day, -5, SYSUTCDATETIME()));
SET IDENTITY_INSERT [dbo].[ReturnRequests] OFF;
GO

INSERT INTO [dbo].[ReturnEvents] ([ReturnID], [EventTime], [Actor], [Action], [Note]) VALUES
(1, DATEADD(day, -1, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu trả hàng'),
(2, DATEADD(day, -2, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu trả hàng'),
(3, DATEADD(day, -4, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu trả hàng'),
(4, DATEADD(day, -3, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu trả hàng'),
(5, DATEADD(day, -5, SYSUTCDATETIME()), N'system', N'CREATE', N'Tạo yêu cầu trả hàng');
GO

SELECT N'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS [Status];
GO
