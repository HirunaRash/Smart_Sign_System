-- ============================================================================
-- 1. DATABASE CREATION AND INITIALIZATION
-- ============================================================================
CREATE DATABASE IF NOT EXISTS SIGNET;
USE SIGNET;

-- ============================================================================
-- 2. TABLES CREATION
-- ============================================================================

-- Table 1: Company Details
CREATE TABLE Company (
    CompanyId INT NOT NULL AUTO_INCREMENT,
    CompanyCode VARCHAR(50) NOT NULL,
    CompanyName VARCHAR(250) NOT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (CompanyId)
);

-- Table 2: Department Details
CREATE TABLE Department (
    DepartmentId INT NOT NULL AUTO_INCREMENT,
    CompanyId INT NOT NULL,
    DepartmentCode VARCHAR(50) NOT NULL,
    DepartmentName VARCHAR(200) NOT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (DepartmentId)
);

-- Table 3: Employee Profiles
CREATE TABLE Employee (
    EmployeeId INT NOT NULL AUTO_INCREMENT,
    CompanyId INT NOT NULL,
    DepartmentId INT NOT NULL,
    EmployeeNo VARCHAR(50) NOT NULL,
    EmployeeName VARCHAR(200) NOT NULL,
    Designation VARCHAR(150) NULL,
    Email VARCHAR(255) NULL,
    Mobile VARCHAR(50) NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (EmployeeId)
);

-- Table 4: Authorized Employee Signatures
CREATE TABLE EmployeeSignature (
    SignatureId INT NOT NULL AUTO_INCREMENT,
    EmployeeId INT NOT NULL,
    SignatureImage LONGBLOB NULL, -- Stores binary signature image data
    ValidFrom DATE NOT NULL,
    ValidTo DATE NULL,
    IsDefault TINYINT(1) NOT NULL DEFAULT 0,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (SignatureId),
    CONSTRAINT CK_EmployeeSignature_ValidDate CHECK (ValidTo IS NULL OR ValidTo >= ValidFrom)
);

-- Table 5: Cheque Layout Templates
CREATE TABLE ChequeTemplate (
    ChequeTemplateId INT NOT NULL AUTO_INCREMENT,
    TemplateName VARCHAR(200) NOT NULL,
    BankName VARCHAR(200) NOT NULL,
    Width DECIMAL(10, 2) NOT NULL,
    Height DECIMAL(10, 2) NOT NULL,
    DateX DECIMAL(10, 2) NOT NULL,
    DateY DECIMAL(10, 2) NOT NULL,
    PayeeX DECIMAL(10, 2) NOT NULL,
    PayeeY DECIMAL(10, 2) NOT NULL,
    AmountX DECIMAL(10, 2) NOT NULL,
    AmountY DECIMAL(10, 2) NOT NULL,
    AmountWordsX DECIMAL(10, 2) NOT NULL,
    AmountWordsY DECIMAL(10, 2) NOT NULL,
    Signature1X DECIMAL(10, 2) NULL,
    Signature1Y DECIMAL(10, 2) NULL,
    Signature2X DECIMAL(10, 2) NULL,
    Signature2Y DECIMAL(10, 2) NULL,
    Signature3X DECIMAL(10, 2) NULL,
    Signature3Y DECIMAL(10, 2) NULL,
    Signature4X DECIMAL(10, 2) NULL,
    Signature4Y DECIMAL(10, 2) NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (ChequeTemplateId)
);

-- Table 6: Corporate Bank Accounts
CREATE TABLE BankAccount (
    BankAccountId INT NOT NULL AUTO_INCREMENT,
    CompanyId INT NOT NULL,
    BankName VARCHAR(200) NOT NULL,
    Branch VARCHAR(200) NOT NULL,
    AccountNo VARCHAR(100) NOT NULL,
    AccountName VARCHAR(250) NOT NULL,
    ChequeTemplateId INT NULL,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (BankAccountId)
);

-- Table 7: Cheque Lifecycle Statuses
CREATE TABLE ChequeStatus (
    StatusId INT NOT NULL AUTO_INCREMENT,
    StatusCode VARCHAR(50) NOT NULL,
    StatusName VARCHAR(100) NOT NULL,
    DisplayOrder INT NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (StatusId)
);

