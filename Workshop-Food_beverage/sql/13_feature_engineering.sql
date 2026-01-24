-- =====================================================
-- Phase 3 - Data Product & Machine Learning
-- Étape 13 : Feature Engineering pour ML (OPTIONNEL)
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA ANALYTICS;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- TABLE : ml_features
-- Features préparées pour les modèles ML
-- =====================================================

CREATE OR REPLACE TABLE ANALYTICS.ml_features AS
WITH base AS (
    SELECT
     -- Features temporelles
        es.transaction_date,
        es.region,
        es.amount,
        es.has_active_promotion,
        es.discount_percentage,
        es.promotion_duration_days,

        DATE_TRUNC('MONTH', es.transaction_date) AS feature_month,
        MONTH(es.transaction_date) AS month,
        DAYOFWEEK(es.transaction_date) AS day_of_week,

        CASE
            WHEN DAYOFWEEK(es.transaction_date) IN (1,7) THEN 1 ELSE 0
        END AS is_weekend,
-- Features géographiques
        CASE
            WHEN es.region IN ('North', 'South') THEN 'Région_Primaire'
            ELSE 'Région_Secondaire'
        END AS region_category,

        CASE
            WHEN es.amount < 25 THEN 'Faible'
            WHEN es.amount < 75 THEN 'Moyen'
            ELSE 'Élevé'
        END AS amount_category

    FROM ANALYTICS.enriched_sales es
),

monthly_stats AS (
    SELECT
        region,
        feature_month,
        AVG(amount) AS avg_amount_region_month,
        COUNT(*) AS transaction_count_region_month
    FROM base
    GROUP BY region, feature_month
)

SELECT
    b.*,

    -- Ajout des features agrégées
    m.avg_amount_region_month,
    m.transaction_count_region_month,

    -- Tendance (mois précédent)
    LAG(m.avg_amount_region_month)
        OVER (PARTITION BY b.region ORDER BY b.feature_month)
        AS prev_month_avg_amount,

    -- Target ML
    CASE WHEN b.amount > 100 THEN 1 ELSE 0 END AS high_value_transaction

FROM base b
LEFT JOIN monthly_stats m
    ON b.region = m.region
   AND b.feature_month = m.feature_month;


-- Commentaires
COMMENT ON TABLE ANALYTICS.ml_features IS 'Table des features préparées pour les modèles ML';
COMMENT ON COLUMN ANALYTICS.ml_features.has_promotion IS 'Indicateur binaire de promotion active';
COMMENT ON COLUMN ANALYTICS.ml_features.high_value_transaction IS 'Target: transaction de valeur élevée (>100)';

-- Vérifications
SELECT COUNT(*) AS total_ml_features FROM ANALYTICS.ml_features;
SELECT * FROM ANALYTICS.ml_features LIMIT 10;

-- =====================================================
-- TABLE : customer_ml_features
-- Features au niveau client pour segmentation
-- =====================================================

CREATE OR REPLACE TABLE ANALYTICS.customer_ml_features AS
SELECT
    ec.customer_id,
    ec.age,
    CASE WHEN ec.gender = 'Male' THEN 1 ELSE 0 END AS is_male,
    CASE WHEN ec.marital_status = 'Married' THEN 1 ELSE 0 END AS is_married,
    ec.annual_income,

    -- Encodage des segments
    CASE
        WHEN ec.age_group = '18-24' THEN 1
        WHEN ec.age_group = '25-34' THEN 2
        WHEN ec.age_group = '35-44' THEN 3
        WHEN ec.age_group = '45-54' THEN 4
        WHEN ec.age_group = '55-64' THEN 5
        ELSE 6
    END AS age_group_encoded,

    CASE
        WHEN ec.income_segment = 'Faible Revenu' THEN 1
        WHEN ec.income_segment = 'Revenu Moyen' THEN 2
        WHEN ec.income_segment = 'Haut Revenu' THEN 3
        ELSE 4
    END AS income_segment_encoded,

    -- Features géographiques (one-hot encoding simplifié)
    CASE WHEN ec.region = 'North' THEN 1 ELSE 0 END AS region_north,
    CASE WHEN ec.region = 'South' THEN 1 ELSE 0 END AS region_south,
    CASE WHEN ec.region = 'East' THEN 1 ELSE 0 END AS region_east,
    CASE WHEN ec.region = 'West' THEN 1 ELSE 0 END AS region_west

FROM ANALYTICS.enriched_customers ec;

-- Commentaires
COMMENT ON TABLE ANALYTICS.customer_ml_features IS 'Features au niveau client pour modèles de segmentation';
COMMENT ON COLUMN ANALYTICS.customer_ml_features.age_group_encoded IS 'Encodage numérique des groupes d âge';

-- Vérifications
SELECT COUNT(*) AS total_customer_ml_features FROM ANALYTICS.customer_ml_features;
SELECT * FROM ANALYTICS.customer_ml_features LIMIT 10;

-- =====================================================
-- Feature Engineering terminé !
-- Prêt pour l'entraînement des modèles ML
-- =====================================================
