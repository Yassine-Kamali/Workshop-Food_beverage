-- =====================================================
-- Phase 1 - Data Preparation & Ingestion
-- Étape 5 : Nettoyage des données et création des tables SILVER
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- PRINCIPES DE NETTOYAGE APPLIQUÉS :
-- 1. Suppression des doublons
-- 2. Gestion des valeurs NULL
-- 3. Standardisation des formats (dates, textes)
-- 4. Validation des valeurs (montants positifs, etc.)
-- 5. Harmonisation des données
-- =====================================================

-- =====================================================
-- 1. Table SILVER : customer_demographics_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.customer_demographics_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.customer_demographics_clean;
SELECT * FROM SILVER.customer_demographics_clean LIMIT 10;

-- =====================================================
-- 2. Table SILVER : customer_service_interactions_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.customer_service_interactions_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.customer_service_interactions_clean;
SELECT * FROM SILVER.customer_service_interactions_clean LIMIT 10;

-- =====================================================
-- 3. Table SILVER : financial_transactions_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.financial_transactions_clean AS
SELECT DISTINCT
    transaction_id,
    transaction_date,
    TRIM(transaction_type) AS transaction_type,
    ABS(amount) AS amount,  -- S'assurer que les montants sont positifs
    TRIM(payment_method) AS payment_method,
    TRIM(entity) AS entity,
    TRIM(region) AS region,
    TRIM(account_code) AS account_code
FROM BRONZE.financial_transactions
WHERE transaction_id IS NOT NULL
  AND transaction_date IS NOT NULL
  AND amount IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_date DESC) = 1;

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.financial_transactions_clean;
SELECT * FROM SILVER.financial_transactions_clean LIMIT 10;

-- =====================================================
-- 4. Table SILVER : promotions_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.promotions_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.promotions_clean;
SELECT * FROM SILVER.promotions_clean LIMIT 10;

-- =====================================================
-- 5. Table SILVER : marketing_campaigns_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.marketing_campaigns_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.marketing_campaigns_clean;
SELECT * FROM SILVER.marketing_campaigns_clean LIMIT 10;

-- =====================================================
-- 6. Table SILVER : product_reviews_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.product_reviews_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.product_reviews_clean;
SELECT * FROM SILVER.product_reviews_clean LIMIT 10;

-- =====================================================
-- 7. Table SILVER : inventory_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.inventory_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.inventory_clean;
SELECT * FROM SILVER.inventory_clean LIMIT 10;

-- =====================================================
-- 8. Table SILVER : store_locations_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.store_locations_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.store_locations_clean;
SELECT * FROM SILVER.store_locations_clean LIMIT 10;

-- =====================================================
-- 9. Table SILVER : logistics_and_shipping_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.logistics_and_shipping_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.logistics_and_shipping_clean;
SELECT * FROM SILVER.logistics_and_shipping_clean LIMIT 10;

-- =====================================================
-- 10. Table SILVER : supplier_information_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.supplier_information_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.supplier_information_clean;
SELECT * FROM SILVER.supplier_information_clean LIMIT 10;

-- =====================================================
-- 11. Table SILVER : employee_records_clean
-- =====================================================

CREATE OR REPLACE TABLE SILVER.employee_records_clean AS
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

-- Vérifications
SELECT COUNT(*) AS total_rows FROM SILVER.employee_records_clean;
SELECT * FROM SILVER.employee_records_clean LIMIT 10;

-- =====================================================
-- SECTION : RAPPORT DE QUALITÉ DES DONNÉES
-- =====================================================

-- Comparaison BRONZE vs SILVER : Nombre de lignes
SELECT 
    'customer_demographics' AS table_name,
    (SELECT COUNT(*) FROM BRONZE.customer_demographics) AS bronze_count,
    (SELECT COUNT(*) FROM SILVER.customer_demographics_clean) AS silver_count,
    (SELECT COUNT(*) FROM BRONZE.customer_demographics) - (SELECT COUNT(*) FROM SILVER.customer_demographics_clean) AS rows_removed
