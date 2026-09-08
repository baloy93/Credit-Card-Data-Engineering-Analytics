-- staging schema
CREATE SCHEMA staging;

CREATE TABLE staging.Stg_Customers (
    CustomerID  VARCHAR(10),
    FullName    VARCHAR(100),
    Gender      VARCHAR(10),
    Age         INT,
    City        VARCHAR(100),
    Country     VARCHAR(100),
    LoadDate    DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging.Stg_Cards (
    CardID       VARCHAR(10),
    CustomerID   VARCHAR(10),
    CardType     VARCHAR(20),
    CreditLimit  DECIMAL(18,2),
    IssueDate    DATE,
    LoadDate     DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging.Stg_Transactions (
    TransactionID   VARCHAR(20),
    CustomerID      VARCHAR(10),
    CardID          VARCHAR(10),
    MerchantName    VARCHAR(100),
    TransactionDate DATE,
    Amount          DECIMAL(18,2),
    TransactionType VARCHAR(20),
    Status          VARCHAR(20),
    FraudFlag       BIT,
    Channel         VARCHAR(20),
    LoadDate        DATETIME DEFAULT GETDATE()
);

CREATE TABLE staging.Stg_Merchants (
    MerchantID   VARCHAR(10),
    MerchantName VARCHAR(100),
    Category     VARCHAR(50),
    City         VARCHAR(100),
    Country      VARCHAR(100)
);