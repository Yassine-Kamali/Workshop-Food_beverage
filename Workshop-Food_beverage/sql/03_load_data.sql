-- =====================================================
-- Phase 1 - Data Preparation & Ingestion
-- Étape 3 : Chargement des données (COPY INTO)
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- SECTION 1 : CHARGEMENT DES FICHIERS CSV
-- =====================================================

-- =====================================================
-- 1. Chargement : customer_demographics.csv
-- =====================================================

COPY INTO BRONZE.customer_demographics
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/customer_demographics.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.customer_demographics;
SELECT * FROM BRONZE.customer_demographics LIMIT 10;

-- =====================================================
-- 2. Chargement : customer_service_interactions.csv
-- =====================================================

COPY INTO BRONZE.customer_service_interactions
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/customer_service_interactions.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.customer_service_interactions;
SELECT * FROM BRONZE.customer_service_interactions LIMIT 10;

-- =====================================================
-- 3. Chargement : financial_transactions.csv
-- =====================================================

COPY INTO BRONZE.financial_transactions
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/financial_transactions.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.financial_transactions;
SELECT * FROM BRONZE.financial_transactions LIMIT 10;

-- =====================================================
-- 4. Chargement : promotions-data.csv
-- =====================================================

COPY INTO BRONZE.promotions_data
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/promotions-data.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.promotions_data;
SELECT * FROM BRONZE.promotions_data LIMIT 10;

-- =====================================================
-- 5. Chargement : marketing_campaigns.csv
-- =====================================================

COPY INTO BRONZE.marketing_campaigns
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/marketing_campaigns.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.marketing_campaigns;
SELECT * FROM BRONZE.marketing_campaigns LIMIT 10;

-- =====================================================
-- 6. Chargement : product_reviews.csv
-- =====================================================
-- Note : Ce fichier utilise des TAB comme délimiteurs (TSV format)

COPY INTO BRONZE.product_reviews
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/product_reviews.csv
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = '\t'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = 'NONE'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    EMPTY_FIELD_AS_NULL = TRUE
    ENCODING = 'UTF8'
)
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.product_reviews;
SELECT * FROM BRONZE.product_reviews LIMIT 10;

-- =====================================================
-- 7. Chargement : logistics_and_shipping.csv
-- =====================================================

COPY INTO BRONZE.logistics_and_shipping
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/logistics_and_shipping.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.logistics_and_shipping;
SELECT * FROM BRONZE.logistics_and_shipping LIMIT 10;

-- =====================================================
-- 8. Chargement : supplier_information.csv
-- =====================================================

COPY INTO BRONZE.supplier_information
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/supplier_information.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.supplier_information;
SELECT * FROM BRONZE.supplier_information LIMIT 10;

-- =====================================================
-- 9. Chargement : employee_records.csv
-- =====================================================

COPY INTO BRONZE.employee_records
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/employee_records.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.employee_records;
SELECT * FROM BRONZE.employee_records LIMIT 10;

-- =====================================================
-- SECTION 2 : CHARGEMENT DES FICHIERS JSON
-- =====================================================

-- =====================================================
-- 10. Chargement : inventory.json
-- =====================================================

-- Étape 1 : Créer une table temporaire pour recevoir le JSON brut
CREATE OR REPLACE TEMPORARY TABLE temp_inventory_json (
    json_data VARIANT
);

-- Étape 2 : Charger le fichier JSON dans la table temporaire
COPY INTO temp_inventory_json
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/inventory.json
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.JSON_FORMAT')
ON_ERROR = 'CONTINUE';

-- Étape 3 : Parser le JSON et insérer dans la table finale
INSERT INTO BRONZE.inventory (
    product_id,
    product_category,
    region,
    country,
    warehouse,
    current_stock,
    reorder_point,
    lead_time,
    last_restock_date
)
SELECT
    json_data:product_id::VARCHAR AS product_id,
    json_data:product_category::VARCHAR AS product_category,
    json_data:region::VARCHAR AS region,
    json_data:country::VARCHAR AS country,
    json_data:warehouse::VARCHAR AS warehouse,
    json_data:current_stock::INTEGER AS current_stock,
    json_data:reorder_point::INTEGER AS reorder_point,
    json_data:lead_time::INTEGER AS lead_time,
    json_data:last_restock_date::DATE AS last_restock_date
FROM temp_inventory_json;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.inventory;
SELECT * FROM BRONZE.inventory LIMIT 10;

-- =====================================================
-- 11. Chargement : store_locations.json
-- =====================================================

-- Étape 1 : Créer une table temporaire pour recevoir le JSON brut
CREATE OR REPLACE TEMPORARY TABLE temp_store_locations_json (
    json_data VARIANT
);

-- Étape 2 : Charger le fichier JSON dans la table temporaire
COPY INTO temp_store_locations_json
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/store_locations.json
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.JSON_FORMAT')
ON_ERROR = 'CONTINUE';

-- Étape 3 : Parser le JSON et insérer dans la table finale
INSERT INTO BRONZE.store_locations (
    store_id,
    store_name,
    store_type,
    region,
    country,
    city,
    address,
    postal_code,
    square_footage,
    employee_count
)
SELECT
    json_data:store_id::VARCHAR AS store_id,
    json_data:store_name::VARCHAR AS store_name,
    json_data:store_type::VARCHAR AS store_type,
    json_data:region::VARCHAR AS region,
    json_data:country::VARCHAR AS country,
    json_data:city::VARCHAR AS city,
    json_data:address::VARCHAR AS address,
    json_data:postal_code::INTEGER AS postal_code,
    json_data:square_footage::NUMBER(10, 2) AS square_footage,
    json_data:employee_count::INTEGER AS employee_count
FROM temp_store_locations_json;

-- Vérification du chargement
SELECT COUNT(*) AS total_rows FROM BRONZE.store_locations;
SELECT * FROM BRONZE.store_locations LIMIT 10;

-- =====================================================
-- SECTION 3 : RAPPORT DE CHARGEMENT GLOBAL
-- =====================================================

-- Rapport : Nombre de lignes par table
SELECT 
    'customer_demographics' AS table_name,
    COUNT(*) AS row_count
FROM BRONZE.customer_demographics
UNION ALL
SELECT 
    'customer_service_interactions',
    COUNT(*)
FROM BRONZE.customer_service_interactions
UNION ALL
SELECT 
    'financial_transactions',
    COUNT(*)
FROM BRONZE.financial_transactions
UNION ALL
SELECT 
    'promotions_data',
    COUNT(*)
FROM BRONZE.promotions_data
UNION ALL
SELECT 
    'marketing_campaigns',
    COUNT(*)
FROM BRONZE.marketing_campaigns
UNION ALL
SELECT 
    'product_reviews',
    COUNT(*)
FROM BRONZE.product_reviews
UNION ALL
SELECT 
    'inventory',
    COUNT(*)
FROM BRONZE.inventory
UNION ALL
SELECT 
    'store_locations',
    COUNT(*)
FROM BRONZE.store_locations
UNION ALL
SELECT 
    'logistics_and_shipping',
    COUNT(*)
FROM BRONZE.logistics_and_shipping
UNION ALL
SELECT 
    'supplier_information',
    COUNT(*)
FROM BRONZE.supplier_information
UNION ALL
SELECT 
    'employee_records',
    COUNT(*)
FROM BRONZE.employee_records
ORDER BY table_name;

-- =====================================================
-- Chargement des données terminé avec succès !
-- =====================================================
