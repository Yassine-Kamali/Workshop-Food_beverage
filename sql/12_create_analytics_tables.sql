-- =====================================================
-- Phase 3 - Data Product & Machine Learning
-- Étape 12 : Création des tables analytiques (Data Product)
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- TABLE 1 : enriched_sales
-- Table des ventes enrichies avec informations promotionnelles
-- Granularité : transaction
-- Clés de jointure : transaction_id, region, transaction_date
-- =====================================================

CREATE OR REPLACE TABLE ANALYTICS.enriched_sales AS
SELECT
    t.TRANSACTION_ID,
    t.TRANSACTION_DATE,
    t.TRANSACTION_TYPE,
    t.AMOUNT,
    t.PAYMENT_METHOD,
    t.ENTITY,
    t.REGION,
    t.ACCOUNT_CODE,
-- Dimensions temporelles
    DATE_TRUNC('MONTH', t.TRANSACTION_DATE) AS sales_month,
    DATE_TRUNC('QUARTER', t.TRANSACTION_DATE) AS sales_quarter,
    DATE_TRUNC('YEAR', t.TRANSACTION_DATE) AS sales_year,
    DAYOFWEEK(t.TRANSACTION_DATE) AS day_of_week,
    MONTH(t.TRANSACTION_DATE) AS month_number,
    
  -- Informations promotionnelles (jointure sur région et période)
    CASE
        WHEN p.PROMOTION_ID IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS has_active_promotion,

    p.PROMOTION_ID,
    p.PRODUCT_CATEGORY AS promotion_category,
    p.PROMOTION_TYPE,
    p.DISCOUNT_PERCENTAGE,
    p.PROMOTION_DURATION_DAYS,
    
  -- Indicateurs calculés
    CASE
        WHEN t.AMOUNT > 100 THEN 'Valeur Élevée'
        WHEN t.AMOUNT > 50 THEN 'Valeur Moyenne'
        ELSE 'Valeur Faible'
    END AS transaction_value_segment

FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN t
LEFT JOIN SILVER.PROMOTIONS_CLEAN p
    ON t.REGION = p.REGION
    AND t.TRANSACTION_DATE BETWEEN p.START_DATE AND p.END_DATE
WHERE t.TRANSACTION_TYPE = 'Sale';

-- Commentaires et documentation
COMMENT ON TABLE ANALYTICS.enriched_sales IS 'Table analytique des ventes enrichies avec données promotionnelles. Granularité: transaction. Clés: transaction_id, region, transaction_date';
COMMENT ON COLUMN ANALYTICS.enriched_sales.transaction_id IS 'Identifiant unique de la transaction';
COMMENT ON COLUMN ANALYTICS.enriched_sales.has_active_promotion IS 'Indique si une promotion était active lors de la transaction';
COMMENT ON COLUMN ANALYTICS.enriched_sales.transaction_value_segment IS 'Segmentation par valeur de transaction';

-- Vérifications
SELECT COUNT(*) AS total_enriched_sales FROM ANALYTICS.enriched_sales;
SELECT * FROM ANALYTICS.enriched_sales LIMIT 10;


-- =====================================================
-- TABLE 2 : active_promotions
-- Table des promotions actives avec métriques de performance
-- Granularité : promotion
-- Clés de jointure : promotion_id, region, product_category
-- =====================================================

CREATE OR REPLACE TABLE ANALYTICS.active_promotions AS
SELECT
    p.promotion_id,
    p.product_category,
    p.promotion_type,
    p.discount_percentage,
    p.start_date,
    p.end_date,
    p.region,
    p.promotion_duration_days,

    -- Métriques de performance calculées
    COUNT(t.transaction_id) AS total_transactions_during_promo,
    SUM(t.amount) AS total_revenue_during_promo,
    ROUND(AVG(t.amount), 2) AS avg_transaction_value_during_promo,

    -- Comparaison avec période précédente (simplifiée)
    LAG(SUM(t.amount)) OVER (PARTITION BY p.product_category, p.region ORDER BY p.start_date) AS prev_period_revenue,

    -- Indicateur de succès
    CASE
        WHEN SUM(t.amount) > LAG(SUM(t.amount)) OVER (PARTITION BY p.product_category, p.region ORDER BY p.start_date) THEN 'Réussi'
        WHEN SUM(t.amount) IS NULL THEN 'Aucune Donnée'
        ELSE 'Sous-performance'
    END AS performance_indicator

