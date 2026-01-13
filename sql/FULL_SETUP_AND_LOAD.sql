-- =====================================================
-- SCRIPT COMPLET - Phase 1
-- Setup + Création tables + Chargement données + Nettoyage
-- =====================================================

-- =====================================================
-- PARTIE 1 : SETUP ENVIRONNEMENT
-- =====================================================

CREATE DATABASE IF NOT EXISTS ANYCOMPANY_LAB;
USE DATABASE ANYCOMPANY_LAB;

CREATE SCHEMA IF NOT EXISTS BRONZE;
CREATE SCHEMA IF NOT EXISTS SILVER;

CREATE WAREHOUSE IF NOT EXISTS ANYCOMPANY_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = FALSE;

USE WAREHOUSE ANYCOMPANY_WH;

-- Stage S3
CREATE OR REPLACE STAGE BRONZE.S3_FOOD_BEVERAGE_STAGE
    URL = 's3://logbrain-datalake/datasets/food-beverage/';

-- Format CSV
CREATE OR REPLACE FILE FORMAT BRONZE.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    EMPTY_FIELD_AS_NULL = TRUE;

-- Format JSON
CREATE OR REPLACE FILE FORMAT BRONZE.JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE;

-- Vérifier les fichiers disponibles
LIST @BRONZE.S3_FOOD_BEVERAGE_STAGE;

-- =====================================================
-- PARTIE 2 : CRÉATION DES TABLES BRONZE
-- =====================================================

USE SCHEMA BRONZE;

CREATE OR REPLACE TABLE customer_demographics (
    customer_id INTEGER,
    name VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(50),
    region VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    marital_status VARCHAR(50),
    annual_income NUMBER(15, 2)
);

CREATE OR REPLACE TABLE customer_service_interactions (
    interaction_id VARCHAR(50),
    interaction_date DATE,
    interaction_type VARCHAR(50),
    issue_category VARCHAR(100),
    description TEXT,
    duration_minutes INTEGER,
    resolution_status VARCHAR(50),
    follow_up_required VARCHAR(10),
    customer_satisfaction INTEGER
);

CREATE OR REPLACE TABLE financial_transactions (
    transaction_id VARCHAR(50),
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount NUMBER(15, 2),
    payment_method VARCHAR(50),
    entity VARCHAR(255),
    region VARCHAR(100),
    account_code VARCHAR(50)
);

CREATE OR REPLACE TABLE promotions_data (
    promotion_id VARCHAR(50),
    product_category VARCHAR(100),
    promotion_type VARCHAR(100),
    discount_percentage NUMBER(5, 4),
    start_date DATE,
    end_date DATE,
    region VARCHAR(100)
);

CREATE OR REPLACE TABLE marketing_campaigns (
    campaign_id VARCHAR(50),
    campaign_name VARCHAR(255),
    campaign_type VARCHAR(100),
    product_category VARCHAR(100),
    target_audience VARCHAR(100),
    start_date DATE,
    end_date DATE,
    region VARCHAR(100),
    budget NUMBER(15, 2),
    reach INTEGER,
    conversion_rate NUMBER(6, 4)
);

CREATE OR REPLACE TABLE product_reviews (
    review_id INTEGER,
    product_id VARCHAR(50),
    reviewer_id VARCHAR(50),
    reviewer_name VARCHAR(255),
    rating INTEGER,
    review_date DATE,
    review_title VARCHAR(500),
    review_text TEXT,
    product_category VARCHAR(100)
);

CREATE OR REPLACE TABLE inventory (
    product_id VARCHAR(50),
    product_category VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    warehouse VARCHAR(255),
    current_stock INTEGER,
    reorder_point INTEGER,
    lead_time INTEGER,
    last_restock_date DATE
);

CREATE OR REPLACE TABLE store_locations (
    store_id VARCHAR(50),
    store_name VARCHAR(255),
    store_type VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    address VARCHAR(500),
    postal_code INTEGER,
    square_footage NUMBER(10, 2),
    employee_count INTEGER
);

CREATE OR REPLACE TABLE logistics_and_shipping (
    shipment_id VARCHAR(50),
    order_id VARCHAR(50),
    ship_date DATE,
    estimated_delivery DATE,
    shipping_method VARCHAR(50),
    status VARCHAR(50),
    shipping_cost NUMBER(10, 2),
    destination_region VARCHAR(100),
    destination_country VARCHAR(100),
    carrier VARCHAR(255)
);

