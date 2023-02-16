`-- Data Preview
SELECT * 
FROM taiwanrealestate2


-- 1. Transaction Date Format
-- 1-1. Transaction year, month 
SELECT 
	����~���, 
	REVERSE(SUBSTRING(REVERSE(����~���), 5, 3)) + 1911 AS  transaction_year,
	REVERSE(SUBSTRING(REVERSE(����~���), 3, 2)) AS  transaction_month
FROM taiwanrealestate2 ;



-- *Update the datasets (only for this project, normally we dont update the dataset)
ALTER TABLE taiwanrealestate2
Add transaction_year INT;

ALTER TABLE taiwanrealestate2
ADD transaction_month INT;

UPDATE taiwanrealestate2
SET transaction_year = 
	(CASE WHEN   
			REVERSE(SUBSTRING(REVERSE(����~���), 5, 3)) + 1911 <= 1911 THEN null
		ELSE REVERSE(SUBSTRING(REVERSE(����~���), 5, 3)) + 1911
	 END),
	transaction_month = 
	(CASE WHEN 
		REVERSE(SUBSTRING(REVERSE(����~���), 3, 2))=0 THEN nULL
		ELSE REVERSE(SUBSTRING(REVERSE(����~���), 3, 2))
	 END) ;


ALTER TABLE dbo.taiwanrealestate2
ADD transaction_date VARCHAR(255) ;

UPDATE taiwanrealestate2
SET transaction_date = 
		(CASE 
		WHEN transaction_year is null OR transaction_month is null  THEN null
		ELSE 
			CONCAT(  
				REVERSE(SUBSTRING(REVERSE(����~���), 5, 3)) + 1911 ,
				REVERSE(SUBSTRING(REVERSE(����~���), 3, 2)) , 
				REVERSE(SUBSTRING(REVERSE(����~���), 1, 2))
					)
		END)

-- *Verify

SELECT 
	����~���, 
	transaction_year,
	transaction_month,
	transaction_date
FROM taiwanrealestate2 ;


-- 1-2. Extract the year_built from build_year
SELECT 
    �ؿv�����~�� AS build_year,
    111 - REVERSE(SUBSTRING(REVERSE(�ؿv�����~��), 5, 3)) AS year_built
FROM taiwanrealestate2 ;


-- *Update dataset
ALTER TABLE taiwanrealestate2
ADD year_built INT;

UPDATE taiwanrealestate2
SET year_built =  
	(CASE 
		WHEN LEN(�ؿv�����~��) > 1 THEN 111 - REVERSE(SUBSTRING(REVERSE(�ؿv�����~��), 5, 3))
		ELSE null
	END);


-- *Verify
SELECT 
	����~��� as TransactionDate,
    transaction_year,
    transaction_month,
	transaction_date,
    �ؿv�����~�� AS build_year,
	year_built
FROM taiwanrealestate2 ;


-- 2 Drop Incomplete or Incorrec Rows and Unused Columns
-- 2.1 Drop Incomplete or Incorrect Data(Rows)
DELETE 
FROM taiwanrealestate2
WHERE ��������褽�� = 0 OR			-- The transactions that did not disclosure price.
	  ��������褽�� is null OR		-- The transactions that price are 0
	  �g�a�����`���n���褽�� =0 OR   -- Property area = 0
	  �ت������`���n���褽�� =0 OR	-- Property area = 0
	  �Ƶ� LIKE '%��%' OR			-- Since the transaction between relatives usually comes with abnormal price, remove these data by looking at keyword in Remark coulmn
	  transaction_year is null OR   -- Incorrect date data
	  transaction_year > 2022 OR	-- Incorrect date data
	  transaction_month is null ;	-- Incorrect date data


-- 2.2 Drop Unused Columns 
ALTER TABLE taiwanrealestate2
DROP COLUMN �D�ت����n, �D�n�ا�, ����Ъ�, ������ɼ�, �ت��{�p�槽_�j��,���L�޲z��´, 
			����h��, ����s��, ���첾���`���n_���褽��, �����`����, �������O,
			�����g�a�ϥΤ���, ���ݫت����n, ���x���n, �q��, �D�����g�a�ϥΤ���, �D�����g�a�ϥνs�w ; 


-- 3. Unit of area, square meters --> Ping(Asian unit for house area)
SELECT 
	�ت������`���n���褽�� as squre_meters,
	�ت������`���n���褽�� * 0.3025 AS ping_total
FROM taiwanrealestate2 ;


-- *Update dataset
ALTER TABLE taiwanrealestate2
ADD ping_total FLOAT;

UPDATE dbo.taiwanrealestate2
SET ping_total = �ت������`���n���褽�� * 0.3025;


