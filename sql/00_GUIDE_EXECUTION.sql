-- =====================================================
-- GUIDE D'EXÉCUTION - Phase 1
-- Workshop AnyCompany Food & Beverage
-- =====================================================

/*
Ce fichier contient l'ordre d'exécution recommandé pour la Phase 1.
Suivez les étapes dans l'ordre pour garantir une configuration correcte.
*/

-- =====================================================
-- ÉTAPE 1 : Configuration de l'environnement
-- Durée estimée : 2-3 minutes
-- =====================================================

-- Exécuter le script complet :
-- @sql/01_setup_environment.sql

-- Ce script va créer :
-- - La database ANYCOMPANY_LAB
-- - Les schémas BRONZE et SILVER
-- - Le warehouse ANYCOMPANY_WH
-- - Le stage S3 externe
-- - Les formats de fichiers CSV et JSON

-- Vérification :
LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE;
-- Vous devriez voir tous les fichiers CSV et JSON disponibles

-- =====================================================
-- ÉTAPE 2 : Création des tables BRONZE
-- Durée estimée : 1-2 minutes
-- =====================================================

-- Exécuter le script complet :
-- @sql/02_create_bronze_tables.sql

-- Ce script va créer 11 tables dans le schéma BRONZE

-- Vérification :
SHOW TABLES IN SCHEMA BRONZE;
-- Vous devriez voir 11 tables créées

-- =====================================================
-- ÉTAPE 3 : Chargement des données
-- Durée estimée : 5-10 minutes
-- =====================================================

-- Exécuter le script complet :
-- @sql/03_load_data.sql

-- Ce script va :
-- - Charger tous les fichiers CSV
-- - Charger tous les fichiers JSON
-- - Afficher les statistiques de chargement

-- Vérification après chaque COPY INTO :
-- Vérifier qu'il n'y a pas d'erreurs
-- Vérifier le nombre de lignes chargées

-- Exemple de vérification globale :
SELECT 
    'customer_demographics' AS table_name,
    COUNT(*) AS row_count
FROM BRONZE.customer_demographics
UNION ALL
SELECT 'financial_transactions', COUNT(*) FROM BRONZE.financial_transactions
UNION ALL
SELECT 'promotions_data', COUNT(*) FROM BRONZE.promotions_data;

-- =====================================================
-- ÉTAPE 4 : Nettoyage et création des tables SILVER
-- Durée estimée : 5-10 minutes
-- =====================================================

-- Exécuter le script complet :
-- @sql/04_clean_data.sql

-- Ce script va :
-- - Nettoyer toutes les tables BRONZE
-- - Créer 11 tables SILVER avec suffixe _clean
-- - Appliquer les règles de qualité
-- - Ajouter des colonnes calculées

-- Vérification :
SHOW TABLES IN SCHEMA SILVER;
-- Vous devriez voir 11 tables avec suffixe _clean

-- Comparaison BRONZE vs SILVER :
SELECT 
    (SELECT COUNT(*) FROM BRONZE.customer_demographics) AS bronze_count,
    (SELECT COUNT(*) FROM SILVER.customer_demographics_clean) AS silver_count;

-- =====================================================
-- VALIDATION FINALE
-- =====================================================

-- 1. Vérifier que tous les objets ont été créés
SHOW DATABASES LIKE 'ANYCOMPANY_LAB';
SHOW SCHEMAS IN DATABASE ANYCOMPANY_LAB;
SHOW WAREHOUSES LIKE 'ANYCOMPANY_WH';

-- 2. Vérifier le nombre total de tables
SELECT 
    table_schema,
    COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
GROUP BY table_schema;

-- Résultat attendu :
-- BRONZE : 11 tables
-- SILVER : 11 tables

-- 3. Vérifier qu'il y a des données dans toutes les tables
SELECT 
    table_schema,
    table_name,
    row_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
  AND table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

-- 4. Tester quelques requêtes d'exploration
-- Exemple : Top 5 des régions par nombre de clients
SELECT 
    region,
    COUNT(*) AS customer_count
FROM SILVER.customer_demographics_clean
GROUP BY region
ORDER BY customer_count DESC
LIMIT 5;

-- Exemple : Promotions actives par catégorie
SELECT 
    product_category,
    COUNT(*) AS promo_count,
    AVG(discount_percentage) AS avg_discount
FROM SILVER.promotions_clean
GROUP BY product_category
ORDER BY promo_count DESC;
