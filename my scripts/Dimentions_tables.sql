-- dimension schema
CREATE SCHEMA dimension;

CREATE TABLE dimension.Dim_Customer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  VARCHAR(10),
    FullName    VARCHAR(100),
    Gender      VARCHAR(10),
    Age         INT,
    City        VARCHAR(100),
    Country     VARCHAR(100),
    StartDate   DATE,
    EndDate     DATE,
    IsCurrent   BIT
);

CREATE TABLE dimension.Dim_Card (
    CardKey      INT IDENTITY(1,1) PRIMARY KEY,
    CardID       VARCHAR(10),
    CustomerID   VARCHAR(10),
    CardType     VARCHAR(20),
    CreditLimit  DECIMAL(18,2),
    StartDate    DATE,
    EndDate      DATE,
    IsCurrent    BIT
);

CREATE TABLE dimension.Dim_Merchant (
    MerchantKey  INT IDENTITY(1,1) PRIMARY KEY,
    MerchantName VARCHAR(100),
    Category     VARCHAR(50),
    City         VARCHAR(100),
    Country      VARCHAR(100),
    StartDate    DATE,
    EndDate      DATE,
    IsCurrent    BIT
);

CREATE TABLE dimension.Dim_Date (
    DateKey  INT PRIMARY KEY,
    FullDate DATE,
    Day      INT,
    Month    INT,
    Year     INT,
    Quarter  INT,
    WeekDay  VARCHAR(20)
);

CREATE TABLE dimension.Fact_Transactions (
    TransactionKey  BIGINT IDENTITY(1,1) PRIMARY KEY,
    CustomerKey     INT,
    CardKey         INT,
    MerchantKey     INT,
    DateKey         INT,
    TransactionID   VARCHAR(20),
    Amount          DECIMAL(18,2),
    TransactionType VARCHAR(20),
    Status          VARCHAR(20),
    FraudFlag       BIT,
    Channel         VARCHAR(20)
);