-- Table 8: Types of Supporting Documents
CREATE TABLE DocumentType (
    DocumentTypeId INT NOT NULL AUTO_INCREMENT,
    DocumentTypeCode VARCHAR(50) NOT NULL,
    DocumentTypeName VARCHAR(100) NOT NULL,
    Description VARCHAR(500) NULL,
    IsMandatoryByDefault TINYINT(1) NOT NULL DEFAULT 0,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    DisplayOrder INT NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (DocumentTypeId)
);

-- Table 9: Core Cheque Requests
CREATE TABLE ChequeRequest (
    ChequeRequestId INT NOT NULL AUTO_INCREMENT,
    RequestNo VARCHAR(50) NOT NULL,
    CompanyId INT NOT NULL,
    DepartmentId INT NOT NULL,
    PayeeName VARCHAR(250) NOT NULL,
    ChequeAmount DECIMAL(18, 2) NOT NULL,
    ChequeDate DATE NOT NULL,
    Purpose VARCHAR(1000) NULL,
    BankAccountId INT NOT NULL,
    StatusId INT NOT NULL,
    RequiredSignatures INT NOT NULL DEFAULT 0,
    CompletedSignatures INT NOT NULL DEFAULT 0,
    ReadyForPrint TINYINT(1) NOT NULL DEFAULT 0,
    PrintedDate DATETIME NULL,
    DeliveredDate DATETIME NULL,
    Remarks VARCHAR(1000) NULL,
    CreatedBy INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedDate DATETIME NULL,
    PRIMARY KEY (ChequeRequestId),
    CONSTRAINT CK_ChequeRequest_Amount CHECK (ChequeAmount > 0),
    CONSTRAINT CK_ChequeRequest_Signatures CHECK (RequiredSignatures >= 0 AND CompletedSignatures >= 0 AND CompletedSignatures <= RequiredSignatures)
);

-- Table 10: Cheque Delivery Tracking
CREATE TABLE ChequeDelivery (
    DeliveryId INT NOT NULL AUTO_INCREMENT,
    ChequeRequestId INT NOT NULL,
    DeliveredTo VARCHAR(250) NOT NULL,
    DeliveredDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ReceivedBy VARCHAR(250) NULL,
    Remarks VARCHAR(1000) NULL,
    PRIMARY KEY (DeliveryId)
);

-- Table 11: Uploaded Supporting Documents
CREATE TABLE ChequeSupportingDocument (
    DocumentId INT NOT NULL AUTO_INCREMENT,
    ChequeRequestId INT NOT NULL,
    DocumentTypeId INT NOT NULL,
    DocumentName VARCHAR(255) NOT NULL,
    DocumentImage LONGBLOB NOT NULL, -- Stores scanned document binary files
    IsMandatory TINYINT(1) NOT NULL DEFAULT 0,
    UploadedBy INT NOT NULL,
    UploadedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    IsDeleted TINYINT(1) NOT NULL DEFAULT 0,
    DeletedBy INT NULL,
    DeletedDate DATETIME NULL,
    PRIMARY KEY (DocumentId)
);

-- Table 12: Review History for Supporting Documents
CREATE TABLE ChequeDocumentReview (
    ReviewId INT NOT NULL AUTO_INCREMENT,
    DocumentId INT NOT NULL,
    EmployeeId INT NOT NULL,
    ReviewedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Comments VARCHAR(1000) NULL,
    IsApproved TINYINT(1) NOT NULL,
    PRIMARY KEY (ReviewId)
);

-- Table 13: Audit Trail for Cheque Printing Actions
CREATE TABLE ChequePrintLog (
    PrintId INT NOT NULL AUTO_INCREMENT,
    ChequeRequestId INT NOT NULL,
    PrintedBy INT NOT NULL,
    PrintedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PrintCount INT NOT NULL DEFAULT 1,
    PrinterName VARCHAR(255) NULL,
    Remarks VARCHAR(1000) NULL,
    PRIMARY KEY (PrintId),
    CONSTRAINT CK_ChequePrintLog_PrintCount CHECK (PrintCount > 0)
);

-- Table 14: Log for Reverted/Returned Cheque Requests
CREATE TABLE ChequeRevert (
    RevertId INT NOT NULL AUTO_INCREMENT,
    ChequeRequestId INT NOT NULL,
    FromEmployeeId INT NOT NULL,
    ToDepartmentId INT NOT NULL,
    Reason VARCHAR(2000) NOT NULL,
    RevertedDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Resolved TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (RevertId)
);

