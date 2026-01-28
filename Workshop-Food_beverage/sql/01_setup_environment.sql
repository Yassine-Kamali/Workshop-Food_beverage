-- =====================================================
-- Phase 1 - Data Preparation & Ingestion
-- Étape 1 : Préparation de l'environnement Snowflake
-- =====================================================

-- Contexte : AnyCompany Food & Beverage
-- Workshop : Data-Driven Marketing Analytics
-- Date : Janvier 2026

-- =====================================================
-- 1. Création de la base de données principale
-- =====================================================

CREATE DATABASE IF NOT EXISTS ANYCOMPANY_LAB
    COMMENT = 'Base de données principale pour le lab AnyCompany Food & Beverage';

USE DATABASE ANYCOMPANY_LAB;

-- =====================================================
-- 2. Création des schémas
-- =====================================================

-- Schéma BRONZE : Données brutes issues des sources
CREATE SCHEMA IF NOT EXISTS BRONZE
    COMMENT = 'Schéma contenant les données brutes (raw data) sans transformation';

-- Schéma SILVER : Données nettoyées et standardisées
CREATE SCHEMA IF NOT EXISTS SILVER
    COMMENT = 'Schéma contenant les données nettoyées et standardisées prêtes pour l''analyse';

-- =====================================================
-- 3. Création d'un entrepôt virtuel (Virtual Warehouse)
-- =====================================================

CREATE WAREHOUSE IF NOT EXISTS ANYCOMPANY_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Entrepôt virtuel pour les opérations du lab AnyCompany';

USE WAREHOUSE ANYCOMPANY_WH;

-- =====================================================
-- 4. Création du stage externe pour le chargement depuis S3
-- =====================================================

-- Stage pointant vers le datalake S3 contenant les fichiers sources
CREATE OR REPLACE STAGE ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE
    URL = 's3://logbrain-datalake/datasets/food-beverage/'
    COMMENT = 'Stage externe pour charger les données depuis Amazon S3';

-- =====================================================
-- 5. Création d'un format de fichier pour les CSV
-- =====================================================

CREATE OR REPLACE FILE FORMAT ANYCOMPANY_LAB.BRONZE.CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    EMPTY_FIELD_AS_NULL = TRUE
    COMMENT = 'Format de fichier CSV standard pour l''ingestion des données';

-- =====================================================
-- 6. Création d'un format de fichier pour les JSON
-- =====================================================

CREATE OR REPLACE FILE FORMAT ANYCOMPANY_LAB.BRONZE.JSON_FORMAT
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    COMMENT = 'Format de fichier JSON pour l''ingestion des données';

-- =====================================================
-- 7. Vérification de l'environnement
-- =====================================================

-- Lister les fichiers disponibles dans le stage S3
LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE;

-- Afficher les schémas créés
SHOW SCHEMAS IN DATABASE ANYCOMPANY_LAB;

-- Afficher les formats de fichiers créés
SHOW FILE FORMATS IN SCHEMA ANYCOMPANY_LAB.BRONZE;

-- =====================================================
-- Configuration terminée avec succès !
-- =====================================================