CREATE OR REPLACE TABLE supplier_information (
    supplier_id VARCHAR(50),
    supplier_name VARCHAR(255),
    product_category VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    lead_time INTEGER,
    reliability_score NUMBER(4, 2),
    quality_rating VARCHAR(10)
);

CREATE OR REPLACE TABLE employee_records (
    employee_id VARCHAR(50),
    name VARCHAR(255),
    date_of_birth DATE,
    hire_date DATE,
    department VARCHAR(100),
    job_title VARCHAR(255),
    salary NUMBER(15, 2),
    region VARCHAR(100),
    country VARCHAR(100),
    email VARCHAR(255)
);

-- =====================================================
-- PARTIE 3 : CHARGEMENT DES DONNÉES CSV
-- =====================================================

-- 1. customer_demographics
COPY INTO customer_demographics
FROM @S3_FOOD_BEVERAGE_STAGE/customer_demographics.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'customer_demographics' AS table_name, COUNT(*) AS rows FROM customer_demographics;

-- 2. customer_service_interactions
COPY INTO customer_service_interactions
FROM @S3_FOOD_BEVERAGE_STAGE/customer_service_interactions.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'customer_service_interactions' AS table_name, COUNT(*) AS rows FROM customer_service_interactions;

-- 3. financial_transactions
COPY INTO financial_transactions
FROM @S3_FOOD_BEVERAGE_STAGE/financial_transactions.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'financial_transactions' AS table_name, COUNT(*) AS rows FROM financial_transactions;

-- 4. promotions_data
COPY INTO promotions_data
FROM @S3_FOOD_BEVERAGE_STAGE/promotions-data.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'promotions_data' AS table_name, COUNT(*) AS rows FROM promotions_data;

-- 5. marketing_campaigns
COPY INTO marketing_campaigns
FROM @S3_FOOD_BEVERAGE_STAGE/marketing_campaigns.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'marketing_campaigns' AS table_name, COUNT(*) AS rows FROM marketing_campaigns;

-- 6. product_reviews
COPY INTO product_reviews
FROM @S3_FOOD_BEVERAGE_STAGE/product_reviews.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'product_reviews' AS table_name, COUNT(*) AS rows FROM product_reviews;

-- 7. logistics_and_shipping
COPY INTO logistics_and_shipping
FROM @S3_FOOD_BEVERAGE_STAGE/logistics_and_shipping.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'logistics_and_shipping' AS table_name, COUNT(*) AS rows FROM logistics_and_shipping;

-- 8. supplier_information
COPY INTO supplier_information
FROM @S3_FOOD_BEVERAGE_STAGE/supplier_information.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'supplier_information' AS table_name, COUNT(*) AS rows FROM supplier_information;

-- 9. employee_records
COPY INTO employee_records
FROM @S3_FOOD_BEVERAGE_STAGE/employee_records.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

SELECT 'employee_records' AS table_name, COUNT(*) AS rows FROM employee_records;

-- =====================================================
-- PARTIE 4 : CHARGEMENT DES DONNÉES JSON
-- =====================================================

-- 10. inventory (JSON)
CREATE OR REPLACE TEMPORARY TABLE temp_inventory_json (json_data VARIANT);

COPY INTO temp_inventory_json
FROM @S3_FOOD_BEVERAGE_STAGE/inventory.json
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT')
ON_ERROR = 'CONTINUE';

INSERT INTO inventory
SELECT
    json_data:product_id::VARCHAR,
    json_data:product_category::VARCHAR,
    json_data:region::VARCHAR,
    json_data:country::VARCHAR,
    json_data:warehouse::VARCHAR,
    json_data:current_stock::INTEGER,
    json_data:reorder_point::INTEGER,
    json_data:lead_time::INTEGER,
    json_data:last_restock_date::DATE
FROM temp_inventory_json;

SELECT 'inventory' AS table_name, COUNT(*) AS rows FROM inventory;

-- 11. store_locations (JSON)
CREATE OR REPLACE TEMPORARY TABLE temp_store_locations_json (json_data VARIANT);

COPY INTO temp_store_locations_json
FROM @S3_FOOD_BEVERAGE_STAGE/store_locations.json
FILE_FORMAT = (FORMAT_NAME = 'JSON_FORMAT')
ON_ERROR = 'CONTINUE';

