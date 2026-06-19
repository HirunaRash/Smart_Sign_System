CREATE DATABASE ChequeWorkflowDB;
USE ChequeWorkflowDB;

-- 1. Company Table
CREATE TABLE Company (
    CompanyId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyCode VARCHAR(50) NOT NULL UNIQUE,
    CompanyName VARCHAR(255) NOT NULL,
    IsActive TINYINT(1) DEFAULT 1,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Department Table
CREATE TABLE Department (
    DepartmentId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId INT NOT NULL,
    DepartmentCode VARCHAR(50) NOT NULL,
    DepartmentName VARCHAR(255) NOT NULL,
    IsActive TINYINT(1) DEFAULT 1,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Department_Company FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId)
);

-- 3. Employee Table
CREATE TABLE Employee (
    EmployeeId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId INT NOT NULL,
    DepartmentId INT NOT NULL,
    EmployeeNo VARCHAR(50) NOT NULL UNIQUE,
    EmployeeName VARCHAR(255) NOT NULL,
    Designation VARCHAR(100),
    Email VARCHAR(100) UNIQUE,
    Mobile VARCHAR(20),
    IsActive TINYINT(1) DEFAULT 1,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Employee_Company FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId),
    CONSTRAINT FK_Employee_Department FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId)
);

-- 4. Electronic Signature Table
CREATE TABLE EmployeeSignature (
    SignatureId INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeId INT NOT NULL,
    SignatureImage LONGBLOB, -- රූපය (Image file) database එකේම save කිරීමට හෝ path එකක් ලෙස VARCHAR භාවිතා කළ හැක
    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,
    IsDefault TINYINT(1) DEFAULT 0,
    IsActive TINYINT(1) DEFAULT 1,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_Signature_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

-- 14. Cheque Template Table (Bank Account එකට පෙර නිර්මාණය කළ යුතුය)
CREATE TABLE ChequeTemplate (
    TemplateId INT AUTO_INCREMENT PRIMARY KEY,
    TemplateName VARCHAR(100) NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    Width DECIMAL(10,2),
    Height DECIMAL(10,2),
    DateX DECIMAL(10,2), DateY DECIMAL(10,2),
    PayeeX DECIMAL(10,2), PayeeY DECIMAL(10,2),
    AmountX DECIMAL(10,2), AmountY DECIMAL(10,2),
    AmountWordsX DECIMAL(10,2), AmountWordsY DECIMAL(10,2),
    Signature1X DECIMAL(10,2), Signature1Y DECIMAL(10,2),
    Signature2X DECIMAL(10,2), Signature2Y DECIMAL(10,2),
    Signature3X DECIMAL(10,2), Signature3Y DECIMAL(10,2),
    IsActive TINYINT(1) DEFAULT 1
);

-- 7. Bank Account Table
CREATE TABLE BankAccount (
    BankAccountId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId INT NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    Branch VARCHAR(100),
    AccountNo VARCHAR(50) NOT NULL UNIQUE,
    AccountName VARCHAR(150) NOT NULL,
    ChequeTemplateId INT,
    IsActive TINYINT(1) DEFAULT 1,
    CONSTRAINT FK_BankAccount_Company FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId),
    CONSTRAINT FK_BankAccount_Template FOREIGN KEY (ChequeTemplateId) REFERENCES ChequeTemplate(TemplateId)
);

-- 5. Cheque Signing Rule Table
CREATE TABLE ChequeSigningRule (
    RuleId INT AUTO_INCREMENT PRIMARY KEY,
    CompanyId INT NOT NULL,
    DepartmentId INT NULL, -- NULL විය හැකි බව සඳහන් කර ඇත
    BankAccountId INT NOT NULL,
    MinAmount DECIMAL(18,2) NOT NULL,
    MaxAmount DECIMAL(18,2) NOT NULL,
    RequiredSignatures INT NOT NULL,
    IsSequentialSigning TINYINT(1) DEFAULT 1,
    IsActive TINYINT(1) DEFAULT 1,
    CONSTRAINT FK_Rule_Company FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId),
    CONSTRAINT FK_Rule_Department FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId),
    CONSTRAINT FK_Rule_BankAccount FOREIGN KEY (BankAccountId) REFERENCES BankAccount(BankAccountId)
);