-- Table 15: Workflow Signatures Maintained per Request
CREATE TABLE ChequeSignature (
    ChequeSignatureId INT NOT NULL AUTO_INCREMENT,
    ChequeRequestId INT NOT NULL,
    EmployeeId INT NOT NULL,
    SignatureId INT NOT NULL,
    SigningOrder INT NOT NULL,
    ActionDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ActionType VARCHAR(50) NOT NULL,
    PRIMARY KEY (ChequeSignatureId),
    CONSTRAINT CK_ChequeSignature_ActionType CHECK (ActionType IN ('CANCELLED', 'SKIPPED', 'REJECTED', 'SIGNED')),
    CONSTRAINT CK_ChequeSignature_SigningOrder CHECK (SigningOrder > 0)
);

-- Table 16: Dynamic Matrix Criteria Rules for Required Signatures
CREATE TABLE ChequeSigningRule (
    RuleId INT NOT NULL AUTO_INCREMENT,
    CompanyId INT NOT NULL,
    DepartmentId INT NULL,
    BankAccountId INT NOT NULL,
    MinAmount DECIMAL(18, 2) NOT NULL,
    MaxAmount DECIMAL(18, 2) NOT NULL,
    RequiredSignatures INT NOT NULL,
    IsSequentialSigning TINYINT(1) NOT NULL DEFAULT 0,
    IsActive TINYINT(1) NOT NULL DEFAULT 1,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (RuleId),
    CONSTRAINT CK_ChequeSigningRule_AmountRange CHECK (MaxAmount >= MinAmount),
    CONSTRAINT CK_ChequeSigningRule_RequiredSignatures CHECK (RequiredSignatures > 0)
);

-- Table 17: User Mappings Assigning Users/Orders to Rules
CREATE TABLE ChequeSigningRuleUser (
    RuleUserId INT NOT NULL AUTO_INCREMENT,
    RuleId INT NOT NULL,
    EmployeeId INT NOT NULL,
    SigningOrder INT NOT NULL,
    CanApprove TINYINT(1) NOT NULL DEFAULT 1,
    CanReject TINYINT(1) NOT NULL DEFAULT 1,
    CanRevert TINYINT(1) NOT NULL DEFAULT 0,
    CreatedBy INT NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedBy INT NULL,
    UpdatedOn DATETIME NULL,
    PRIMARY KEY (RuleUserId),
    CONSTRAINT CK_ChequeSigningRuleUser_SigningOrder CHECK (SigningOrder > 0)
);


-- ============================================================================
-- 3. FOREIGN KEY RELATIONSHIPS (REFERENTIAL INTEGRITY)
-- ============================================================================

-- Department Constraints
ALTER TABLE Department ADD CONSTRAINT FK_Department_Company FOREIGN KEY(CompanyId) REFERENCES Company (CompanyId);

-- Employee Constraints
ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Company FOREIGN KEY(CompanyId) REFERENCES Company (CompanyId);
ALTER TABLE Employee ADD CONSTRAINT FK_Employee_Department FOREIGN KEY(DepartmentId) REFERENCES Department (DepartmentId);

-- EmployeeSignature Constraints
ALTER TABLE EmployeeSignature ADD CONSTRAINT FK_EmployeeSignature_Employee FOREIGN KEY(EmployeeId) REFERENCES Employee (EmployeeId);

-- BankAccount Constraints
ALTER TABLE BankAccount ADD CONSTRAINT FK_BankAccount_ChequeTemplate FOREIGN KEY(ChequeTemplateId) REFERENCES ChequeTemplate (ChequeTemplateId);
ALTER TABLE BankAccount ADD CONSTRAINT FK_BankAccount_Company FOREIGN KEY(CompanyId) REFERENCES Company (CompanyId);

-- ChequeRequest Constraints
ALTER TABLE ChequeRequest ADD CONSTRAINT FK_ChequeRequest_BankAccount FOREIGN KEY(BankAccountId) REFERENCES BankAccount (BankAccountId);
ALTER TABLE ChequeRequest ADD CONSTRAINT FK_ChequeRequest_Company FOREIGN KEY(CompanyId) REFERENCES Company (CompanyId);
ALTER TABLE ChequeRequest ADD CONSTRAINT FK_ChequeRequest_Department FOREIGN KEY(DepartmentId) REFERENCES Department (DepartmentId);
ALTER TABLE ChequeRequest ADD CONSTRAINT FK_ChequeRequest_Status FOREIGN KEY(StatusId) REFERENCES ChequeStatus (StatusId);

