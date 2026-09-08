-- backdate all expired customer records to 6 months ago
UPDATE dimension.Dim_Customer
SET StartDate = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
WHERE IsCurrent = 0;

-- backdate all expired card records
UPDATE dimension.Dim_Card
SET StartDate = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
WHERE IsCurrent = 0;

-- backdate all expired merchant records
UPDATE dimension.Dim_Merchant
SET StartDate = DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
WHERE IsCurrent = 0;

-- set EndDate on expired customer records to one day before active record
UPDATE d
SET d.EndDate = DATEADD(DAY, -1, a.StartDate)
FROM dimension.Dim_Customer d
INNER JOIN dimension.Dim_Customer a
    ON  d.CustomerID = a.CustomerID
    AND a.IsCurrent  = 1
WHERE d.IsCurrent = 0;

-- set EndDate on expired card records
UPDATE d
SET d.EndDate = DATEADD(DAY, -1, a.StartDate)
FROM dimension.Dim_Card d
INNER JOIN dimension.Dim_Card a
    ON  d.CardID    = a.CardID
    AND a.IsCurrent = 1
WHERE d.IsCurrent = 0;

-- set EndDate on expired merchant records
UPDATE d
SET d.EndDate = DATEADD(DAY, -1, a.StartDate)
FROM dimension.Dim_Merchant d
INNER JOIN dimension.Dim_Merchant a
    ON  d.MerchantName = a.MerchantName
    AND a.IsCurrent    = 1
WHERE d.IsCurrent = 0;