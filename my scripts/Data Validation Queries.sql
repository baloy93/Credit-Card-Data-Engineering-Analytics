-- row counts across all layers
SELECT 'Stg_Customers'       AS TableName, COUNT(*) AS Rows FROM staging.Stg_Customers
UNION ALL
SELECT 'Stg_Cards',           COUNT(*) FROM staging.Stg_Cards
UNION ALL
SELECT 'Stg_Transactions',    COUNT(*) FROM staging.Stg_Transactions
UNION ALL
SELECT 'Stg_Merchants',       COUNT(*) FROM staging.Stg_Merchants
UNION ALL
SELECT 'Stg_Clean_Customers', COUNT(*) FROM staging.Stg_Clean_Customers
UNION ALL
SELECT 'Stg_Clean_Cards',     COUNT(*) FROM staging.Stg_Clean_Cards
UNION ALL
SELECT 'Stg_Clean_Transactions', COUNT(*) FROM staging.Stg_Clean_Transactions
UNION ALL
SELECT 'Stg_Clean_Merchants', COUNT(*) FROM staging.Stg_Clean_Merchants
UNION ALL
SELECT 'Dim_Customer',        COUNT(*) FROM dimension.Dim_Customer
UNION ALL
SELECT 'Dim_Card',            COUNT(*) FROM dimension.Dim_Card
UNION ALL
SELECT 'Dim_Merchant',        COUNT(*) FROM dimension.Dim_Merchant
UNION ALL
SELECT 'Dim_Date',            COUNT(*) FROM dimension.Dim_Date
UNION ALL
SELECT 'Fact_Transactions',   COUNT(*) FROM dimension.Fact_Transactions;


-- check dirty data in raw staging
SELECT Gender, COUNT(*) AS Count
FROM staging.Stg_Customers
GROUP BY Gender
ORDER BY Count DESC;

SELECT
    SUM(CASE WHEN Age IS NULL   THEN 1 ELSE 0 END) AS Null_Age,
    SUM(CASE WHEN Age < 18      THEN 1 ELSE 0 END) AS Age_Below_18,
    SUM(CASE WHEN Age > 100     THEN 1 ELSE 0 END) AS Age_Above_100,
    COUNT(*)                                         AS Total_Rows
FROM staging.Stg_Customers;

SELECT
    SUM(CASE WHEN FullName IS NULL OR FullName = '' THEN 1 ELSE 0 END) AS Null_FullName,
    SUM(CASE WHEN City     IS NULL OR City     = '' THEN 1 ELSE 0 END) AS Null_City,
    COUNT(*)                                                            AS Total_Rows
FROM staging.Stg_Customers;

SELECT Country, COUNT(*) AS Count
FROM staging.Stg_Customers
GROUP BY Country
ORDER BY Count DESC;

SELECT CustomerID, COUNT(*) AS Occurrences
FROM staging.Stg_Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY Occurrences DESC;

SELECT
    SUM(CASE WHEN CardType  IS NULL OR CardType = '' THEN 1 ELSE 0 END) AS Blank_CardType,
    SUM(CASE WHEN IssueDate IS NULL                  THEN 1 ELSE 0 END) AS Null_IssueDate,
    COUNT(*)                                                             AS Total_Rows
FROM staging.Stg_Cards;

SELECT TransactionType, COUNT(*) AS Count
FROM staging.Stg_Transactions
GROUP BY TransactionType
ORDER BY Count DESC;

SELECT
    SUM(CASE WHEN Amount < 0  THEN 1 ELSE 0 END) AS Negative_Amounts,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS Null_Channel,
    COUNT(*)                                          AS Total_Rows
FROM staging.Stg_Transactions;


-- check clean staging is correct after dataflow
SELECT Gender, COUNT(*) AS Count
FROM staging.Stg_Clean_Customers
GROUP BY Gender
ORDER BY Count DESC;

SELECT Country, COUNT(*) AS Count
FROM staging.Stg_Clean_Customers
GROUP BY Country
ORDER BY Count DESC;

SELECT CustomerID, COUNT(*) AS Occurrences
FROM staging.Stg_Clean_Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;

SELECT
    SUM(CASE WHEN Amount < 0 THEN 1 ELSE 0 END) AS Negative_Amounts,
    MIN(Amount)                                   AS Min_Amount,
    MAX(Amount)                                   AS Max_Amount,
    COUNT(*)                                      AS Total_Rows
FROM staging.Stg_Clean_Transactions;

SELECT TransactionType, COUNT(*) AS Count
FROM staging.Stg_Clean_Transactions
GROUP BY TransactionType
ORDER BY Count DESC;



