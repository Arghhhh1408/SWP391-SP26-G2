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
   PHẦN 4 - BẢNG THÔNG BÁO  ← ĐÃ SỬA 3 CỘT
   ======================================================================================= */
CREATE TABLE [dbo].[Notifications](
    [NotificationID] INT           IDENTITY(1,1) NOT NULL,
    [UserID]         INT           NOT NULL,

    -- CHANGED: 100 → 255 (tiêu đề có thể dài)
    [Title]          NVARCHAR(255) NOT NULL,

    -- CHANGED: NVARCHAR(255) → NVARCHAR(MAX) (nội dung đa dòng, nhiều sản phẩm)
    [Message]        NVARCHAR(MAX) NULL,

    [IsRead]         BIT           NOT NULL DEFAULT 0,
    [CreatedAt]      DATETIME      NOT NULL DEFAULT GETDATE(),

    -- CHANGED: NVARCHAR(20) → NVARCHAR(50)
    -- Vì 'STOCKIN_CANCEL_REQUEST' = 22 ký tự → vượt 20 → INSERT lỗi!
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
    [SupplierID] INT           IDENTITY(1,1) NOT NULL,
    [Name]       NVARCHAR(100) NOT NULL,
    [Phone]      NVARCHAR(20)  NULL,
    [Address]    NVARCHAR(255) NULL,
    [Email]      NVARCHAR(100) NULL,
    [IsActive]   BIT           NOT NULL DEFAULT 1,
    CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED ([SupplierID] ASC)
);
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
   PHẦN 12 - VIEW TỔNG HỢP TIẾN ĐỘ NHẬP HÀNG
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
   PHẦN 13 - PROCEDURE CẬP NHẬT TRẠNG THÁI PHIẾU NHẬP
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

/* =======================================================================================
   PHẦN 14 - PROCEDURE NHẬN HÀNG TỪNG PHẦN
   ======================================================================================= */
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
   PHẦN 15 - PROCEDURE GỬI YÊU CẦU HỦY PHIẾU NHẬP
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

/* =======================================================================================
   PHẦN 16 - PROCEDURE DUYỆT HỦY PHIẾU NHẬP
   ======================================================================================= */
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

/* =======================================================================================
   PHẦN 17 - PROCEDURE TỪ CHỐI HỦY PHIẾU NHẬP
   ======================================================================================= */
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
   PHẦN 18 - BẢNG PHIẾU XUẤT / BÁN HÀNG
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

/* =======================================================================================
   PHẦN 19 - BẢNG CHI TIẾT PHIẾU XUẤT
   ======================================================================================= */
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
   PHẦN 20 - BẢNG BẢO HÀNH
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

/* =======================================================================================
   PHẦN 20B - BẢNG YÊU CẦU BẢO HÀNH (WarrantyClaims – khớp WarrantyClaimDAO / entity WarrantyClaim)
   ======================================================================================= */
CREATE TABLE [dbo].[WarrantyClaims](
    [ClaimID]          INT            IDENTITY(1,1) NOT NULL,
    [ClaimCode]        NVARCHAR(50)   NULL,
    [SKU]              NVARCHAR(50)   NOT NULL,
    [ProductName]      NVARCHAR(255)  NOT NULL,
    [CustomerName]     NVARCHAR(100)  NOT NULL,
    [CustomerPhone]    NVARCHAR(20)   NOT NULL,
    [IssueDescription] NVARCHAR(MAX)  NULL,
    [Status]           NVARCHAR(30)   NOT NULL DEFAULT N'NEW',
    [CreatedAt]        DATETIME2(3)   NOT NULL CONSTRAINT [DF_WarrantyClaims_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]        DATETIME2(3)   NOT NULL CONSTRAINT [DF_WarrantyClaims_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_WarrantyClaims] PRIMARY KEY CLUSTERED ([ClaimID] ASC)
);
GO

CREATE TABLE [dbo].[WarrantyClaimEvents](
    [EventID]   INT            IDENTITY(1,1) NOT NULL,
    [ClaimID]   INT            NOT NULL,
    [EventTime] DATETIME2(3)   NOT NULL CONSTRAINT [DF_WarrantyClaimEvents_EventTime] DEFAULT SYSUTCDATETIME(),
    [Actor]     NVARCHAR(100)  NOT NULL,
    [Action]    NVARCHAR(50)   NOT NULL,
    [Note]      NVARCHAR(MAX)  NULL,
    CONSTRAINT [PK_WarrantyClaimEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_WarrantyClaimEvents_Claim] FOREIGN KEY ([ClaimID]) REFERENCES [dbo].[WarrantyClaims]([ClaimID]) ON DELETE CASCADE
);
GO

