-- Database: cheque_authorization_system

CREATE DATABASE IF NOT EXISTS cheque_authorization_system;
USE cheque_authorization_system;

-- 1. COMPANY
-- =====================================================================
CREATE TABLE Company (
    CompanyId       INT AUTO_INCREMENT PRIMARY KEY,
    CompanyCode     VARCHAR(50) NOT NULL UNIQUE,
    CompanyName     VARCHAR(150) NOT NULL,
    IsActive        BOOLEAN DEFAULT TRUE,

    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL
);


-- =====================================================================
-- 2. DEPARTMENT
-- =====================================================================
CREATE TABLE Department (
    DepartmentId    INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId       INT NOT NULL,
    DepartmentCode  VARCHAR(50) NOT NULL,
    DepartmentName  VARCHAR(100) NOT NULL,
    IsActive        BOOLEAN DEFAULT TRUE,

    -- [Meta Data]
    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL,

    FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId),
    UNIQUE KEY UQ_Department_Company_Code (CompanyId, DepartmentCode)
);


-- =====================================================================
-- 3. EMPLOYEE
-- =====================================================================
CREATE TABLE Employee (
    EmployeeId      INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId       INT NOT NULL,
    DepartmentId    INT NOT NULL,
    EmployeeNo      VARCHAR(50) NOT NULL UNIQUE,
    EmployeeName    VARCHAR(150) NOT NULL,
    Designation     VARCHAR(100),
    Email           VARCHAR(150) UNIQUE NOT NULL,
    Mobile          VARCHAR(20),
    IsActive        BOOLEAN DEFAULT TRUE,

    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL,

    FOREIGN KEY (CompanyId)    REFERENCES Company(CompanyId),
    FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);


-- =====================================================================
-- 4. ELECTRONIC SIGNATURE
-- =====================================================================
CREATE TABLE EmployeeSignature (
    SignatureId         INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeId          INT NOT NULL,

    SignatureImage      MEDIUMBLOB NOT NULL,    -- stores signature image up to 16MB
    ImageType           VARCHAR(50),            -- JPG, PNG
    ImageSize           INT,                    -- size in KB
    OriginalFileName    VARCHAR(255),

    ValidFrom           DATETIME NOT NULL,
    ValidTo             DATETIME NOT NULL,
    IsDefault           BOOLEAN DEFAULT FALSE,
    IsActive            BOOLEAN DEFAULT TRUE,

    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy            INT,
    UpdateAt             DATETIME NULL,
    UpdateBy              INT NULL,

    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);


-- =====================================================================
-- 7. BANK ACCOUNT
-- =====================================================================

CREATE TABLE BankAccount (
    BankAccountId       INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId           INT NOT NULL,
    BankName             VARCHAR(150) NOT NULL,
    Branch               VARCHAR(150),
    AccountNo            VARCHAR(50) NOT NULL UNIQUE,
    AccountName          VARCHAR(150) NOT NULL,
    ChequeTemplateId     INT NULL,               -- FK added after ChequeTemplate is created
    IsActive             BOOLEAN DEFAULT TRUE,

    CreatedAt            DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy             INT,
    UpdateAt              DATETIME NULL,
    UpdateBy               INT NULL,

    FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId)
);


-- =====================================================================
-- 5. CHEQUE SIGNING RULE
--   ex - < 100,000        -> 1 signature
--   100,000 - 1M      -> 2 signatures
--   > 1M              -> 3 signatures
-- =====================================================================
CREATE TABLE ChequeSigningRule (
    RuleId               INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId            INT NOT NULL,
    DepartmentId         INT NULL,               -- NULL = applies company-wide
    BankAccountId        INT NOT NULL,
    MinAmount            DECIMAL(15,2) NOT NULL,
    MaxAmount            DECIMAL(15,2) NOT NULL,
    RequiredSignatures   INT NOT NULL,
    IsSequentialSigning  BOOLEAN DEFAULT TRUE,   -- TRUE = signers must sign in order
    IsActive             BOOLEAN DEFAULT TRUE,

    CreatedAt            DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy             INT,
    UpdateAt              DATETIME NULL,
    UpdateBy               INT NULL,

    FOREIGN KEY (CompanyId)     REFERENCES Company(CompanyId),
    FOREIGN KEY (DepartmentId)  REFERENCES Department(DepartmentId),
    FOREIGN KEY (BankAccountId) REFERENCES BankAccount(BankAccountId)
);