UNION ALL
SELECT 
    'customer_service_interactions',
    (SELECT COUNT(*) FROM BRONZE.customer_service_interactions),
    (SELECT COUNT(*) FROM SILVER.customer_service_interactions_clean),
    (SELECT COUNT(*) FROM BRONZE.customer_service_interactions) - (SELECT COUNT(*) FROM SILVER.customer_service_interactions_clean)
UNION ALL
SELECT 
    'financial_transactions',
    (SELECT COUNT(*) FROM BRONZE.financial_transactions),
    (SELECT COUNT(*) FROM SILVER.financial_transactions_clean),
    (SELECT COUNT(*) FROM BRONZE.financial_transactions) - (SELECT COUNT(*) FROM SILVER.financial_transactions_clean)
UNION ALL
SELECT 
    'promotions_data',
    (SELECT COUNT(*) FROM BRONZE.promotions_data),
    (SELECT COUNT(*) FROM SILVER.promotions_clean),
    (SELECT COUNT(*) FROM BRONZE.promotions_data) - (SELECT COUNT(*) FROM SILVER.promotions_clean)
UNION ALL
SELECT 
    'marketing_campaigns',
    (SELECT COUNT(*) FROM BRONZE.marketing_campaigns),
    (SELECT COUNT(*) FROM SILVER.marketing_campaigns_clean),
    (SELECT COUNT(*) FROM BRONZE.marketing_campaigns) - (SELECT COUNT(*) FROM SILVER.marketing_campaigns_clean)
UNION ALL
SELECT 
    'product_reviews',
    (SELECT COUNT(*) FROM BRONZE.product_reviews),
    (SELECT COUNT(*) FROM SILVER.product_reviews_clean),
    (SELECT COUNT(*) FROM BRONZE.product_reviews) - (SELECT COUNT(*) FROM SILVER.product_reviews_clean)
UNION ALL
SELECT 
    'inventory',
    (SELECT COUNT(*) FROM BRONZE.inventory),
    (SELECT COUNT(*) FROM SILVER.inventory_clean),
    (SELECT COUNT(*) FROM BRONZE.inventory) - (SELECT COUNT(*) FROM SILVER.inventory_clean)
UNION ALL
SELECT 
    'store_locations',
    (SELECT COUNT(*) FROM BRONZE.store_locations),
    (SELECT COUNT(*) FROM SILVER.store_locations_clean),
    (SELECT COUNT(*) FROM BRONZE.store_locations) - (SELECT COUNT(*) FROM SILVER.store_locations_clean)
UNION ALL
SELECT 
    'logistics_and_shipping',
    (SELECT COUNT(*) FROM BRONZE.logistics_and_shipping),
    (SELECT COUNT(*) FROM SILVER.logistics_and_shipping_clean),
    (SELECT COUNT(*) FROM BRONZE.logistics_and_shipping) - (SELECT COUNT(*) FROM SILVER.logistics_and_shipping_clean)
UNION ALL
SELECT 
    'supplier_information',
    (SELECT COUNT(*) FROM BRONZE.supplier_information),
    (SELECT COUNT(*) FROM SILVER.supplier_information_clean),
    (SELECT COUNT(*) FROM BRONZE.supplier_information) - (SELECT COUNT(*) FROM SILVER.supplier_information_clean)
UNION ALL
SELECT 
    'employee_records',
    (SELECT COUNT(*) FROM BRONZE.employee_records),
    (SELECT COUNT(*) FROM SILVER.employee_records_clean),
    (SELECT COUNT(*) FROM BRONZE.employee_records) - (SELECT COUNT(*) FROM SILVER.employee_records_clean)
ORDER BY table_name;

-- Afficher toutes les tables SILVER créées
SHOW TABLES IN SCHEMA SILVER;

-- =====================================================
-- Nettoyage des données terminé avec succès !
-- Les tables SILVER sont prêtes pour l'analyse (Phase 2)
-- =====================================================
