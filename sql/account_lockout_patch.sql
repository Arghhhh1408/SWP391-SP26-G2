USE [SimpleInventoryManagement]
GO

-- Add columns to User table for Account Lockout Policy
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = N'FailedAttempts')
BEGIN
    ALTER TABLE [dbo].[User] ADD [FailedAttempts] INT NOT NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[User]') AND name = N'LockoutEnd')
BEGIN
    ALTER TABLE [dbo].[User] ADD [LockoutEnd] DATETIME NULL;
END
GO

-- Add system log action for account lockout
-- (The action string will be used in Java code, no DB change needed for Action types usually)

PRINT 'Database schema updated successfully for Account Lockout Policy.';