-- =====================================================================
-- 6. AUTHORIZED SIGNATORIES
-- =====================================================================
CREATE TABLE ChequeSigningRuleUser (
    RuleUserId      INT AUTO_INCREMENT PRIMARY KEY,
    RuleId          INT NOT NULL,
    EmployeeId      INT NOT NULL,
    SigningOrder    INT NOT NULL,
    CanApprove      BOOLEAN DEFAULT TRUE,
    CanReject       BOOLEAN DEFAULT TRUE,
    CanRevert       BOOLEAN DEFAULT TRUE,

    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL,

    FOREIGN KEY (RuleId)     REFERENCES ChequeSigningRule(RuleId),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId),
    UNIQUE KEY UQ_Rule_SigningOrder (RuleId, SigningOrder)
);


-- =====================================================================
-- 14. CHEQUE TEMPLATE  (created early since BankAccount references it)
-- =====================================================================
CREATE TABLE ChequeTemplate (
    TemplateId        INT AUTO_INCREMENT PRIMARY KEY,
    TemplateName      VARCHAR(100) NOT NULL,
    BankName          VARCHAR(150),
    Width             INT NOT NULL,        -- cheque layout width  (px or mm)
    Height            INT NOT NULL,        -- cheque layout height (px or mm)

    DateX             INT,
    DateY             INT,
    PayeeX            INT,
    PayeeY            INT,
    AmountX           INT,
    AmountY           INT,
    AmountWordsX      INT,
    AmountWordsY      INT,
    Signature1X       INT,
    Signature1Y       INT,
    Signature2X       INT,
    Signature2Y       INT,
    Signature3X       INT,
    Signature3Y       INT,

    IsActive          BOOLEAN DEFAULT TRUE,

    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL
);

-- Add the deferred FK from BankAccount -> ChequeTemplate
ALTER TABLE BankAccount
    ADD FOREIGN KEY (ChequeTemplateId) REFERENCES ChequeTemplate(TemplateId);


-- =====================================================================
-- 12. STATUS MASTER  (created early since ChequeRequest references it)
-- Suggested statuses: DRAFT, SUBMITTED, DOC_REVIEW_PENDING,
-- SIGNATURE_PENDING, PARTIALLY_APPROVED, FULLY_APPROVED,
-- RETURNED_FOR_CORRECTION, REJECTED, READY_TO_PRINT, PRINTED,
-- DELIVERED, CANCELLED, VOIDED
-- =====================================================================
CREATE TABLE ChequeStatus (
    StatusId        INT AUTO_INCREMENT PRIMARY KEY,
    StatusCode      VARCHAR(50) NOT NULL UNIQUE,
    StatusName      VARCHAR(100) NOT NULL,
    DisplayOrder    INT DEFAULT 0
);

-- Seed suggested statuses
INSERT INTO ChequeStatus (StatusCode, StatusName, DisplayOrder) VALUES
('DRAFT',                    'Draft',                       1),
('SUBMITTED',                'Submitted',                   2),
('DOC_REVIEW_PENDING',       'Document Review Pending',     3),
('SIGNATURE_PENDING',        'Awaiting Signature',          4),
('PARTIALLY_APPROVED',       'Partially Approved',          5),
('FULLY_APPROVED',           'Fully Approved',              6),
('RETURNED_FOR_CORRECTION',  'Returned for Correction',     7),
('REJECTED',                 'Rejected',                    8),
('READY_TO_PRINT',           'Ready to Print',              9),
('PRINTED',                  'Printed',                    10),
('DELIVERED',                'Delivered',                  11),
('CANCELLED',                'Cancelled',                  12),
('VOIDED',                   'Voided',                     13);


-- =====================================================================
-- 8. CHEQUE REQUEST
-- =====================================================================
CREATE TABLE ChequeRequest (
    ChequeRequestId      INT AUTO_INCREMENT PRIMARY KEY,
    RequestNo            VARCHAR(100) UNIQUE NOT NULL,
    CompanyId            INT NOT NULL,
    DepartmentId         INT NOT NULL,
    PayeeName            VARCHAR(150) NOT NULL,
    ChequeAmount         DECIMAL(15,2) NOT NULL,
    ChequeDate           DATE NOT NULL,
    Purpose              VARCHAR(255),
    BankAccountId        INT NOT NULL,

    CreatedBy            INT NOT NULL,
    CreatedDate          DATETIME DEFAULT CURRENT_TIMESTAMP,

    CurrentStatusId      INT NOT NULL,
    RequiredSignatures   INT NOT NULL DEFAULT 0,
    CompletedSignatures  INT NOT NULL DEFAULT 0,

    ReadyForPrint        BOOLEAN DEFAULT FALSE,
    PrintedDate          DATETIME NULL,
    DeliveredDate         DATETIME NULL,

    Remarks               TEXT,

    UpdateAt              DATETIME NULL,
    UpdateBy               INT NULL,

    FOREIGN KEY (CompanyId)       REFERENCES Company(CompanyId),
    FOREIGN KEY (DepartmentId)    REFERENCES Department(DepartmentId),
    FOREIGN KEY (BankAccountId)   REFERENCES BankAccount(BankAccountId),
    FOREIGN KEY (CurrentStatusId) REFERENCES ChequeStatus(StatusId)
);


