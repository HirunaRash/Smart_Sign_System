CREATE DATABASE smart_sign_system;
USE smart_sign_system;

-- Departments table
CREATE TABLE Departments (
    DepartmentId    INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName  VARCHAR(100) NOT NULL UNIQUE,
    DepartmentCode  VARCHAR(50) NOT NULL,
    IsActive        BOOLEAN DEFAULT TRUE,
    CompanyId       INT,
    
    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL
);

-- Employees table
CREATE TABLE Employees (
    EmployeeId      INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentId    INT,
    FirstName        VARCHAR(150) NOT NULL,
    LastName         VARCHAR(150) NOT NULL,
    Email            VARCHAR(150) UNIQUE NOT NULL,

    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
	UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId)
);

-- Company table
CREATE TABLE Company (
    CompanyId      INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName         VARCHAR(150) NOT NULL,
    
    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
	UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL
);

-- Cheques table
CREATE TABLE Cheques (
    ChequeId            INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentId        INT NOT NULL,              -- department issue the Cheque sign to employees 
    ChequeNumber        VARCHAR(100) UNIQUE NOT NULL,
    
    FileData            MEDIUMBLOB NOT NULL,       -- stores photo up to 16MB
    FileType            VARCHAR(50),               -- JPG, PNG
    FileSize            INT,                       -- size in KB
    OriginalFileName    VARCHAR(255),
    
    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy           INT NULL,
    UpdateAt            DATETIME NULL,
    UpdateBy            INT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(DepartmentId)
);

-- Signatures table
CREATE TABLE EmployeeSignatures (
    SignatureId         INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeId          INT NOT NULL,
    
    SignatureImage      MEDIUMBLOB NOT NULL,        -- stores signature photo up to 16MB
    ImageType           VARCHAR(50),                -- JPG, PNG
    ImageSize           INT,                        -- size in KB
    OriginalFileName    VARCHAR(255),
    
    ValidFrom           DATETIME NOT NULL,          -- signature valid from date
    ValidTo             DATETIME NOT NULL,          -- signature valid to date
    IsActive            BOOLEAN DEFAULT TRUE,
    
    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy           INT,
    UpdateAt            DATETIME NULL,
    UpdateBy            INT NULL,
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);

-- Cheque Signing Rule table
CREATE TABLE ChequeSigningRule (
    RuleId          INT AUTO_INCREMENT PRIMARY KEY,
    RuleName        VARCHAR(100) NOT NULL,           -- e.g. "Single Signature Rule", "Dual Signature Rule"
    MinAmount       DECIMAL(15,2) NOT NULL,          -- minimum cheque amount for this rule
    MaxAmount       DECIMAL(15,2) NOT NULL,          -- maximum cheque amount for this rule
    RequiredSignatures  INT NOT NULL,                -- number of signatures required (1 or 2)
    IsActive        BOOLEAN DEFAULT TRUE,
    
    CreatedAt       DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy       INT,
    UpdateAt        DATETIME NULL,
    UpdateBy        INT NULL
);



-- Transaction table
CREATE TABLE Transactions (
    TransactionId       INT AUTO_INCREMENT PRIMARY KEY,
    ChequeId            INT NOT NULL,
    EmployeeId          INT NOT NULL,               -- employee who signed the cheque
    RuleId              INT NOT NULL,               -- signing rule applied for this transaction
    ChequeAmount        DECIMAL(15,2) NOT NULL,     -- cheque amount
    RequiredSignatures  INT NOT NULL,               -- how many signatures required (1 or 2)
    CollectedSignatures INT DEFAULT 0,              -- how many signatures collected so far
    Status              VARCHAR(30) DEFAULT 'Pending', -- Pending, Approved, Rejected
    Comments            TEXT,
    TransactionDate     DATETIME NOT NULL,          -- date of the transaction
    
    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy           INT NULL,
    UpdateAt            DATETIME NULL,
    UpdateBy            INT NULL,
    FOREIGN KEY (ChequeId)   REFERENCES Cheques(ChequeId),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId),
    FOREIGN KEY (RuleId)     REFERENCES ChequeSigningRule(RuleId)
);

-- Employee Credentials table
CREATE TABLE EmployeeCredentials (
    CredentialId        INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeId          INT NOT NULL UNIQUE,            -- one login per employee
    PasswordHash        VARCHAR(255) NOT NULL,           -- never store plain text passwords
    Role                VARCHAR(50) NOT NULL,            -- e.g. Admin, Approver, Employee
    LastLoginAt         DATETIME NULL,
    FailedLoginAttempts INT DEFAULT 0,
    IsLocked            BOOLEAN DEFAULT FALSE,

    CreatedAt           DATETIME DEFAULT CURRENT_TIMESTAMP,
    CreatedBy           INT,
    UpdateAt            DATETIME NULL,
    UpdateBy            INT NULL,
    FOREIGN KEY (EmployeeId) REFERENCES Employees(EmployeeId)
);


