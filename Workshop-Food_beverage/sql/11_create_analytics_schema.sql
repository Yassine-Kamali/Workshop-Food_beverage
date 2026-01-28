-- =====================================================
-- Phase 3 - Data Product & Machine Learning
-- Étape 11 : Création du schéma ANALYTICS
-- =====================================================

USE DATABASE ANYCOMPANY_LAB;
USE WAREHOUSE ANYCOMPANY_WH;

-- Création du schéma ANALYTICS pour les tables analytiques
CREATE SCHEMA IF NOT EXISTS ANALYTICS
COMMENT = 'Schéma contenant les tables analytiques et data products pour les analyses et ML';

-- Vérification
SHOW SCHEMAS LIKE 'ANALYTICS';