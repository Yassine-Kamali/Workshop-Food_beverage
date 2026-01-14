-- =====================================================
-- Phase 1 - Data Preparation & Ingestion
-- Étape 2 : Création des tables dans le schéma BRONZE
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- 1. Table : customer_demographics
-- Données démographiques des clients
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.customer_demographics (
    customer_id INTEGER,
    name VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(50),
    region VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    marital_status VARCHAR(50),
    annual_income NUMBER(15, 2)
)
COMMENT = 'Données démographiques des clients - Données brutes';

-- =====================================================
-- 2. Table : customer_service_interactions
-- Interactions avec le service client
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.customer_service_interactions (
    interaction_id VARCHAR(50),
    interaction_date DATE,
    interaction_type VARCHAR(50),
    issue_category VARCHAR(100),
    description TEXT,
    duration_minutes INTEGER,
    resolution_status VARCHAR(50),
    follow_up_required VARCHAR(10),
    customer_satisfaction INTEGER
)
COMMENT = 'Interactions clients avec le service client - Données brutes';

-- =====================================================
-- 3. Table : financial_transactions
-- Transactions financières de vente
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.financial_transactions (
    transaction_id VARCHAR(50),
    transaction_date DATE,
    transaction_type VARCHAR(50),
    amount NUMBER(15, 2),
    payment_method VARCHAR(50),
    entity VARCHAR(255),
    region VARCHAR(100),
    account_code VARCHAR(50)
)
COMMENT = 'Transactions financières - Données brutes';

-- =====================================================
-- 4. Table : promotions_data
-- Données des promotions commerciales
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.promotions_data (
    promotion_id VARCHAR(50),
    product_category VARCHAR(100),
    promotion_type VARCHAR(100),
    discount_percentage NUMBER(5, 4),
    start_date DATE,
    end_date DATE,
    region VARCHAR(100)
)
COMMENT = 'Données des promotions - Données brutes';

-- =====================================================
-- 5. Table : marketing_campaigns
-- Campagnes marketing
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.marketing_campaigns (
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
)
COMMENT = 'Campagnes marketing - Données brutes';

-- =====================================================
-- 6. Table : product_reviews
-- Avis et notes sur les produits
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.product_reviews (
    review_id INTEGER,
    product_id VARCHAR(50),
    reviewer_id VARCHAR(50),
    reviewer_name VARCHAR(255),
    helpful_votes INTEGER,
    total_votes INTEGER,
    rating INTEGER,
    review_date TIMESTAMP,
    review_title VARCHAR(500),
    review_text TEXT,
    product_category VARCHAR(100),
    product_subcategory VARCHAR(100),
    product_description TEXT
)
COMMENT = 'Avis produits clients - Données brutes';

-- =====================================================
-- 7. Table : inventory
-- Niveaux de stock (source JSON)
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.inventory (
    product_id VARCHAR(50),
    product_category VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    warehouse VARCHAR(255),
    current_stock INTEGER,
    reorder_point INTEGER,
    lead_time INTEGER,
    last_restock_date DATE
)
COMMENT = 'Niveaux de stock par entrepôt - Données brutes (source JSON)';

-- =====================================================
-- 8. Table : store_locations
-- Informations géographiques des magasins (source JSON)
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.store_locations (
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
)
COMMENT = 'Informations géographiques des magasins - Données brutes (source JSON)';

-- =====================================================
-- 9. Table : logistics_and_shipping
-- Données logistiques et d'expédition
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.logistics_and_shipping (
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
)
COMMENT = 'Données logistiques et d''expédition - Données brutes';

-- =====================================================
-- 10. Table : supplier_information
-- Informations sur les fournisseurs
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.supplier_information (
    supplier_id VARCHAR(50),
    supplier_name VARCHAR(255),
    product_category VARCHAR(100),
    region VARCHAR(100),
    country VARCHAR(100),
    city VARCHAR(100),
    lead_time INTEGER,
    reliability_score NUMBER(4, 2),
    quality_rating VARCHAR(10)
)
COMMENT = 'Informations sur les fournisseurs - Données brutes';

-- =====================================================
-- 11. Table : employee_records
-- Données organisationnelles des employés
-- =====================================================

CREATE OR REPLACE TABLE BRONZE.employee_records (
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
)
COMMENT = 'Données des employés - Données brutes';

-- =====================================================
-- Vérification des tables créées
-- =====================================================

SHOW TABLES IN SCHEMA BRONZE;

-- Afficher le nombre de tables créées
SELECT COUNT(*) AS nombre_tables_bronze
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'BRONZE';

-- =====================================================
-- Toutes les tables BRONZE ont été créées avec succès !
-- =====================================================
