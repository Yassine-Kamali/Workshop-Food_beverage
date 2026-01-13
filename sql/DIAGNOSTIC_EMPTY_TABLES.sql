-- =====================================================
-- DIAGNOSTIC - Pourquoi les tables BRONZE sont vides ?
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA BRONZE;
USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- 1. VÉRIFIER LE STAGE S3
-- =====================================================

-- Afficher la configuration du stage
SHOW STAGES IN SCHEMA BRONZE;

-- Lister les fichiers disponibles dans le stage S3
LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE;

-- Si la commande ci-dessus ne retourne rien, le problème est l'accès au S3

-- =====================================================
-- 2. VÉRIFIER LES FORMATS DE FICHIERS
-- =====================================================

SHOW FILE FORMATS IN SCHEMA BRONZE;

-- =====================================================
-- 3. VÉRIFIER L'HISTORIQUE DES COPY INTO
-- =====================================================

-- Voir l'historique des dernières tentatives de chargement
SELECT 
    *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'ANYCOMPANY_LAB.BRONZE.CUSTOMER_DEMOGRAPHICS',
    START_TIME => DATEADD(hours, -24, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

-- =====================================================
-- 4. TEST DE CHARGEMENT AVEC ERREURS DÉTAILLÉES
-- =====================================================

-- Vider la table si elle existe déjà
TRUNCATE TABLE IF EXISTS BRONZE.customer_demographics;

-- Test de chargement avec affichage des erreurs
COPY INTO BRONZE.customer_demographics
FROM @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE/customer_demographics.csv
FILE_FORMAT = (FORMAT_NAME = 'ANYCOMPANY_LAB.BRONZE.CSV_FORMAT')
ON_ERROR = 'SKIP_FILE'  -- Change en SKIP_FILE pour voir les erreurs
VALIDATION_MODE = 'RETURN_ERRORS';  -- Mode validation pour voir les erreurs sans charger

-- Si des erreurs apparaissent, les analyser

-- =====================================================
-- 5. TEST AVEC UN FICHIER PLUS SIMPLE
-- =====================================================

-- Si le problème persiste, essayer avec un chemin différent
-- Parfois le problème est le nom du fichier ou le chemin

-- Lister à nouveau pour voir exactement les noms de fichiers
LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE 
PATTERN = '.*\.csv';

-- =====================================================
-- 6. SOLUTION ALTERNATIVE : CHARGEMENT DIRECT AVEC URL
-- =====================================================

-- Si le stage ne fonctionne pas, essayer un chargement direct
COPY INTO BRONZE.customer_demographics
FROM 's3://logbrain-datalake/datasets/food-beverage/customer_demographics.csv'
FILE_FORMAT = (
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    EMPTY_FIELD_AS_NULL = TRUE
)
ON_ERROR = 'ABORT_STATEMENT';  -- Arrêter si erreur pour voir le problème

-- Vérifier si ça a fonctionné
SELECT COUNT(*) FROM BRONZE.customer_demographics;
SELECT * FROM BRONZE.customer_demographics LIMIT 5;

-- =====================================================
-- 7. INFORMATIONS SYSTÈME
-- =====================================================

-- Vérifier que le warehouse est bien actif
SHOW WAREHOUSES LIKE 'ANYCOMPANY_WH';

-- Vérifier les privilèges
SHOW GRANTS ON SCHEMA BRONZE;

-- =====================================================
-- INSTRUCTIONS POUR RÉSOUDRE LE PROBLÈME
-- =====================================================

/*
ÉTAPE PAR ÉTAPE :

1. Exécutez la commande LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE;
   - Si elle retourne des fichiers : le stage fonctionne
   - Si elle est vide ou erreur : problème d'accès S3

2. Si le stage fonctionne, exécutez le COPY INTO avec VALIDATION_MODE
   - Cela vous montrera les erreurs sans charger les données

3. Regardez l'historique COPY_HISTORY pour voir les erreurs passées

4. Si rien ne fonctionne, utilisez la méthode de chargement direct (section 6)

5. Copiez les erreurs et je vous aiderai à les résoudre
*/