-- =====================================================================
-- 9. SUPPORTING DOCUMENTS
-- =====================================================================
CREATE TABLE ChequeSupportingDocument (
    DocumentId        INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId   INT NOT NULL,
    DocumentName      VARCHAR(255) NOT NULL,
    FilePath          VARCHAR(500) NOT NULL,
    DocumentType      VARCHAR(50),             -- e.g. Invoice, PO, Quotation
    UploadedBy        INT NOT NULL,
    UploadedDate      DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsMandatory       BOOLEAN DEFAULT FALSE,
    
    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId)
);


-- =====================================================================
-- 10. DOCUMENT REVIEW
-- First signer must review.
-- Business Rule:
--   - Before 1st signature -> review mandatory.
--   - After 1st signature  -> no further review required.
-- =====================================================================
CREATE TABLE ChequeDocumentReview (
    ReviewId          INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId   INT NOT NULL,
    EmployeeId        INT NOT NULL,
    ReviewedDate      DATETIME NOT NULL,
    Comments          TEXT,
    IsApproved        BOOLEAN NOT NULL,
    
    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    FOREIGN KEY (EmployeeId)      REFERENCES Employee(EmployeeId)
);


-- =====================================================================
-- 11. SIGNATURE LOG
-- =====================================================================
CREATE TABLE ChequeSignature (
    ChequeSignatureId   INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId     INT NOT NULL,
    EmployeeId          INT NOT NULL,
    SignatureId         INT NOT NULL,
    SigningOrder        INT NOT NULL,
    ActionDate          DATETIME NOT NULL,
    ActionType          ENUM('SIGNED', 'REJECTED', 'REVERTED', 'SKIPPED') NOT NULL,
    
    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    FOREIGN KEY (EmployeeId)      REFERENCES Employee(EmployeeId),
    FOREIGN KEY (SignatureId)     REFERENCES EmployeeSignature(SignatureId)
);


-- =====================================================================
-- 13. REVERT HISTORY
-- =====================================================================
CREATE TABLE ChequeRevert (
    RevertId          INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId   INT NOT NULL,
    FromEmployeeId    INT NOT NULL,
    ToDepartmentId    INT NOT NULL,
    Reason            TEXT,
    RevertedDate      DATETIME NOT NULL,
    Resolved          BOOLEAN DEFAULT FALSE,

    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    FOREIGN KEY (FromEmployeeId)  REFERENCES Employee(EmployeeId),
    FOREIGN KEY (ToDepartmentId)  REFERENCES Department(DepartmentId)
);


-- =====================================================================
-- 15. PRINT LOG
-- =====================================================================
CREATE TABLE ChequePrintLog (
    PrintId           INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId   INT NOT NULL,
    PrintedBy         INT NOT NULL,
    PrintedDate       DATETIME DEFAULT CURRENT_TIMESTAMP,
    PrintCount        INT DEFAULT 1,
    PrinterName       VARCHAR(150),
    Remarks           TEXT,
    
    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    FOREIGN KEY (PrintedBy)       REFERENCES Employee(EmployeeId)
);


-- =====================================================================
-- 16. DELIVERY LOG
-- =====================================================================
CREATE TABLE ChequeDelivery (
    DeliveryId        INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId   INT NOT NULL,
    DeliveredTo       VARCHAR(150) NOT NULL,
    DeliveredDate     DATETIME NOT NULL,
    ReceivedBy        VARCHAR(150),
    Remarks           TEXT,

    CreatedAt         DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy         INT,
    UpdateAt          DATETIME NULL,
    UpdateBy          INT NULL,

    FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId)
);


-- =====================================================================
-- EMPLOYEE LOGIN / CREDENTIALS
-- =====================================================================
CREATE TABLE EmployeeCredentials (
    CredentialId         INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeId           INT NOT NULL UNIQUE,
    PasswordHash         VARCHAR(255) NOT NULL,    -- never store plain text passwords
    Role                 VARCHAR(50) NOT NULL,     -- e.g. Admin, Approver, Employee
    LastLoginAt          DATETIME NULL,
    FailedLoginAttempts  INT DEFAULT 0,
    IsLocked             BOOLEAN DEFAULT FALSE,

    CreatedAt            DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy             INT,
    UpdateAt              DATETIME NULL,
    UpdateBy               INT NULL,

    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);