FROM SILVER.promotions_clean p
LEFT JOIN SILVER.financial_transactions_clean t
    ON p.region = t.region
    AND t.transaction_date BETWEEN p.start_date AND p.end_date
    AND t.transaction_type = 'Sale'
GROUP BY
    p.promotion_id,
    p.product_category,
    p.promotion_type,
    p.discount_percentage,
    p.start_date,
    p.end_date,
    p.region,
    p.promotion_duration_days;

-- Commentaires et documentation
COMMENT ON TABLE ANALYTICS.active_promotions IS 'Table analytique des promotions avec métriques de performance. Granularité: promotion. Clés: promotion_id, region, product_category';
COMMENT ON COLUMN ANALYTICS.active_promotions.total_transactions_during_promo IS 'Nombre total de transactions pendant la promotion';
COMMENT ON COLUMN ANALYTICS.active_promotions.performance_indicator IS 'Indicateur de performance vs période précédente';

-- Vérifications
SELECT COUNT(*) AS total_active_promotions FROM ANALYTICS.active_promotions;
SELECT * FROM ANALYTICS.active_promotions LIMIT 10;

-- =====================================================
-- TABLE 3 : enriched_customers
-- Table des clients enrichis avec données démographiques et comportementales
-- Granularité : client
-- Clés de jointure : customer_id, region, country
-- =====================================================

CREATE OR REPLACE TABLE ANALYTICS.enriched_customers AS
SELECT
    c.customer_id,
    c.name,
    c.date_of_birth,
    c.gender,
    c.region,
    c.country,
    c.city,
    c.marital_status,
    c.annual_income,

    -- Âge calculé
    DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) AS age,

    -- Segmentation par âge
    CASE
        WHEN DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) < 25 THEN '18-24'
        WHEN DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) < 35 THEN '25-34'
        WHEN DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) < 45 THEN '35-44'
        WHEN DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) < 55 THEN '45-54'
        WHEN DATEDIFF(year, c.date_of_birth, CURRENT_DATE()) < 65 THEN '55-64'
        ELSE '65+'
    END AS age_group,

    -- Segmentation par revenu
    CASE
        WHEN c.annual_income < 30000 THEN 'Faible Revenu'
        WHEN c.annual_income < 60000 THEN 'Revenu Moyen'
        WHEN c.annual_income < 100000 THEN 'Haut Revenu'
        ELSE 'Très Haut Revenu'
    END AS income_segment

FROM SILVER.customer_demographics_clean c;

-- Commentaires et documentation
COMMENT ON TABLE ANALYTICS.enriched_customers IS 'Table analytique des clients enrichis avec segmentation et métriques comportementales. Granularité: client. Clés: customer_id, region, country';
COMMENT ON COLUMN ANALYTICS.enriched_customers.age_group IS 'Groupe d âge du client';
COMMENT ON COLUMN ANALYTICS.enriched_customers.engagement_level IS 'Niveau d engagement basé sur les interactions service';

-- Vérifications
SELECT COUNT(*) AS total_enriched_customers FROM ANALYTICS.enriched_customers;
SELECT * FROM ANALYTICS.enriched_customers LIMIT 10;

-- =====================================================
-- VÉRIFICATIONS FINALES
-- =====================================================

-- Afficher toutes les tables ANALYTICS créées
SHOW TABLES IN SCHEMA ANALYTICS;

-- Statistiques des tables
SELECT
    'enriched_sales' AS table_name,
    COUNT(*) AS row_count
FROM ANALYTICS.enriched_sales
UNION ALL
SELECT
    'active_promotions',
    COUNT(*)
FROM ANALYTICS.active_promotions
UNION ALL
SELECT
    'enriched_customers',
    COUNT(*)
FROM ANALYTICS.enriched_customers;

-- =====================================================
-- Data Product créé avec succès !
-- Prêt pour les analyses avancées et les modèles ML
-- =====================================================