INSERT INTO store_locations
SELECT
    json_data:store_id::VARCHAR,
    json_data:store_name::VARCHAR,
    json_data:store_type::VARCHAR,
    json_data:region::VARCHAR,
    json_data:country::VARCHAR,
    json_data:city::VARCHAR,
    json_data:address::VARCHAR,
    json_data:postal_code::INTEGER,
    json_data:square_footage::NUMBER(10, 2),
    json_data:employee_count::INTEGER
FROM temp_store_locations_json;

SELECT 'store_locations' AS table_name, COUNT(*) AS rows FROM store_locations;

-- =====================================================
-- RAPPORT : TOUTES LES TABLES BRONZE
-- =====================================================

SELECT 'customer_demographics' AS table_name, COUNT(*) AS row_count FROM customer_demographics
UNION ALL SELECT 'customer_service_interactions', COUNT(*) FROM customer_service_interactions
UNION ALL SELECT 'financial_transactions', COUNT(*) FROM financial_transactions
UNION ALL SELECT 'promotions_data', COUNT(*) FROM promotions_data
UNION ALL SELECT 'marketing_campaigns', COUNT(*) FROM marketing_campaigns
UNION ALL SELECT 'product_reviews', COUNT(*) FROM product_reviews
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'store_locations', COUNT(*) FROM store_locations
UNION ALL SELECT 'logistics_and_shipping', COUNT(*) FROM logistics_and_shipping
UNION ALL SELECT 'supplier_information', COUNT(*) FROM supplier_information
UNION ALL SELECT 'employee_records', COUNT(*) FROM employee_records
ORDER BY table_name;

-- =====================================================
-- PARTIE 5 : CRÉATION DES TABLES SILVER (NETTOYÉES)
-- =====================================================

USE SCHEMA SILVER;

-- 1. customer_demographics_clean
CREATE OR REPLACE TABLE customer_demographics_clean AS
SELECT DISTINCT
    customer_id,
    TRIM(name) AS name,
    date_of_birth,
    UPPER(TRIM(gender)) AS gender,
    TRIM(region) AS region,
    TRIM(country) AS country,
    TRIM(city) AS city,
    TRIM(marital_status) AS marital_status,
    annual_income
FROM BRONZE.customer_demographics
WHERE customer_id IS NOT NULL
  AND name IS NOT NULL
  AND date_of_birth IS NOT NULL
  AND annual_income >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY name) = 1;

SELECT 'customer_demographics_clean' AS table_name, COUNT(*) AS rows FROM customer_demographics_clean;

-- 2. customer_service_interactions_clean
CREATE OR REPLACE TABLE customer_service_interactions_clean AS
SELECT DISTINCT
    interaction_id,
    interaction_date,
    TRIM(interaction_type) AS interaction_type,
    TRIM(issue_category) AS issue_category,
    TRIM(description) AS description,
    duration_minutes,
    TRIM(resolution_status) AS resolution_status,
    CASE 
        WHEN UPPER(TRIM(follow_up_required)) IN ('YES', 'Y', '1', 'TRUE') THEN 'Yes'
        WHEN UPPER(TRIM(follow_up_required)) IN ('NO', 'N', '0', 'FALSE') THEN 'No'
        ELSE follow_up_required
    END AS follow_up_required,
    customer_satisfaction
FROM BRONZE.customer_service_interactions
WHERE interaction_id IS NOT NULL
  AND interaction_date IS NOT NULL
  AND duration_minutes >= 0
  AND customer_satisfaction BETWEEN 1 AND 5
QUALIFY ROW_NUMBER() OVER (PARTITION BY interaction_id ORDER BY interaction_date DESC) = 1;

SELECT 'customer_service_interactions_clean' AS table_name, COUNT(*) AS rows FROM customer_service_interactions_clean;

-- 3. financial_transactions_clean
CREATE OR REPLACE TABLE financial_transactions_clean AS
SELECT DISTINCT
    transaction_id,
    transaction_date,
    TRIM(transaction_type) AS transaction_type,
    ABS(amount) AS amount,
    TRIM(payment_method) AS payment_method,
    TRIM(entity) AS entity,
    TRIM(region) AS region,
    TRIM(account_code) AS account_code
FROM BRONZE.financial_transactions
WHERE transaction_id IS NOT NULL
  AND transaction_date IS NOT NULL
  AND amount IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date DESC) = 1;

SELECT 'financial_transactions_clean' AS table_name, COUNT(*) AS rows FROM financial_transactions_clean;

