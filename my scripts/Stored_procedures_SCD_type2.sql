CREATE OR ALTER PROCEDURE sp_load_Dim_Date
AS
BEGIN
    SET NOCOUNT ON;

    -- load all dates from clean transactions, skip ones already in the table
    INSERT INTO dimension.Dim_Date
    (DateKey, FullDate, Day, Month, Year, Quarter, WeekDay)
    SELECT DISTINCT
        CAST(FORMAT(CAST(TransactionDate AS DATE), 'yyyyMMdd') AS INT),
        CAST(TransactionDate AS DATE),
        DAY(CAST(TransactionDate AS DATE)),
        MONTH(CAST(TransactionDate AS DATE)),
        YEAR(CAST(TransactionDate AS DATE)),
        DATEPART(QUARTER, CAST(TransactionDate AS DATE)),
        DATENAME(WEEKDAY, CAST(TransactionDate AS DATE))
    FROM staging.Stg_Clean_Transactions
    WHERE TransactionDate IS NOT NULL
      AND CAST(FORMAT(CAST(TransactionDate AS DATE), 'yyyyMMdd') AS INT)
              NOT IN (SELECT DateKey FROM dimension.Dim_Date);
END

CREATE OR ALTER PROCEDURE sp_load_Dim_Customer
AS
BEGIN
    SET NOCOUNT ON;

    -- expire changed records
    UPDATE dimension.Dim_Customer
    SET
        EndDate   = CAST(GETDATE() AS DATE),
        IsCurrent = 0
    WHERE IsCurrent = 1
      AND CustomerID IN (
          SELECT s.CustomerID
          FROM staging.Stg_Clean_Customers s
          INNER JOIN dimension.Dim_Customer d
              ON  s.CustomerID = d.CustomerID
              AND d.IsCurrent  = 1
          WHERE s.FullName != d.FullName
             OR s.Gender   != d.Gender
             OR s.Age      != d.Age
             OR s.City     != d.City
             OR s.Country  != d.Country
      );

    -- insert new and updated records
    INSERT INTO dimension.Dim_Customer
    (CustomerID, FullName, Gender, Age, City, Country, StartDate, EndDate, IsCurrent)
    SELECT
        s.CustomerID,
        s.FullName,
        s.Gender,
        s.Age,
        s.City,
        s.Country,
        CAST(GETDATE() AS DATE),
        NULL,
        1
    FROM staging.Stg_Clean_Customers s
    WHERE s.CustomerID IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dimension.Dim_Customer d
          WHERE d.CustomerID = s.CustomerID
            AND d.IsCurrent  = 1
      );
END

CREATE OR ALTER PROCEDURE sp_load_Dim_Card
AS
BEGIN
    SET NOCOUNT ON;

    -- expire changed records
    UPDATE dimension.Dim_Card
    SET
        EndDate   = CAST(GETDATE() AS DATE),
        IsCurrent = 0
    WHERE IsCurrent = 1
      AND CardID IN (
          SELECT s.CardID
          FROM staging.Stg_Clean_Cards s
          INNER JOIN dimension.Dim_Card d
              ON  s.CardID    = d.CardID
              AND d.IsCurrent = 1
          WHERE s.CardType    != d.CardType
             OR s.CreditLimit != d.CreditLimit
      );

    -- insert new and updated records
    INSERT INTO dimension.Dim_Card
    (CardID, CustomerID, CardType, CreditLimit, StartDate, EndDate, IsCurrent)
    SELECT
        s.CardID,
        s.CustomerID,
        s.CardType,
        TRY_CAST(REPLACE(CAST(s.CreditLimit AS VARCHAR(50)), ',', '') AS DECIMAL(18,2)),
        CAST(GETDATE() AS DATE),
        NULL,
        1
    FROM staging.Stg_Clean_Cards s
    WHERE s.CardID     IS NOT NULL
      AND s.CustomerID IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dimension.Dim_Card d
          WHERE d.CardID    = s.CardID
            AND d.IsCurrent = 1
      );
END