-- ChequeDelivery Constraints
ALTER TABLE ChequeDelivery ADD CONSTRAINT FK_ChequeDelivery_ChequeRequest FOREIGN KEY(ChequeRequestId) REFERENCES ChequeRequest (ChequeRequestId);

-- ChequeSupportingDocument Constraints
ALTER TABLE ChequeSupportingDocument ADD CONSTRAINT FK_ChequeSupportingDocument_ChequeRequest FOREIGN KEY(ChequeRequestId) REFERENCES ChequeRequest (ChequeRequestId);
ALTER TABLE ChequeSupportingDocument ADD CONSTRAINT FK_ChequeSupportingDocument_DocumentType FOREIGN KEY(DocumentTypeId) REFERENCES DocumentType (DocumentTypeId);

-- ChequeDocumentReview Constraints
ALTER TABLE ChequeDocumentReview ADD CONSTRAINT FK_ChequeDocumentReview_Document FOREIGN KEY(DocumentId) REFERENCES ChequeSupportingDocument (DocumentId);
ALTER TABLE ChequeDocumentReview ADD CONSTRAINT FK_ChequeDocumentReview_Employee FOREIGN KEY(EmployeeId) REFERENCES Employee (EmployeeId);

-- ChequePrintLog Constraints
ALTER TABLE ChequePrintLog ADD CONSTRAINT FK_ChequePrintLog_ChequeRequest FOREIGN KEY(ChequeRequestId) REFERENCES ChequeRequest (ChequeRequestId);
ALTER TABLE ChequePrintLog ADD CONSTRAINT FK_ChequePrintLog_Employee FOREIGN KEY(PrintedBy) REFERENCES Employee (EmployeeId);

-- ChequeRevert Constraints
ALTER TABLE ChequeRevert ADD CONSTRAINT FK_ChequeRevert_ChequeRequest FOREIGN KEY(ChequeRequestId) REFERENCES ChequeRequest (ChequeRequestId);
ALTER TABLE ChequeRevert ADD CONSTRAINT FK_ChequeRevert_FromEmployee FOREIGN KEY(FromEmployeeId) REFERENCES Employee (EmployeeId);
ALTER TABLE ChequeRevert ADD CONSTRAINT FK_ChequeRevert_ToDepartment FOREIGN KEY(ToDepartmentId) REFERENCES Department (DepartmentId);

-- ChequeSignature Constraints
ALTER TABLE ChequeSignature ADD CONSTRAINT FK_ChequeSignature_ChequeRequest FOREIGN KEY(ChequeRequestId) REFERENCES ChequeRequest (ChequeRequestId);
ALTER TABLE ChequeSignature ADD CONSTRAINT FK_ChequeSignature_Employee FOREIGN KEY(EmployeeId) REFERENCES Employee (EmployeeId);
ALTER TABLE ChequeSignature ADD CONSTRAINT FK_ChequeSignature_Signature FOREIGN KEY(SignatureId) REFERENCES EmployeeSignature (SignatureId);

-- ChequeSigningRule Constraints
ALTER TABLE ChequeSigningRule ADD CONSTRAINT FK_ChequeSigningRule_BankAccount FOREIGN KEY(BankAccountId) REFERENCES BankAccount (BankAccountId);
ALTER TABLE ChequeSigningRule ADD CONSTRAINT FK_ChequeSigningRule_Company FOREIGN KEY(CompanyId) REFERENCES Company (CompanyId);
ALTER TABLE ChequeSigningRule ADD CONSTRAINT FK_ChequeSigningRule_Department FOREIGN KEY(DepartmentId) REFERENCES Department (DepartmentId);

-- ChequeSigningRuleUser Constraints
ALTER TABLE ChequeSigningRuleUser ADD CONSTRAINT FK_ChequeSigningRuleUser_Employee FOREIGN KEY(EmployeeId) REFERENCES Employee (EmployeeId);
ALTER TABLE ChequeSigningRuleUser ADD CONSTRAINT FK_ChequeSigningRuleUser_Rule FOREIGN KEY(RuleId) REFERENCES ChequeSigningRule (RuleId);