-- 4. promotions_clean
CREATE OR REPLACE TABLE promotions_clean AS
SELECT DISTINCT
    promotion_id,
    TRIM(product_category) AS product_category,
    TRIM(promotion_type) AS promotion_type,
    discount_percentage,
    start_date,
    end_date,
    TRIM(region) AS region,
    DATEDIFF(day, start_date, end_date) AS promotion_duration_days
FROM BRONZE.promotions_data
WHERE promotion_id IS NOT NULL
  AND start_date IS NOT NULL
  AND end_date IS NOT NULL
  AND start_date <= end_date
  AND discount_percentage BETWEEN 0 AND 1
QUALIFY ROW_NUMBER() OVER (PARTITION BY promotion_id ORDER BY start_date DESC) = 1;

SELECT 'promotions_clean' AS table_name, COUNT(*) AS rows FROM promotions_clean;

-- 5. marketing_campaigns_clean
CREATE OR REPLACE TABLE marketing_campaigns_clean AS
SELECT DISTINCT
    campaign_id,
    TRIM(campaign_name) AS campaign_name,
    TRIM(campaign_type) AS campaign_type,
    TRIM(product_category) AS product_category,
    TRIM(target_audience) AS target_audience,
    start_date,
    end_date,
    TRIM(region) AS region,
    budget,
    reach,
    conversion_rate,
    DATEDIFF(day, start_date, end_date) AS campaign_duration_days,
    CASE 
        WHEN reach > 0 THEN budget / reach
        ELSE NULL
    END AS cost_per_reach
FROM BRONZE.marketing_campaigns
WHERE campaign_id IS NOT NULL
  AND start_date IS NOT NULL
  AND end_date IS NOT NULL
  AND start_date <= end_date
  AND budget >= 0
  AND reach >= 0
  AND conversion_rate BETWEEN 0 AND 1
QUALIFY ROW_NUMBER() OVER (PARTITION BY campaign_id ORDER BY start_date DESC) = 1;

SELECT 'marketing_campaigns_clean' AS table_name, COUNT(*) AS rows FROM marketing_campaigns_clean;

-- 6. product_reviews_clean
CREATE OR REPLACE TABLE product_reviews_clean AS
SELECT DISTINCT
    review_id,
    TRIM(product_id) AS product_id,
    TRIM(reviewer_id) AS reviewer_id,
    TRIM(reviewer_name) AS reviewer_name,
    rating,
    review_date,
    TRIM(review_title) AS review_title,
    TRIM(review_text) AS review_text,
    TRIM(product_category) AS product_category
FROM BRONZE.product_reviews
WHERE review_id IS NOT NULL
  AND product_id IS NOT NULL
  AND rating BETWEEN 1 AND 5
  AND review_date IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_date DESC) = 1;

SELECT 'product_reviews_clean' AS table_name, COUNT(*) AS rows FROM product_reviews_clean;

-- 7. inventory_clean
CREATE OR REPLACE TABLE inventory_clean AS
SELECT DISTINCT
    TRIM(product_id) AS product_id,
    TRIM(product_category) AS product_category,
    TRIM(region) AS region,
    TRIM(country) AS country,
    TRIM(warehouse) AS warehouse,
    current_stock,
    reorder_point,
    lead_time,
    last_restock_date,
    CASE 
        WHEN current_stock <= reorder_point THEN 'Low Stock'
        WHEN current_stock <= reorder_point * 1.5 THEN 'Medium Stock'
        ELSE 'High Stock'
    END AS stock_status
FROM BRONZE.inventory
WHERE product_id IS NOT NULL
  AND current_stock >= 0
  AND reorder_point >= 0
  AND lead_time >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY product_id, warehouse ORDER BY last_restock_date DESC) = 1;

SELECT 'inventory_clean' AS table_name, COUNT(*) AS rows FROM inventory_clean;

-- 8. store_locations_clean
CREATE OR REPLACE TABLE store_locations_clean AS
SELECT DISTINCT
    store_id,
    TRIM(store_name) AS store_name,
    TRIM(store_type) AS store_type,
    TRIM(region) AS region,
    TRIM(country) AS country,
    TRIM(city) AS city,
    TRIM(address) AS address,
    postal_code,
    square_footage,
    employee_count
FROM BRONZE.store_locations
WHERE store_id IS NOT NULL
  AND store_name IS NOT NULL
  AND square_footage > 0
  AND employee_count >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY store_name) = 1;

SELECT 'store_locations_clean' AS table_name, COUNT(*) AS rows FROM store_locations_clean;