/* =======================================================================================
   PHẦN 21 - BẢNG ĐIỀU CHỈNH KHO
   ======================================================================================= */
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

/* =======================================================================================
   PHẦN 22 - BẢNG CẢNH BÁO TỒN KHO THẤP
   ======================================================================================= */
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
   PHẦN 23 - BẢNG KIỂM KÊ KHO
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
    CONSTRAINT [FK_InventoryCounts_User]      FOREIGN KEY ([ApprovedBy])  REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 24 - BẢNG CÔNG NỢ NHÀ CUNG CẤP
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

/* =======================================================================================
   PHẦN 24B - CÔNG NỢ PHIẾU NHẬP (SupplierDebt – khớp StockInDAO.insertStockInWithDetailsAndDebt)
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierDebt](
    [DebtID]      INT           IDENTITY(1,1) NOT NULL,
    [StockInID]   INT           NOT NULL,
    [SupplierID]  INT           NOT NULL,
    [DebtAmount]  DECIMAL(18,2) NOT NULL,
    [PaidAmount]  DECIMAL(18,2) NOT NULL DEFAULT 0,
    [Status]      NVARCHAR(20)  NOT NULL DEFAULT N'Unpaid',
    [CreatedDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    [UpdatedDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_SupplierDebt]           PRIMARY KEY CLUSTERED ([DebtID] ASC),
    CONSTRAINT [FK_SupplierDebt_StockIn]   FOREIGN KEY ([StockInID])  REFERENCES [dbo].[StockIn]([StockInID]),
    CONSTRAINT [FK_SupplierDebt_Suppliers] FOREIGN KEY ([SupplierID]) REFERENCES [dbo].[Suppliers]([SupplierID])
);
GO

CREATE TABLE [dbo].[SupplierDebtPayment](
    [PaymentID]   INT           IDENTITY(1,1) NOT NULL,
    [DebtID]      INT           NOT NULL,
    [Amount]      DECIMAL(18,2) NOT NULL,
    [PaymentDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    [Note]        NVARCHAR(500) NULL,
    [CreatedBy]   INT           NOT NULL,
    CONSTRAINT [PK_SupplierDebtPayment]         PRIMARY KEY CLUSTERED ([PaymentID] ASC),
    CONSTRAINT [FK_SupplierDebtPayment_SupplierDebt] FOREIGN KEY ([DebtID])    REFERENCES [dbo].[SupplierDebt]([DebtID]),
    CONSTRAINT [FK_SupplierDebtPayment_User]         FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 25 - BẢNG LỊCH SỬ THANH TOÁN CÔNG NỢ NHÀ CUNG CẤP (SupplierDebts)
   ======================================================================================= */
CREATE TABLE [dbo].[SupplierDebtsPayment](
    [PaymentID]   INT           IDENTITY(1,1) NOT NULL,
    [DebtID]      INT           NOT NULL,
    [Amount]      DECIMAL(18,2) NOT NULL,
    [PaymentDate] DATETIME      NOT NULL DEFAULT GETDATE(),
    [Note]        NVARCHAR(500) NULL,
    [CreatedBy]   INT           NOT NULL,
    CONSTRAINT [PK_SupplierDebtsPayment]         PRIMARY KEY CLUSTERED ([PaymentID] ASC),
    CONSTRAINT [FK_SupplierDebtsPayment_Debt] FOREIGN KEY ([DebtID])    REFERENCES [dbo].[SupplierDebts]([DebtID]),
    CONSTRAINT [FK_SupplierDebtsPayment_User] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[User]([UserID])
);
GO

/* =======================================================================================
   PHẦN 26 - BẢNG KHÁCH TRẢ HÀNG
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

/* =======================================================================================
   PHẦN 26B - BẢNG YÊU CẦU TRẢ HÀNG / HOÀN TIỀN (ReturnRequests – khớp ReturnDAO / entity ReturnRequest)
   ======================================================================================= */
