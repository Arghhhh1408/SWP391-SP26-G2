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

-- ======================================================================================
-- PHẦN 1: QUẢN TRỊ HỆ THỐNG & BẢO MẬT (SYSTEM ADMIN)
-- ======================================================================================

-- 1. BẢNG PHÂN QUYỀN (ROLE)
-- Chức năng: Định nghĩa các vai trò trong hệ thống để phân quyền truy cập.
CREATE TABLE [dbo].[Role](
    [RoleID] [int] NOT NULL,         -- Mã vai trò (0: Admin, 1: Staff...)
    [RoleName] [nvarchar](50) NOT NULL, -- Tên hiển thị (VD: Quản lý, Nhân viên kho)
    PRIMARY KEY CLUSTERED ([RoleID] ASC)
);
GO

-- 2. BẢNG TÀI KHOẢN (USER)
-- Chức năng: Lưu thông tin đăng nhập và hồ sơ nhân viên.
CREATE TABLE [dbo].[User](
    [UserID] [int] IDENTITY(1,1) NOT NULL,
    [Username] [nvarchar](50) NOT NULL,      -- Tên đăng nhập (Unique)
    [PasswordHash] [nvarchar](255) NOT NULL, -- Mật khẩu đã mã hóa (MD5 hoặc BCrypt)
    [FullName] [nvarchar](100) NULL,         -- Họ và tên nhân viên
    [RoleID] [int] NOT NULL,                 -- Thuộc vai trò nào? (FK)
    [Email] [nvarchar](100) NULL,            -- Email liên hệ/khôi phục pass
    [Phone] [nvarchar](20) NULL,             -- Số điện thoại
    [CreateDate] [datetime] DEFAULT GETDATE(), -- Ngày tạo tài khoản
    [IsActive] [bit] DEFAULT 1,              -- Trạng thái: 1=Đang làm việc, 0=Đã nghỉ/Bị khóa (Thay vì xóa cứng)
    PRIMARY KEY CLUSTERED ([UserID] ASC),
    FOREIGN KEY([RoleID]) REFERENCES [dbo].[Role] ([RoleID])
);
GO