CREATE OR ALTER PROCEDURE sp_load_Dim_Merchant
AS
BEGIN
    SET NOCOUNT ON;

    -- expire changed records
    UPDATE dimension.Dim_Merchant
    SET
        EndDate   = CAST(GETDATE() AS DATE),
        IsCurrent = 0
    WHERE IsCurrent = 1
      AND MerchantName IN (
          SELECT s.MerchantName
          FROM staging.Stg_Clean_Merchants s
          INNER JOIN dimension.Dim_Merchant d
              ON  s.MerchantName = d.MerchantName
              AND d.IsCurrent    = 1
          WHERE s.Category != d.Category
             OR s.City     != d.City
             OR s.Country  != d.Country
      );

    -- insert new and updated records
    INSERT INTO dimension.Dim_Merchant
    (MerchantName, Category, City, Country, StartDate, EndDate, IsCurrent)
    SELECT
        s.MerchantName,
        s.Category,
        s.City,
        s.Country,
        CAST(GETDATE() AS DATE),
        NULL,
        1
    FROM staging.Stg_Clean_Merchants s
    WHERE s.MerchantName IS NOT NULL
      AND TRIM(s.MerchantName) != ''
      AND NOT EXISTS (
          SELECT 1
          FROM dimension.Dim_Merchant d
          WHERE d.MerchantName = s.MerchantName
            AND d.IsCurrent    = 1
      );
END

CREATE OR ALTER PROCEDURE sp_load_Fact_Transactions
AS
BEGIN
    SET NOCOUNT ON;

    -- insert transactions only when all keys are found
    INSERT INTO dimension.Fact_Transactions
    (
        CustomerKey,
        CardKey,
        MerchantKey,
        DateKey,
        TransactionID,
        Amount,
        TransactionType,
        Status,
        FraudFlag,
        Channel
    )
    SELECT
        c.CustomerKey,
        ca.CardKey,
        m.MerchantKey,
        d.DateKey,
        s.TransactionID,
        s.Amount,
        s.TransactionType,
        s.Status,
        s.FraudFlag,
        s.Channel
    FROM staging.Stg_Clean_Transactions s

    LEFT JOIN dimension.Dim_Customer c
        ON  s.CustomerID = c.CustomerID
        AND c.IsCurrent  = 1

    LEFT JOIN dimension.Dim_Card ca
        ON  s.CardID     = ca.CardID
        AND ca.IsCurrent = 1

    LEFT JOIN dimension.Dim_Merchant m
        ON  s.MerchantName = m.MerchantName
        AND m.IsCurrent    = 1

    LEFT JOIN dimension.Dim_Date d
        ON  d.DateKey = CAST(
                FORMAT(CAST(s.TransactionDate AS DATE), 'yyyyMMdd')
            AS INT)

    WHERE s.TransactionID IS NOT NULL
      AND c.CustomerKey   IS NOT NULL
      AND ca.CardKey      IS NOT NULL
      AND m.MerchantKey   IS NOT NULL
      AND d.DateKey       IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dimension.Fact_Transactions f
          WHERE f.TransactionID = s.TransactionID
      );

    -- fix any rows that loaded with null keys
    UPDATE f
    SET
        f.CustomerKey  = c.CustomerKey,
        f.CardKey      = ca.CardKey,
        f.MerchantKey  = m.MerchantKey,
        f.DateKey      = d.DateKey
    FROM dimension.Fact_Transactions f
    LEFT JOIN staging.Stg_Clean_Transactions s
        ON  f.TransactionID = s.TransactionID
    LEFT JOIN dimension.Dim_Customer c
        ON  s.CustomerID   = c.CustomerID
        AND c.IsCurrent    = 1
    LEFT JOIN dimension.Dim_Card ca
        ON  s.CardID       = ca.CardID
        AND ca.IsCurrent   = 1
    LEFT JOIN dimension.Dim_Merchant m
        ON  s.MerchantName = m.MerchantName
        AND m.IsCurrent    = 1
    LEFT JOIN dimension.Dim_Date d
        ON  d.DateKey = CAST(
                FORMAT(CAST(s.TransactionDate AS DATE), 'yyyyMMdd')
            AS INT)
    WHERE f.CustomerKey IS NULL
       OR f.CardKey     IS NULL
       OR f.MerchantKey IS NULL
       OR f.DateKey     IS NULL;

END