-- 6. Authorized Signatories Table
CREATE TABLE ChequeSigningRuleUser (
    RuleUserId INT AUTO_INCREMENT PRIMARY KEY,
    RuleId INT NOT NULL,
    EmployeeId INT NOT NULL,
    SigningOrder INT NOT NULL,
    CanApprove TINYINT(1) DEFAULT 1,
    CanReject TINYINT(1) DEFAULT 1,
    CanRevert TINYINT(1) DEFAULT 1,
    CONSTRAINT FK_RuleUser_Rule FOREIGN KEY (RuleId) REFERENCES ChequeSigningRule(RuleId),
    CONSTRAINT FK_RuleUser_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

-- 12. Status Master Table
CREATE TABLE ChequeStatus (
    StatusId INT AUTO_INCREMENT PRIMARY KEY,
    StatusCode VARCHAR(50) NOT NULL UNIQUE,
    StatusName VARCHAR(100) NOT NULL,
    DisplayOrder INT
);

-- 8. Cheque Request Table (Main transaction table)
CREATE TABLE ChequeRequest (
    ChequeRequestId INT AUTO_INCREMENT PRIMARY KEY,
    RequestNo VARCHAR(50) NOT NULL UNIQUE,
    CompanyId INT NOT NULL,
    DepartmentId INT NOT NULL,
    PayeeName VARCHAR(255) NOT NULL,
    ChequeAmount DECIMAL(18,2) NOT NULL,
    ChequeDate DATE NOT NULL,
    Purpose TEXT,
    BankAccountId INT NOT NULL,
    CreatedBy INT NOT NULL,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CurrentStatusId INT NOT NULL,
    RequiredSignatures INT DEFAULT 1,
    CompletedSignatures INT DEFAULT 0,
    ReadyForPrint TINYINT(1) DEFAULT 0,
    PrintedDate DATETIME NULL,
    DeliveredDate DATETIME NULL,
    Remarks TEXT,
    CONSTRAINT FK_Request_Company FOREIGN KEY (CompanyId) REFERENCES Company(CompanyId),
    CONSTRAINT FK_Request_Department FOREIGN KEY (DepartmentId) REFERENCES Department(DepartmentId),
    CONSTRAINT FK_Request_BankAccount FOREIGN KEY (BankAccountId) REFERENCES BankAccount(BankAccountId),
    CONSTRAINT FK_Request_Employee FOREIGN KEY (CreatedBy) REFERENCES Employee(EmployeeId),
    CONSTRAINT FK_Request_Status FOREIGN KEY (CurrentStatusId) REFERENCES ChequeStatus(StatusId)
);

-- 9. Supporting Documents Table
CREATE TABLE ChequeSupportingDocument (
    DocumentId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    DocumentName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    DocumentType VARCHAR(50),
    UploadedBy INT NOT NULL,
    UploadedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    IsMandatory TINYINT(1) DEFAULT 0,
    CONSTRAINT FK_Doc_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    CONSTRAINT FK_Doc_Employee FOREIGN KEY (UploadedBy) REFERENCES Employee(EmployeeId)
);

-- 10. Document Review Table
CREATE TABLE ChequeDocumentReview (
    ReviewId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    EmployeeId INT NOT NULL,
    ReviewedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Comments TEXT,
    IsApproved TINYINT(1) NOT NULL,
    CONSTRAINT FK_Review_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    CONSTRAINT FK_Review_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

-- 11. Signature Log Table
CREATE TABLE ChequeSignature (
    ChequeSignatureId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    EmployeeId INT NOT NULL,
    SignatureId INT NOT NULL,
    SigningOrder INT NOT NULL,
    ActionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ActionType ENUM('SIGNED', 'REJECTED', 'REVERTED', 'SKIPPED') NOT NULL,
    CONSTRAINT FK_SigLog_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    CONSTRAINT FK_SigLog_Employee FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId),
    CONSTRAINT FK_SigLog_Signature FOREIGN KEY (SignatureId) REFERENCES EmployeeSignature(SignatureId)
);

-- 13. Revert History Table
CREATE TABLE ChequeRevert (
    RevertId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    FromEmployeeId INT NOT NULL,
    ToDepartmentId INT NOT NULL,
    Reason TEXT NOT NULL,
    RevertedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Resolved TINYINT(1) DEFAULT 0,
    CONSTRAINT FK_Revert_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    CONSTRAINT FK_Revert_Employee FOREIGN KEY (FromEmployeeId) REFERENCES Employee(EmployeeId),
    CONSTRAINT FK_Revert_Dept FOREIGN KEY (ToDepartmentId) REFERENCES Department(DepartmentId)
);

-- 15. Print Log Table
CREATE TABLE ChequePrintLog (
    PrintId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    PrintedBy INT NOT NULL,
    PrintedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PrintCount INT DEFAULT 1,
    PrinterName VARCHAR(100),
    Remarks TEXT,
    CONSTRAINT FK_Print_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId),
    CONSTRAINT FK_Print_Employee FOREIGN KEY (PrintedBy) REFERENCES Employee(EmployeeId)
);

-- 16. Delivery Log Table
CREATE TABLE ChequeDelivery (
    DeliveryId INT AUTO_INCREMENT PRIMARY KEY,
    ChequeRequestId INT NOT NULL,
    DeliveredTo VARCHAR(255) NOT NULL,
    DeliveredDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ReceivedBy VARCHAR(255),
    Remarks TEXT,
    CONSTRAINT FK_Delivery_Request FOREIGN KEY (ChequeRequestId) REFERENCES ChequeRequest(ChequeRequestId)
);