CREATE TABLE [dbo].[ReturnRequests](
    [ReturnID]        INT            IDENTITY(1,1) NOT NULL,
    [ReturnCode]      NVARCHAR(50)   NULL,
    [SKU]             NVARCHAR(50)   NOT NULL,
    [ProductName]     NVARCHAR(255)  NOT NULL,
    [CustomerName]    NVARCHAR(100)  NOT NULL,
    [CustomerPhone]   NVARCHAR(20)   NOT NULL,
    [Reason]          NVARCHAR(MAX)  NULL,
    [ConditionNote]   NVARCHAR(MAX)  NULL,
    [Status]          NVARCHAR(30)   NOT NULL DEFAULT N'NEW',
    [RefundAmount]    DECIMAL(18,2)  NULL,
    [RefundMethod]    NVARCHAR(50)   NULL,
    [RefundReference] NVARCHAR(100)  NULL,
    [RefundedAt]      DATETIME2(3)   NULL,
    [CreatedAt]       DATETIME2(3)   NOT NULL CONSTRAINT [DF_ReturnRequests_CreatedAt] DEFAULT SYSUTCDATETIME(),
    [UpdatedAt]       DATETIME2(3)   NOT NULL CONSTRAINT [DF_ReturnRequests_UpdatedAt] DEFAULT SYSUTCDATETIME(),
    CONSTRAINT [PK_ReturnRequests] PRIMARY KEY CLUSTERED ([ReturnID] ASC)
);
GO

CREATE TABLE [dbo].[ReturnEvents](
    [EventID]   INT            IDENTITY(1,1) NOT NULL,
    [ReturnID]  INT            NOT NULL,
    [EventTime] DATETIME2(3)   NOT NULL CONSTRAINT [DF_ReturnEvents_EventTime] DEFAULT SYSUTCDATETIME(),
    [Actor]     NVARCHAR(100)  NOT NULL,
    [Action]    NVARCHAR(50)   NOT NULL,
    [Note]      NVARCHAR(MAX)  NULL,
    CONSTRAINT [PK_ReturnEvents] PRIMARY KEY CLUSTERED ([EventID] ASC),
    CONSTRAINT [FK_ReturnEvents_Return] FOREIGN KEY ([ReturnID]) REFERENCES [dbo].[ReturnRequests]([ReturnID]) ON DELETE CASCADE
);
GO

/* =======================================================================================
   PHẦN 27 - BẢNG TRẢ HÀNG LẠI NHÀ CUNG CẤP
   ======================================================================================= */