-- *Verify
SELECT �ت������`���n���褽�� AS squre_meters , ping_total
FROM dbo.taiwanrealestate2 ;


-- 4. Unit price. TWD per squre meters --> TWD per ping
SELECT
	��������褽�� as twd_squre_meters,
    ��������褽�� * 3.30579 as twd_per_ping
FROM dbo.taiwanrealestate2 ;


-- *Update dataset
ALTER TABLE taiwanrealestate2
ADD twd_per_ping FLOAT ;

UPDATE taiwanrealestate2
SET twd_per_ping = ��������褽�� * 3.30579 ;


-- *Verify
SELECT
	��������褽�� as twd_squre_meters,
    twd_per_ping
FROM taiwanrealestate2 ;


-- 5. House type 
-- 5.1 Extract string
SELECT  �ت����A, 
(CASE 
	WHEN PARSENAME(REPLACE(�ت����A, '(', '.') , 2) is null THEN SUBSTRING(�ت����A, 1, LEN(�ت����A))
	ELSE PARSENAME(REPLACE(�ت����A, '(', '.') , 2) 
 END) as house_type
FROM taiwanrealestate2 ;



-- *Update dataset
ALTER TABLE taiwanrealestate2
ADD house_type TEXT;

UPDATE taiwanrealestate2
SET house_type=
	(CASE 
		WHEN PARSENAME(REPLACE(�ت����A, '(', '.') , 2) is null THEN SUBSTRING(�ت����A, 1, LEN(�ت����A))
		ELSE PARSENAME(REPLACE(�ت����A, '(', '.') , 2) 
	 END) ;



-- *Verify
SELECT 	�ت����A,
		house_type
FROM taiwanrealestate2 ;


-- 5.2 create translation table for later join
CREATE TABLE house_type_translation(
	house_type_ch TEXT,
	house_type_en TEXT
	);

INSERT INTO house_type_translation(house_type_ch, house_type_en)
VALUES  ('��v�j��', 'Highrise_Condo'), ('�طH', 'Midrise_Condo'), ('���J', 'Lowrise_Condo'), 
		('�M��', 'Studio'), ('�줽�ӷ~�j��', 'Office'),('�t��', 'Factory'), 
		('����', 'Store'), ('�z�ѭ�', 'Townhouse'),('��L', 'Other');


-- 5.3 Join the translation table to the main dataset
SELECT m.house_type, t.house_type_en, *
FROM taiwanrealestate2 as m
INNER JOIN house_type_translation as t
ON (cast(m.house_type as varchar) = cast(t.house_type_ch as varchar));


-- 6. Real State Market Mertics
-- 6-1. District Monthly Average Realstate Price.
SELECT district AS district, transaction_year, transaction_month, avg_price_per_ping_10k
FROM (SELECT �m���� AS district, transaction_year, transaction_month,
		AVG(CAST(twd_per_ping AS float) /10000) AS avg_price_per_ping_10k
		FROM taiwanrealestate2
		WHERE transaction_year > 2017 and transaction_month is not null and �m���� is not null and twd_per_ping is not null
		group by �m����, transaction_year, transaction_month) AS ya
ORDER BY AVG(avg_price_per_ping_10k) over(partition by district) DESC, 1, 2, 3


-- 6-2. Monthly Transaction frequency. *Show district time change
SELECT district AS district, transaction_year, transaction_month, transaction_time
FROM (SELECT �m���� AS district, transaction_year, transaction_month,
		COUNT(twd_per_ping) AS transaction_time
		FROM taiwanrealestate2
		WHERE transaction_year > 2017 and transaction_month is not null and �m���� is not null and twd_per_ping is not null
		GROUP BY �m����, transaction_year, transaction_month) AS ya
ORDER BY AVG(transaction_time) OVER(partition by district) DESC, 1, 3, 2

-- 6-3.  City Monthly Average Realstate Price.
SELECT city, transaction_year, transaction_month, avg_price_per_ping_10k
FROM (SELECT city, transaction_year, transaction_month,
		AVG(CAST(twd_per_ping AS float) /10000) AS avg_price_per_ping_10k
		FROM taiwanrealestate2
		WHERE twd_per_ping is not null and transaction_year >= 2018
		group by city, transaction_year, transaction_month) AS ya
ORDER BY AVG(avg_price_per_ping_10k) over(partition by city) DESC, 1, 2, 3


-- 6-4.  Monthly Realestate Transaction Frequency. *Use CTE
WITH MonthlyFrequency (city, transaction_year, transaction_month, trans_frequency) as 
(
SELECT city, transaction_year, transaction_month,
		COUNT(CAST(twd_per_ping AS float) /10000) 
		FROM taiwanrealestate2
		WHERE twd_per_ping is not null and transaction_year >= 2018
		group by city, transaction_year, transaction_month
)
select *
from MonthlyFrequency
order by SUM(trans_frequency) OVER (PARTITION BY city) DESC, 2, 3