-- 9. logistics_and_shipping_clean
CREATE OR REPLACE TABLE logistics_and_shipping_clean AS
SELECT DISTINCT
    shipment_id,
    order_id,
    ship_date,
    estimated_delivery,
    TRIM(shipping_method) AS shipping_method,
    TRIM(status) AS status,
    shipping_cost,
    TRIM(destination_region) AS destination_region,
    TRIM(destination_country) AS destination_country,
    TRIM(carrier) AS carrier,
    DATEDIFF(day, ship_date, estimated_delivery) AS estimated_delivery_days
FROM BRONZE.logistics_and_shipping
WHERE shipment_id IS NOT NULL
  AND order_id IS NOT NULL
  AND ship_date IS NOT NULL
  AND shipping_cost >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY shipment_id ORDER BY ship_date DESC) = 1;

SELECT 'logistics_and_shipping_clean' AS table_name, COUNT(*) AS rows FROM logistics_and_shipping_clean;

-- 10. supplier_information_clean
CREATE OR REPLACE TABLE supplier_information_clean AS
SELECT DISTINCT
    supplier_id,
    TRIM(supplier_name) AS supplier_name,
    TRIM(product_category) AS product_category,
    TRIM(region) AS region,
    TRIM(country) AS country,
    TRIM(city) AS city,
    lead_time,
    reliability_score,
    TRIM(quality_rating) AS quality_rating
FROM BRONZE.supplier_information
WHERE supplier_id IS NOT NULL
  AND supplier_name IS NOT NULL
  AND lead_time >= 0
  AND reliability_score BETWEEN 0 AND 1
QUALIFY ROW_NUMBER() OVER (PARTITION BY supplier_id ORDER BY supplier_name) = 1;

SELECT 'supplier_information_clean' AS table_name, COUNT(*) AS rows FROM supplier_information_clean;

-- 11. employee_records_clean
CREATE OR REPLACE TABLE employee_records_clean AS
SELECT DISTINCT
    employee_id,
    TRIM(name) AS name,
    date_of_birth,
    hire_date,
    TRIM(department) AS department,
    TRIM(job_title) AS job_title,
    salary,
    TRIM(region) AS region,
    TRIM(country) AS country,
    LOWER(TRIM(email)) AS email,
    DATEDIFF(year, hire_date, CURRENT_DATE()) AS years_of_service,
    DATEDIFF(year, date_of_birth, CURRENT_DATE()) AS age
FROM BRONZE.employee_records
WHERE employee_id IS NOT NULL
  AND name IS NOT NULL
  AND hire_date IS NOT NULL
  AND salary >= 0
QUALIFY ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY hire_date DESC) = 1;

SELECT 'employee_records_clean' AS table_name, COUNT(*) AS rows FROM employee_records_clean;

-- =====================================================
-- RAPPORT FINAL : TOUTES LES TABLES SILVER
-- =====================================================

SELECT 'customer_demographics_clean' AS table_name, COUNT(*) AS row_count FROM customer_demographics_clean
UNION ALL SELECT 'customer_service_interactions_clean', COUNT(*) FROM customer_service_interactions_clean
UNION ALL SELECT 'financial_transactions_clean', COUNT(*) FROM financial_transactions_clean
UNION ALL SELECT 'promotions_clean', COUNT(*) FROM promotions_clean
UNION ALL SELECT 'marketing_campaigns_clean', COUNT(*) FROM marketing_campaigns_clean
UNION ALL SELECT 'product_reviews_clean', COUNT(*) FROM product_reviews_clean
UNION ALL SELECT 'inventory_clean', COUNT(*) FROM inventory_clean
UNION ALL SELECT 'store_locations_clean', COUNT(*) FROM store_locations_clean
UNION ALL SELECT 'logistics_and_shipping_clean', COUNT(*) FROM logistics_and_shipping_clean
UNION ALL SELECT 'supplier_information_clean', COUNT(*) FROM supplier_information_clean
UNION ALL SELECT 'employee_records_clean', COUNT(*) FROM employee_records_clean
ORDER BY table_name;

-- =====================================================
-- ✅ PHASE 1 TERMINÉE !
-- Toutes les tables BRONZE et SILVER sont créées et remplies
-- =====================================================

-- Vérification finale
SHOW TABLES IN SCHEMA BRONZE;
SHOW TABLES IN SCHEMA SILVER;

-- Test rapide
SELECT region, COUNT(*) AS customer_count 
FROM SILVER.customer_demographics_clean 
GROUP BY region 
ORDER BY customer_count DESC 
LIMIT 5;