CREATE TABLE [dbo].[ReturnToVendors](
    [RTVID]     INT           IDENTITY(1,1) NOT NULL,
    [StockInID] INT           NOT NULL,
    [ProductID] INT           NOT NULL,
    [Quantity]  INT           NOT NULL,
    [Reason]    NVARCHAR(255) NULL,
    [Date]      DATETIME      NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [PK_ReturnToVendors]           PRIMARY KEY CLUSTERED ([RTVID] ASC),
    CONSTRAINT [FK_ReturnToVendors_StockIn]    FOREIGN KEY ([StockInID]) REFERENCES [dbo].[StockIn]([StockInID]),
    CONSTRAINT [FK_ReturnToVendors_Products]   FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

/* =======================================================================================
   PHẦN 28 - BẢNG LỊCH SỬ BIẾN ĐỘNG KHO
   ======================================================================================= */
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
   PHẦN 29 - BẢNG THANH TOÁN CÔNG NỢ KHÁCH HÀNG
   ======================================================================================= */
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
   PHẦN 30 - DỮ LIỆU MẪU
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
(N'Gia dụng nhà bếp',    NULL, NULL);
GO

INSERT INTO [dbo].[Categories] ([CategoryName], [Description], [ParentID]) VALUES
(N'Tủ lạnh',       NULL, 1),
(N'Máy giặt',      NULL, 1),
(N'Nồi cơm điện',  NULL, 2),
(N'Bếp từ',        NULL, 2);
GO

INSERT INTO [dbo].[Suppliers] ([Name], [Phone], [Address], [Email], [IsActive]) VALUES
(N'Samsung Vina',      N'0901234567', N'TP.HCM',  N'samsung@supplier.com', 1),
(N'Sharp Việt Nam',    N'0912345678', N'Hà Nội',  N'sharp@supplier.com',   1);
GO

INSERT INTO [dbo].[Customers] ([Name], [Phone], [Address], [Email]) VALUES
(N'Khách lẻ', N'0387654321', N'Tại quầy', NULL);
GO

INSERT INTO [dbo].[Products] ([Name], [SKU], [Cost], [Price], [StockQuantity], [Unit], [CategoryID], [Description], [WarrantyPeriod], [Status]) VALUES
(N'Tủ lạnh Samsung Inverter 208L', N'SS-208L',   5000000, 6500000, 0, N'Cái', 3, NULL, 24, N'Active'),
(N'Nồi cơm điện Sharp 1.8L',      N'SHARP-18',   600000,  850000, 0, N'Cái', 5, NULL, 12, N'Active');
GO

-- Thêm 5 sản phẩm mẫu (SKU phải duy nhất; CategoryID tham chiếu bảng Categories đã seed)
INSERT INTO [dbo].[Products] ([Name], [SKU], [Cost], [Price], [StockQuantity], [Unit], [CategoryID], [Description], [WarrantyPeriod], [Status]) VALUES
(N'Máy giặt LG Inverter 9kg',           N'LG-WASH-9',   8500000.00, 11200000.00, 0, N'Cái', 4, NULL, 24,  N'Active'),
(N'Bếp từ đôi Bosch',                   N'BOSCH-IND-2', 4200000.00,  5500000.00, 0, N'Bộ',  6, NULL, 12,  N'Active'),
(N'Tủ lạnh Panasonic 322L',             N'PA-322L',     7200000.00,  9200000.00, 0, N'Cái', 3, NULL, 24,  N'Active'),
(N'Máy lọc không khí Xiaomi 4 Lite',     N'MI-AIR-4',    1800000.00,  2490000.00, 0, N'Cái', 1, NULL, 12,  N'Active'),
(N'Quạt điều hòa Sunhouse dung tích 40L', N'SH-COOL-40',  3200000.00,  4290000.00, 0, N'Cái', 1, NULL, 12,  N'Active');
GO

INSERT INTO [dbo].[SupplierProduct] ([SupplierID], [ProductID], [SupplyPrice], [IsActive]) VALUES
(1, 1, 5000000, 1),
(2, 2,  600000, 1);
GO

-- Phiếu xuất / bán hàng mẫu (bắt buộc để Tra cứu bảo hành có dữ liệu: JOIN StockOut + StockOutDetails)
DECLARE @SO1 INT, @SO2 INT;
INSERT INTO [dbo].[StockOut] ([CustomerID], [Date], [TotalAmount], [CreatedBy], [Note], [Status]) VALUES
(1, DATEADD(MONTH, -2, GETDATE()), 6500000.00, 1, N'Bán lẻ demo - tủ lạnh', N'Completed');
SET @SO1 = SCOPE_IDENTITY();
INSERT INTO [dbo].[StockOutDetails] ([StockOutID], [ProductID], [Quantity], [UnitPrice]) VALUES
(@SO1, 1, 1, 6500000.00);

INSERT INTO [dbo].[StockOut] ([CustomerID], [Date], [TotalAmount], [CreatedBy], [Note], [Status]) VALUES
(1, DATEADD(MONTH, -1, GETDATE()), 850000.00, 1, N'Bán lẻ demo - nồi cơm', N'Completed');
SET @SO2 = SCOPE_IDENTITY();
INSERT INTO [dbo].[StockOutDetails] ([StockOutID], [ProductID], [Quantity], [UnitPrice]) VALUES
(@SO2, 2, 1, 850000.00);
GO

-- Phiếu nhập mẫu (phục vụ SupplierDebt / SupplierDebts)
INSERT INTO [dbo].[StockIn] ([SupplierID], [Date], [TotalAmount], [InitialPaidAmount], [CreatedBy], [Note], [StockStatus], [PaymentStatus]) VALUES
(1, DATEADD(DAY, -3, GETDATE()), 5000000, 0, 1, N'Phiếu nhập demo 1', N'Completed', N'Paid'),
(1, DATEADD(DAY, -2, GETDATE()),  600000, 0, 1, N'Phiếu nhập demo 2', N'Completed', N'Partial'),
(2, DATEADD(DAY, -1, GETDATE()),  850000, 0, 1, N'Phiếu nhập demo 3', N'Pending',  N'Unpaid');
GO

INSERT INTO [dbo].[WarrantyClaims] ([ClaimCode], [SKU], [ProductName], [CustomerName], [CustomerPhone], [IssueDescription], [Status]) VALUES
(N'WC-1', N'SS-208L',   N'Tủ lạnh Samsung Inverter 208L', N'Nguyễn Văn A', N'0911111111', N'Tủ không lạnh đủ',                    N'NEW'),
(N'WC-2', N'SHARP-18',  N'Nồi cơm Sharp 1.8L',            N'Trần Thị B',   N'0922222222', N'Hỏng nút điều khiển',               N'RECEIVED'),
(N'WC-3', N'SS-208L',   N'Tủ lạnh Samsung Inverter 208L', N'Lê Văn C',     N'0933333333', N'Ồn cao bất thường',                 N'IN_REPAIR');
GO

INSERT INTO [dbo].[WarrantyClaimEvents] ([ClaimID], [Actor], [Action], [Note]) VALUES
(1, N'admin', N'CREATE', N'Tạo yêu cầu bảo hành'),
(2, N'admin', N'CREATE', N'Tiếp nhận tại quầy'),
(3, N'admin', N'NOTE',   N'Chuyển kỹ thuật kiểm tra');
GO

INSERT INTO [dbo].[ReturnRequests] ([ReturnCode], [SKU], [ProductName], [CustomerName], [CustomerPhone], [Reason], [ConditionNote], [Status], [RefundAmount], [RefundMethod], [RefundReference], [RefundedAt]) VALUES
(N'RT-1', N'SS-208L',  N'Tủ lạnh Samsung Inverter 208L', N'Phạm D', N'0944444444', N'Đổi ý trong 7 ngày',     N'Còn nguyên seal',  N'NEW',       NULL,     NULL, NULL, NULL),
(N'RT-2', N'SHARP-18', N'Nồi cơm Sharp 1.8L',            N'Hoàng E', N'0955555555', N'Sản phẩm lỗi kỹ thuật', N'Vỏ trầy nhẹ',      N'APPROVED',  NULL,     NULL, NULL, NULL),
(N'RT-3', N'SHARP-18', N'Nồi cơm Sharp 1.8L',            N'Võ F',    N'0966666666', N'Không nhu cầu',         N'Full box',         N'REFUNDED',  850000,   N'CASH', N'RR-2026-001', SYSUTCDATETIME());
GO

INSERT INTO [dbo].[ReturnEvents] ([ReturnID], [Actor], [Action], [Note]) VALUES
(1, N'admin', N'CREATE', N'Tạo yêu cầu trả hàng/hoàn tiền'),
(2, N'admin', N'CREATE', N'Tạo yêu cầu trả hàng/hoàn tiền'),
(3, N'admin', N'REFUND', N'Hoàn tiền mặt tại quầy');
GO

INSERT INTO [dbo].[SupplierDebt] ([StockInID], [SupplierID], [DebtAmount], [PaidAmount], [Status]) VALUES
(1, 1, 5000000, 5000000, N'Paid'),
(2, 1,  600000,  300000, N'Partial'),
(3, 2,  850000,       0, N'Unpaid');
GO

INSERT INTO [dbo].[SupplierDebtPayment] ([DebtID], [Amount], [Note], [CreatedBy]) VALUES
(1, 5000000, N'Thanh toán đủ khi nhập', 1),
(2,  300000, N'Trả một phần',          1),
(3,  100000, N'Đặt cọc trước',         1);
GO

INSERT INTO [dbo].[SupplierDebts] ([SupplierID], [StockInID], [Amount], [DueDate], [Status]) VALUES
(1, 1, 5000000, DATEADD(DAY, 30, GETDATE()), N'Paid'),
(1, 2,  300000, DATEADD(DAY, 15, GETDATE()), N'Pending'),
(2, 3,  850000, DATEADD(DAY, 45, GETDATE()), N'Pending');
GO

INSERT INTO [dbo].[SupplierDebtsPayment] ([DebtID], [Amount], [Note], [CreatedBy]) VALUES
(1, 2000000, N'Thanh toán đợt 1 (SupplierDebts)', 1),
(2,  100000, N'Thanh toán một phần',             1),
(3,  200000, N'Ứng trước',                       1);
GO

SELECT N'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS [Status];
GO