-- check null surrogate keys in fact table
SELECT
    SUM(CASE WHEN CustomerKey  IS NULL THEN 1 ELSE 0 END) AS Missing_CustomerKey,
    SUM(CASE WHEN CardKey      IS NULL THEN 1 ELSE 0 END) AS Missing_CardKey,
    SUM(CASE WHEN MerchantKey  IS NULL THEN 1 ELSE 0 END) AS Missing_MerchantKey,
    SUM(CASE WHEN DateKey      IS NULL THEN 1 ELSE 0 END) AS Missing_DateKey,
    COUNT(*)                                               AS Total_Rows
FROM dimension.Fact_Transactions;



-- SCD Type 2 verification
SELECT
    CustomerID,
    FullName,
    Age,
    City,
    StartDate,
    EndDate,
    IsCurrent,
    CASE WHEN IsCurrent = 1 THEN 'Active' ELSE 'Expired' END AS RecordStatus
FROM dimension.Dim_Customer
WHERE CustomerID IN (
    SELECT CustomerID
    FROM dimension.Dim_Customer
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
)
ORDER BY CustomerID, StartDate;

SELECT
    CardID,
    CardType,
    CreditLimit,
    StartDate,
    EndDate,
    IsCurrent,
    CASE WHEN IsCurrent = 1 THEN 'Active' ELSE 'Expired' END AS RecordStatus
FROM dimension.Dim_Card
WHERE CardID IN (
    SELECT CardID
    FROM dimension.Dim_Card
    GROUP BY CardID
    HAVING COUNT(*) > 1
)
ORDER BY CardID, StartDate;

SELECT
    MerchantName,
    Category,
    StartDate,
    EndDate,
    IsCurrent,
    CASE WHEN IsCurrent = 1 THEN 'Active' ELSE 'Expired' END AS RecordStatus
FROM dimension.Dim_Merchant
WHERE MerchantName IN (
    SELECT MerchantName
    FROM dimension.Dim_Merchant
    GROUP BY MerchantName
    HAVING COUNT(*) > 1
)
ORDER BY MerchantName, StartDate;



-- pick one customer with two versions for presentation
SELECT
    CustomerID,
    FullName,
    Gender,
    Age,
    City,
    StartDate,
    EndDate,
    IsCurrent,
    CASE WHEN IsCurrent = 1 THEN 'Active' ELSE 'Expired' END AS RecordStatus
FROM dimension.Dim_Customer
WHERE CustomerID = (
    SELECT TOP 1 CustomerID
    FROM dimension.Dim_Customer
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
    ORDER BY CustomerID
)
ORDER BY StartDate;



-- spending by merchant category
SELECT
    m.Category,
    COUNT(f.TransactionKey)  AS Transactions,
    ROUND(SUM(f.Amount), 2)  AS Total_Spent,
    ROUND(AVG(f.Amount), 2)  AS Avg_Transaction
FROM dimension.Fact_Transactions f
INNER JOIN dimension.Dim_Merchant m
    ON f.MerchantKey = m.MerchantKey
GROUP BY m.Category
ORDER BY Total_Spent DESC;

-- spending by card type
SELECT
    ca.CardType,
    COUNT(f.TransactionKey)       AS Transactions,
    ROUND(SUM(f.Amount), 2)       AS Total_Spent,
    ROUND(AVG(f.Amount), 2)       AS Avg_Transaction,
    ROUND(AVG(ca.CreditLimit), 2) AS Avg_Credit_Limit
FROM dimension.Fact_Transactions f
INNER JOIN dimension.Dim_Card ca
    ON f.CardKey = ca.CardKey
GROUP BY ca.CardType
ORDER BY Total_Spent DESC;

-- monthly spending trend
SELECT
    d.Year,
    d.Month,
    COUNT(f.TransactionKey)  AS Transactions,
    ROUND(SUM(f.Amount), 2)  AS Total_Spent
FROM dimension.Fact_Transactions f
INNER JOIN dimension.Dim_Date d
    ON f.DateKey = d.DateKey
GROUP BY d.Year, d.Month
ORDER BY d.Year, d.Month;

-- top 10 customers by total spend
SELECT TOP 10
    c.CustomerID,
    c.FullName,
    c.City,
    COUNT(f.TransactionKey)  AS Transactions,
    ROUND(SUM(f.Amount), 2)  AS Total_Spent
FROM dimension.Fact_Transactions f
INNER JOIN dimension.Dim_Customer c
    ON f.CustomerKey = c.CustomerKey
WHERE c.IsCurrent = 1
GROUP BY c.CustomerID, c.FullName, c.City
ORDER BY Total_Spent DESC;

-- fraud summary
SELECT
    SUM(CASE WHEN FraudFlag = 1 THEN 1 ELSE 0 END)                AS Fraud_Transactions,
    SUM(CASE WHEN FraudFlag = 0 THEN 1 ELSE 0 END)                AS Clean_Transactions,
    ROUND(SUM(CASE WHEN FraudFlag = 1 THEN Amount ELSE 0 END), 2) AS Fraud_Amount,
    COUNT(*)                                                        AS Total_Rows
FROM dimension.Fact_Transactions;