-- 3. BẢNG NHẬT KÝ HOẠT ĐỘNG (SYSTEM LOG) - **TÍNH NĂNG KILLER**
-- Chức năng: Ghi lại mọi hành động quan trọng để tra soát khi có sự cố (mất hàng, sửa giá).
CREATE TABLE [dbo].[SystemLog](
    [LogID] [int] IDENTITY(1,1) NOT NULL,
    [UserID] [int] NOT NULL,             -- Ai là người thực hiện?
    [Action] [nvarchar](50) NOT NULL,    -- Tên hành động (VD: LOGIN, UPDATE_PRICE, DELETE_ORDER)
    [TargetObject] [nvarchar](100) NULL, -- Đối tượng bị tác động (VD: Sản phẩm #10, Đơn hàng #99)
    [Description] [nvarchar](max) NULL,  -- Mô tả chi tiết (VD: "Sửa giá từ 10k -> 20k")
    [LogDate] [datetime] DEFAULT GETDATE(), -- Thời điểm thực hiện
    [IPAddress] [nvarchar](50) NULL,     -- (Tùy chọn) IP máy thực hiện
    PRIMARY KEY CLUSTERED ([LogID] ASC),
    FOREIGN KEY([UserID]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- 4. BẢNG THÔNG BÁO (NOTIFICATIONS)
-- Chức năng: Lưu các thông báo nội bộ để hiển thị lên icon "Quả chuông".
CREATE TABLE [dbo].[Notifications](
    [NotificationID] [int] IDENTITY(1,1) NOT NULL,
    [UserID] [int] NOT NULL,             -- Thông báo này gửi cho ai?
    [Title] [nvarchar](100) NOT NULL,    -- Tiêu đề (VD: Hàng sắp hết!)
    [Message] [nvarchar](255) NULL,      -- Nội dung ngắn gọn
    [IsRead] [bit] DEFAULT 0,            -- 0: Chưa xem, 1: Đã xem (để ẩn dấu chấm đỏ)
    [CreatedAt] [datetime] DEFAULT GETDATE(),
    [Type] [nvarchar](20) DEFAULT 'Info', -- Loại: Info (Tin thường), Warning (Cảnh báo), Success (Thành công)
    PRIMARY KEY CLUSTERED ([NotificationID] ASC),
    FOREIGN KEY([UserID]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- ======================================================================================
-- PHẦN 2: DỮ LIỆU NỀN & SẢN PHẨM (MASTER DATA)
-- ======================================================================================

-- 5. BẢNG DANH MỤC (CATEGORIES) - HỖ TRỢ ĐA CẤP (PARENT-CHILD)
-- Chức năng: Phân loại sản phẩm. Hỗ trợ menu đa cấp (VD: Điện lạnh -> Tủ lạnh).
CREATE TABLE [dbo].[Categories](
    [CategoryID] [int] IDENTITY(1,1) NOT NULL,
    [CategoryName] [nvarchar](100) NOT NULL,
    [Description] [nvarchar](255) NULL,
    [ParentID] [int] NULL, -- Nếu NULL là danh mục Cha. Nếu có số là danh mục Con.
    PRIMARY KEY CLUSTERED ([CategoryID] ASC),
    FOREIGN KEY([ParentID]) REFERENCES [dbo].[Categories] ([CategoryID])
);
GO

-- 6. BẢNG NHÀ CUNG CẤP (SUPPLIERS)
-- Chức năng: Lưu thông tin đối tác nhập hàng.
CREATE TABLE [dbo].[Suppliers](
    [SupplierID] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](100) NOT NULL,     -- Tên công ty/NCC
    [Phone] [nvarchar](20) NULL,
    [Address] [nvarchar](255) NULL,
    [Email] [nvarchar](100) NULL,
    [IsActive] [bit] DEFAULT 1,          -- 1: Còn hợp tác, 0: Ngừng hợp tác
    PRIMARY KEY CLUSTERED ([SupplierID] ASC)
);
GO

-- 7. BẢNG KHÁCH HÀNG (CUSTOMERS)
-- Chức năng: Lưu thông tin khách mua hàng (để tích điểm hoặc bảo hành).
CREATE TABLE [dbo].[Customers](
    [CustomerID] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](100) NOT NULL,
    [Phone] [nvarchar](20) NULL,         -- Dùng SĐT để tra cứu lịch sử mua/bảo hành
    [Address] [nvarchar](255) NULL,
    [Email] [nvarchar](100) NULL,
    PRIMARY KEY CLUSTERED ([CustomerID] ASC)
);
GO

-- 8. BẢNG SẢN PHẨM (PRODUCTS) - **TRÁI TIM HỆ THỐNG**
-- Chức năng: Lưu trữ thông tin hàng hóa, giá cả và tồn kho hiện tại.
CREATE TABLE [dbo].[Products](
    [ProductID] [int] IDENTITY(1,1) NOT NULL,
    [Name] [nvarchar](255) NOT NULL,
    [SKU] [nvarchar](50) NOT NULL,       -- Mã vạch/Mã hàng (Duy nhất, VD: IP15-BLU)
    [Cost] [decimal](10, 2) NOT NULL,    -- Giá vốn nhập vào (User thường không thấy)
    [Price] [decimal](10, 2) NOT NULL,   -- Giá bán ra niêm yết
    [StockQuantity] [int] DEFAULT 0,     -- **QUAN TRỌNG**: Số lượng tồn kho thực tế (Tự động +/-)
    [Unit] [nvarchar](50) NOT NULL,      -- Đơn vị tính (Cái, Chiếc, Bộ)
    [CategoryID] [int] NULL,             -- Thuộc danh mục nào
    [Description] [nvarchar](max) NULL,  -- Bài viết mô tả sản phẩm
    [ImageURL] [nvarchar](max) NULL,     -- Link ảnh sản phẩm
    [WarrantyPeriod] [int] DEFAULT 0,    -- Thời gian bảo hành (Tháng). 0 là không BH.
    [Status] [nvarchar](20) DEFAULT 'Active', -- Active (Bán), Deactivated (Ngừng kinh doanh)
    [CreatedDate] [datetime] DEFAULT GETDATE(),
    [UpdatedDate] [datetime] DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([ProductID] ASC),
    FOREIGN KEY([CategoryID]) REFERENCES [dbo].[Categories] ([CategoryID]),
    CHECK ([Status] IN ('Active', 'Deactivated', 'Deleted'))
);
GO

-- ======================================================================================
-- PHẦN 3: NHẬP KHO (INBOUND) - MÔ HÌNH MASTER-DETAIL
-- ======================================================================================

-- 9. BẢNG PHIẾU NHẬP (STOCK IN HEADER)
-- Chức năng: Lưu thông tin chung của phiếu nhập (Ngày, NCC, Tổng tiền).
CREATE TABLE [dbo].[StockIn](
    [StockInID] [int] IDENTITY(1,1) NOT NULL,
    [SupplierID] [int] NOT NULL,         -- Nhập của ai?
    [Date] [datetime] DEFAULT GETDATE(), -- Ngày nhập
    [TotalAmount] [decimal](18, 2) DEFAULT 0, -- Tổng giá trị phiếu
    [CreatedBy] [int] NOT NULL,          -- Nhân viên nào nhập?
    [Note] [nvarchar](max) NULL,         -- Ghi chú
    [Status] [nvarchar](20) DEFAULT 'Completed',
    PRIMARY KEY CLUSTERED ([StockInID] ASC),
    FOREIGN KEY([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID]),
    FOREIGN KEY([CreatedBy]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- 10. BẢNG CHI TIẾT PHIẾU NHẬP (STOCK IN DETAILS)
-- Chức năng: Lưu danh sách từng món hàng trong phiếu nhập đó.
CREATE TABLE [dbo].[StockInDetails](
    [DetailID] [int] IDENTITY(1,1) NOT NULL,
    [StockInID] [int] NOT NULL,          -- Thuộc phiếu nhập nào?
    [ProductID] [int] NOT NULL,          -- Nhập sản phẩm gì?
    [Quantity] [int] NOT NULL,           -- Số lượng bao nhiêu?
    [UnitCost] [decimal](10, 2) NOT NULL,-- Giá nhập tại thời điểm đó (có thể khác giá gốc)
    [SubTotal] AS ([Quantity] * [UnitCost]), -- Thành tiền dòng này
    PRIMARY KEY CLUSTERED ([DetailID] ASC),
    FOREIGN KEY([StockInID]) REFERENCES [dbo].[StockIn] ([StockInID]) ON DELETE CASCADE,
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- ======================================================================================
-- PHẦN 4: BÁN HÀNG (OUTBOUND) - MÔ HÌNH MASTER-DETAIL
-- ======================================================================================

-- 11. BẢNG ĐƠN HÀNG / PHIẾU XUẤT (STOCK OUT HEADER)
-- Chức năng: Lưu thông tin chung của đơn hàng bán ra.
CREATE TABLE [dbo].[StockOut](
    [StockOutID] [int] IDENTITY(1,1) NOT NULL,
    [CustomerID] [int] NULL,             -- Khách nào mua? (NULL nếu khách vãng lai)
    [Date] [datetime] DEFAULT GETDATE(), -- Ngày bán
    [TotalAmount] [decimal](18, 2) DEFAULT 0, -- Tổng tiền khách phải trả
    [CreatedBy] [int] NOT NULL,          -- Nhân viên nào bán (Sales)?
    [Note] [nvarchar](max) NULL,
    [Status] [nvarchar](20) DEFAULT 'Completed',
    PRIMARY KEY CLUSTERED ([StockOutID] ASC),
    FOREIGN KEY([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]),
    FOREIGN KEY([CreatedBy]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- 12. BẢNG CHI TIẾT ĐƠN HÀNG (STOCK OUT DETAILS)
-- Chức năng: Lưu danh sách món hàng khách mua.
CREATE TABLE [dbo].[StockOutDetails](
    [DetailID] [int] IDENTITY(1,1) NOT NULL,
    [StockOutID] [int] NOT NULL,         -- Thuộc đơn hàng nào?
    [ProductID] [int] NOT NULL,          -- Bán cái gì?
    [Quantity] [int] NOT NULL,           -- Bán mấy cái?
    [UnitPrice] [decimal](10, 2) NOT NULL, -- Giá bán lúc đó (có thể đã giảm giá)
    [SubTotal] AS ([Quantity] * [UnitPrice]),
    PRIMARY KEY CLUSTERED ([DetailID] ASC),
    FOREIGN KEY([StockOutID]) REFERENCES [dbo].[StockOut] ([StockOutID]) ON DELETE CASCADE,
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- ======================================================================================
-- PHẦN 5: DỊCH VỤ BẢO HÀNH (WARRANTY) - TÍNH NĂNG NÂNG CAO CHO ĐỒ GIA DỤNG
-- ======================================================================================

-- 13. BẢNG PHIẾU BẢO HÀNH (WARRANTY TICKETS)
-- Chức năng: Quản lý việc nhận hàng hỏng từ khách -> sửa chữa -> trả lại.
CREATE TABLE [dbo].[WarrantyTickets](
    [TicketID] [int] IDENTITY(1,1) NOT NULL,
    [StockOutID] [int] NOT NULL,         -- Bảo hành cho đơn hàng cũ nào? (Check ngày mua)
    [ProductID] [int] NOT NULL,          -- Sản phẩm nào bị hỏng?
    [CustomerID] [int] NOT NULL,         -- Khách nào mang đến?
    [ReceiveDate] [datetime] DEFAULT GETDATE(), -- Ngày nhận máy
    [ReturnDate] [datetime] NULL,        -- Ngày hẹn trả máy
    [IssueDescription] [nvarchar](max) NULL, -- Khách báo lỗi gì? (VD: Không vào điện)
    [Solution] [nvarchar](max) NULL,     -- Hướng xử lý của kỹ thuật (VD: Thay main)
    [Status] [nvarchar](20) DEFAULT 'Received', -- Trạng thái: Received, Processing, Done, Returned
    [CreatedBy] [int] NOT NULL,          -- Nhân viên tiếp nhận
    PRIMARY KEY CLUSTERED ([TicketID] ASC),
    FOREIGN KEY([StockOutID]) REFERENCES [dbo].[StockOut] ([StockOutID]),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    FOREIGN KEY([CustomerID]) REFERENCES [dbo].[Customers] ([CustomerID]),
    FOREIGN KEY([CreatedBy]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- ======================================================================================
-- PHẦN 6: KIỂM SOÁT KHO & KẾ TOÁN (INVENTORY CONTROL)
-- ======================================================================================

-- 14. BẢNG ĐIỀU CHỈNH KHO (STOCK ADJUSTMENTS)
-- Chức năng: Dùng khi hàng bị vỡ, hỏng, mất cắp -> Cần trừ tồn kho thủ công.
CREATE TABLE [dbo].[StockAdjustments](
    [AdjustmentID] [int] IDENTITY(1,1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [Quantity] [int] NOT NULL,           -- Số lượng điều chỉnh (Thường là số âm, VD: -1)
    [ReasonCode] [nvarchar](50) NOT NULL, -- Lý do: 'DAMAGED' (Vỡ), 'LOST' (Mất), 'EXPIRED' (Hết hạn)
    [Date] [datetime] DEFAULT GETDATE(),
    [CreatedBy] [int] NOT NULL,          -- Ai báo cáo?
    [Status] [nvarchar](20) DEFAULT 'Approved',
    PRIMARY KEY CLUSTERED ([AdjustmentID] ASC),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    FOREIGN KEY([CreatedBy]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- 15. BẢNG CẤU HÌNH CẢNH BÁO (LOW STOCK ALERTS)
-- Chức năng: Cài đặt định mức tối thiểu. Nếu tồn kho < mức này thì báo động.
CREATE TABLE [dbo].[LowStockAlerts](
    [AlertID] [int] IDENTITY(1,1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [MinStockLevel] [int] NOT NULL,      -- Mức báo động (VD: 5 cái)
    [Notified] [bit] DEFAULT 0,          -- Đã gửi thông báo chưa?
    PRIMARY KEY CLUSTERED ([AlertID] ASC),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- 16. BẢNG KIỂM KÊ KHO (INVENTORY COUNTS)
-- Chức năng: Đối chiếu số lượng trên phần mềm và thực tế (Quy trình cuối tháng).
CREATE TABLE [dbo].[InventoryCounts](
    [CountID] [int] IDENTITY(1,1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [PhysicalQuantity] [int] NOT NULL,   -- Số đếm được bằng tay
    [SystemQuantity] [int] NOT NULL,     -- Số đang lưu trên phần mềm (Lúc kiểm)
    [Date] [datetime] DEFAULT GETDATE(),
    [ApprovedBy] [int] NULL,             
    [Status] [nvarchar](20) DEFAULT 'Pending', -- Pending (Chờ duyệt) -> Approved
    PRIMARY KEY CLUSTERED ([CountID] ASC),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID]),
    FOREIGN KEY([ApprovedBy]) REFERENCES [dbo].[User] ([UserID])
);
GO

-- 17. BẢNG CÔNG NỢ NHÀ CUNG CẤP (SUPPLIER DEBTS)
-- Chức năng: Quản lý tiền nợ khi nhập hàng (Mua chịu).
CREATE TABLE [dbo].[SupplierDebts](
    [DebtID] [int] IDENTITY(1,1) NOT NULL,
    [SupplierID] [int] NOT NULL,
    [StockInID] [int] NOT NULL,          -- Nợ của phiếu nhập nào?
    [Amount] [decimal](10, 2) NOT NULL,  -- Số tiền còn nợ
    [DueDate] [date] NULL,               -- Hạn trả tiền
    [Status] [nvarchar](20) DEFAULT 'Pending', -- Pending (Chưa trả), Paid (Đã trả)
    PRIMARY KEY CLUSTERED ([DebtID] ASC),
    FOREIGN KEY([SupplierID]) REFERENCES [dbo].[Suppliers] ([SupplierID]),
    FOREIGN KEY([StockInID]) REFERENCES [dbo].[StockIn] ([StockInID])
);
GO

-- 18. BẢNG KHÁCH TRẢ HÀNG (CUSTOMER RETURNS)
-- Chức năng: Xử lý khi khách mua xong mang trả lại (trong 3-7 ngày đầu).
CREATE TABLE [dbo].[CustomerReturns](
    [ReturnID] [int] IDENTITY(1,1) NOT NULL,
    [StockOutID] [int] NOT NULL, 
    [ProductID] [int] NOT NULL,
    [Quantity] [int] NOT NULL,           -- Số lượng trả lại
    [Reason] [nvarchar](255) NULL,       -- Lý do trả
    [Date] [datetime] DEFAULT GETDATE(),
    [RefundAmount] [decimal](10, 2) NULL,-- Tiền hoàn lại cho khách
    PRIMARY KEY CLUSTERED ([ReturnID] ASC),
    FOREIGN KEY([StockOutID]) REFERENCES [dbo].[StockOut] ([StockOutID]),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- 19. BẢNG TRẢ HÀNG NCC (RETURN TO VENDORS)
-- Chức năng: Xử lý khi nhập hàng về thấy lỗi, trả lại cho NCC.
CREATE TABLE [dbo].[ReturnToVendors](
    [RTVID] [int] IDENTITY(1,1) NOT NULL,
    [StockInID] [int] NOT NULL, 
    [ProductID] [int] NOT NULL,
    [Quantity] [int] NOT NULL,           -- Số lượng trả
    [Reason] [nvarchar](255) NULL,
    [Date] [datetime] DEFAULT GETDATE(),
    PRIMARY KEY CLUSTERED ([RTVID] ASC),
    FOREIGN KEY([StockInID]) REFERENCES [dbo].[StockIn] ([StockInID]),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- 20. BẢNG LỊCH SỬ BIẾN ĐỘNG (PRODUCT HISTORIES / CARD)
-- Chức năng: Sổ cái (Thẻ kho) ghi lại mọi dòng tiền/hàng vào ra của 1 SP.
CREATE TABLE [dbo].[ProductHistories](
    [HistoryID] [int] IDENTITY(1,1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [TransactionType] [nvarchar](50) NOT NULL, -- IN (Nhập), OUT (Xuất), ADJUST (Sửa), RETURN (Trả)
    [Quantity] [int] NOT NULL,                 -- Số lượng thay đổi (+ hoặc -)
    [Date] [datetime] DEFAULT GETDATE(),
    [ReferenceID] [int] NULL,                  -- Link tới ID của StockIn/StockOut tương ứng
    PRIMARY KEY CLUSTERED ([HistoryID] ASC),
    FOREIGN KEY([ProductID]) REFERENCES [dbo].[Products] ([ProductID])
);
GO

-- ======================================================================================
-- PHẦN 7: DỮ LIỆU MẪU (SEED DATA)
-- ======================================================================================

-- Thêm Role (Vai trò)
INSERT INTO [dbo].[Role] (RoleID, RoleName) VALUES 
(0, N'Admin'), (1, N'Warehouse Staff'), (2, N'Manager'), (3, N'Salesperson');

-- Thêm User Admin (Password: 123 -> MD5: 202cb962ac59075b964b07152d234b70)
-- Đã xóa cột LastLogin ở đây
INSERT INTO [dbo].[User] (Username, PasswordHash, FullName, RoleID, Email, Phone, IsActive) VALUES 
(N'admin', N'202cb962ac59075b964b07152d234b70', N'Administrator', 0, N'admin@sim.com', N'0987654321', 1);

-- Thêm Danh mục (Cấu trúc Cha - Con cho Đồ Gia Dụng)
INSERT INTO [dbo].[Categories] (CategoryName, ParentID) VALUES 
(N'Điện tử - Điện lạnh', NULL), -- ID 1 (Cha)
(N'Gia dụng nhà bếp', NULL);     -- ID 2 (Cha)

INSERT INTO [dbo].[Categories] (CategoryName, ParentID) VALUES 
(N'Tủ lạnh', 1),                -- Con của ID 1
(N'Máy giặt', 1),               -- Con của ID 1
(N'Nồi cơm điện', 2),           -- Con của ID 2
(N'Bếp từ', 2);                 -- Con của ID 2

-- Thêm Sản phẩm mẫu (Có bảo hành)
INSERT INTO [dbo].[Products] (Name, SKU, Cost, Price, StockQuantity, Unit, CategoryID, WarrantyPeriod, Status) VALUES 
(N'Tủ lạnh Samsung Inverter 208L', N'SS-208L', 5000000, 6500000, 0, N'Cái', 3, 24, 'Active'), -- BH 24 tháng
(N'Nồi cơm điện Sharp 1.8L', N'SHARP-18', 600000, 850000, 0, N'Cái', 5, 12, 'Active');       -- BH 12 tháng

-- Thêm Nhà cung cấp & Khách hàng
INSERT INTO [dbo].[Suppliers] (Name, Phone, Address) VALUES (N'Samsung Vina', N'18005888', N'TP.HCM');
INSERT INTO [dbo].[Customers] (Name, Phone, Address) VALUES (N'Khách lẻ', N'0000000000', N'Tại quầy');


-- Warranty Claim Processing tables (SQL Server)
-- Database: SimpleInventoryManagement

IF OBJECT_ID('dbo.WarrantyClaimEvents', 'U') IS NOT NULL
DROP TABLE dbo.WarrantyClaimEvents;

IF OBJECT_ID('dbo.WarrantyClaims', 'U') IS NOT NULL
DROP TABLE dbo.WarrantyClaims;

CREATE TABLE dbo.WarrantyClaims (
                                    ClaimID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                    ClaimCode VARCHAR(30) NULL,
                                    SKU VARCHAR(50) NOT NULL,
                                    ProductName NVARCHAR(255) NULL,
                                    CustomerName NVARCHAR(255) NOT NULL,
                                    CustomerPhone VARCHAR(30) NULL,
                                    IssueDescription NVARCHAR(MAX) NOT NULL,
                                    Status VARCHAR(30) NOT NULL,
                                    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_WarrantyClaims_CreatedAt DEFAULT SYSUTCDATETIME(),
                                    UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_WarrantyClaims_UpdatedAt DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_WarrantyClaims_ClaimCode ON dbo.WarrantyClaims(ClaimCode) WHERE ClaimCode IS NOT NULL;
CREATE INDEX IX_WarrantyClaims_SKU ON dbo.WarrantyClaims(SKU);
CREATE INDEX IX_WarrantyClaims_UpdatedAt ON dbo.WarrantyClaims(UpdatedAt DESC);

CREATE TABLE dbo.WarrantyClaimEvents (
                                         EventID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                         ClaimID INT NOT NULL,
                                         EventTime DATETIME2 NOT NULL CONSTRAINT DF_WarrantyClaimEvents_EventTime DEFAULT SYSUTCDATETIME(),
                                         Actor NVARCHAR(100) NOT NULL,
                                         Action VARCHAR(30) NOT NULL,
                                         Note NVARCHAR(MAX) NULL,
                                         CONSTRAINT FK_WarrantyClaimEvents_Claims FOREIGN KEY (ClaimID)
                                             REFERENCES dbo.WarrantyClaims(ClaimID)
                                             ON DELETE CASCADE
);

CREATE INDEX IX_WarrantyClaimEvents_ClaimID ON dbo.WarrantyClaimEvents(ClaimID, EventTime DESC);



-- Returns & Refunds tables (SQL Server)
-- Database: SimpleInventoryManagement

IF OBJECT_ID('dbo.ReturnEvents', 'U') IS NOT NULL
DROP TABLE dbo.ReturnEvents;

IF OBJECT_ID('dbo.ReturnRequests', 'U') IS NOT NULL
DROP TABLE dbo.ReturnRequests;

CREATE TABLE dbo.ReturnRequests (
                                    ReturnID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                    ReturnCode VARCHAR(30) NULL,

                                    SKU VARCHAR(50) NOT NULL,
                                    ProductName NVARCHAR(255) NULL,

                                    CustomerName NVARCHAR(255) NOT NULL,
                                    CustomerPhone VARCHAR(30) NULL,

                                    Reason NVARCHAR(MAX) NOT NULL,
                                    ConditionNote NVARCHAR(MAX) NULL,

                                    Status VARCHAR(30) NOT NULL,

                                    RefundAmount DECIMAL(18,2) NULL,
                                    RefundMethod NVARCHAR(50) NULL,
                                    RefundReference NVARCHAR(100) NULL,
                                    RefundedAt DATETIME2 NULL,

                                    CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_ReturnRequests_CreatedAt DEFAULT SYSUTCDATETIME(),
                                    UpdatedAt DATETIME2 NOT NULL CONSTRAINT DF_ReturnRequests_UpdatedAt DEFAULT SYSUTCDATETIME()
);

CREATE UNIQUE INDEX UX_ReturnRequests_ReturnCode ON dbo.ReturnRequests(ReturnCode) WHERE ReturnCode IS NOT NULL;
CREATE INDEX IX_ReturnRequests_SKU ON dbo.ReturnRequests(SKU);
CREATE INDEX IX_ReturnRequests_UpdatedAt ON dbo.ReturnRequests(UpdatedAt DESC);

CREATE TABLE dbo.ReturnEvents (
                                  EventID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                                  ReturnID INT NOT NULL,
                                  EventTime DATETIME2 NOT NULL CONSTRAINT DF_ReturnEvents_EventTime DEFAULT SYSUTCDATETIME(),
                                  Actor NVARCHAR(100) NOT NULL,
                                  Action VARCHAR(30) NOT NULL,
                                  Note NVARCHAR(MAX) NULL,
                                  CONSTRAINT FK_ReturnEvents_ReturnRequests FOREIGN KEY (ReturnID)
                                      REFERENCES dbo.ReturnRequests(ReturnID)
                                      ON DELETE CASCADE
);

CREATE INDEX IX_ReturnEvents_ReturnID ON dbo.ReturnEvents(ReturnID, EventTime DESC);




SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' AS Status;
GO