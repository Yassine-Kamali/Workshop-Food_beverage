# Phase 1 - Livrables & Documentation Technique

## 📋 Résumé de la Phase 1

Cette phase couvre la préparation et l'ingestion des données pour le projet AnyCompany Food & Beverage.

## ✅ Livrables complétés

### 1. Configuration de l'environnement Snowflake
- **Script:** [`01_setup_environment.sql`](sql/01_setup_environment.sql)
- **Objets créés:**
  - Database `ANYCOMPANY_LAB`
  - Schémas `BRONZE` et `SILVER`
  - Warehouse `ANYCOMPANY_WH` (XSMALL, auto-suspend 60s)
  - Stage externe S3 pointant vers `s3://logbrain-datalake/datasets/food-beverage/`
  - Formats de fichiers CSV et JSON

### 2. Création des tables BRONZE
- **Script:** [`02_create_bronze_tables.sql`](sql/02_create_bronze_tables.sql)
- **11 tables créées** pour recevoir les données brutes

### 3. Chargement des données
- **Script:** [`03_load_data.sql`](sql/03_load_data.sql)
- **Méthode:** `COPY INTO` depuis stage S3
- **Traitement:**
  - 9 fichiers CSV chargés directement
  - 2 fichiers JSON chargés via tables temporaires avec parsing VARIANT

### 4. Nettoyage des données
- **Script:** [`04_clean_data.sql`](sql/04_clean_data.sql)
- **11 tables SILVER créées** avec suffixe `_clean`
- **Transformations appliquées:**
  - Dédoublonnage
  - Gestion des NULL
  - Standardisation des formats
  - Validation des valeurs
  - Colonnes calculées ajoutées

---

## 📊 Détail des tables

### Tables BRONZE (Données brutes)

| # | Table | Type source | Description | Colonnes clés |
|---|-------|-------------|-------------|---------------|
| 1 | `customer_demographics` | CSV | Démographie clients | customer_id, region, annual_income |
| 2 | `customer_service_interactions` | CSV | Interactions service client | interaction_id, customer_satisfaction |
| 3 | `financial_transactions` | CSV | Transactions financières | transaction_id, amount, region |
| 4 | `promotions_data` | CSV | Promotions commerciales | promotion_id, discount_percentage |
| 5 | `marketing_campaigns` | CSV | Campagnes marketing | campaign_id, budget, conversion_rate |
| 6 | `product_reviews` | CSV | Avis produits | review_id, rating, product_category |
| 7 | `inventory` | JSON | Niveaux de stock | product_id, current_stock, warehouse |
| 8 | `store_locations` | JSON | Localisations magasins | store_id, region, square_footage |
| 9 | `logistics_and_shipping` | CSV | Données logistiques | shipment_id, status, shipping_cost |
| 10 | `supplier_information` | CSV | Informations fournisseurs | supplier_id, reliability_score |
| 11 | `employee_records` | CSV | Données employés | employee_id, department, salary |

### Tables SILVER (Données nettoyées)

Chaque table BRONZE a une table correspondante dans SILVER avec le suffixe `_clean`.

**Exemple de transformations appliquées:**

#### `customer_demographics_clean`
- ✅ Dédoublonnage sur `customer_id`
- ✅ TRIM sur tous les champs texte
- ✅ Standardisation du genre (UPPER)
- ✅ Validation : `annual_income >= 0`

#### `financial_transactions_clean`
- ✅ Dédoublonnage sur `transaction_id`
- ✅ Conversion des montants en valeur absolue
- ✅ Standardisation des formats de date

#### `marketing_campaigns_clean`
- ✅ Calcul de `campaign_duration_days`
- ✅ Calcul de `cost_per_reach`
- ✅ Validation : `conversion_rate BETWEEN 0 AND 1`

#### `inventory_clean`
- ✅ Ajout du statut de stock : `Low Stock`, `Medium Stock`, `High Stock`
- ✅ Dédoublonnage par `product_id` et `warehouse`

---

## 🔍 Règles de qualité appliquées

### Gestion des doublons
```sql
QUALIFY ROW_NUMBER() OVER (PARTITION BY <id_column> ORDER BY <date_column> DESC) = 1
```

### Gestion des NULL
- Exclusion des enregistrements avec ID NULL
- Exclusion des dates NULL
- Conservation des NULL pour les champs optionnels

### Validation des valeurs
- Montants : `>= 0`
- Ratings : `BETWEEN 1 AND 5`
- Pourcentages : `BETWEEN 0 AND 1`
- Dates : `start_date <= end_date`

### Standardisation
- Texte : `TRIM()`, `UPPER()`, `LOWER()`
- Email : `LOWER(TRIM(email))`
- Booléens : Conversion en `Yes`/`No`

---

## 📈 Métriques de qualité

### Volumétrie attendue

Exécuter pour obtenir les statistiques :
```sql
SELECT 
    table_schema,
    table_name,
    row_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
ORDER BY table_schema, table_name;
```

### Comparaison BRONZE vs SILVER

```sql
SELECT 
    'customer_demographics' AS table_name,
    (SELECT COUNT(*) FROM BRONZE.customer_demographics) AS bronze_count,
    (SELECT COUNT(*) FROM SILVER.customer_demographics_clean) AS silver_count,
    bronze_count - silver_count AS rows_removed
-- Répéter pour toutes les tables
```

---

## 🚨 Points d'attention

### Crédits Snowflake
⚠️ **Attention à la consommation de crédits !**
- Warehouse configuré en XSMALL
- Auto-suspend après 60 secondes d'inactivité
- Auto-resume activé pour faciliter les tests

**Commande pour suspendre manuellement :**
```sql
ALTER WAREHOUSE ANYCOMPANY_WH SUSPEND;
```

### Erreurs potentielles

#### 1. Fichiers introuvables dans S3
```sql
-- Vérifier la présence des fichiers
LIST @ANYCOMPANY_LAB.BRONZE.S3_FOOD_BEVERAGE_STAGE;
```

#### 2. Erreurs de parsing CSV
- Paramètre `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE` activé
- Paramètre `ON_ERROR = 'CONTINUE'` utilisé dans COPY INTO

#### 3. Parsing JSON
- Utilisation de tables temporaires avec type `VARIANT`
- Casting explicite des types : `::VARCHAR`, `::INTEGER`, `::DATE`

---

## 🎯 Validation finale

### Checklist de validation

- [ ] Database `ANYCOMPANY_LAB` créée
- [ ] Schémas `BRONZE` et `SILVER` créés
- [ ] 11 tables dans `BRONZE` avec données
- [ ] 11 tables dans `SILVER` avec données nettoyées
- [ ] Warehouse actif et accessible
- [ ] Stage S3 accessible
- [ ] Aucune erreur dans les logs

### Requêtes de validation

```sql
-- 1. Compter les tables par schéma
SELECT 
    table_schema,
    COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
GROUP BY table_schema;
-- Attendu : BRONZE = 11, SILVER = 11

-- 2. Vérifier qu'aucune table n'est vide
SELECT 
    table_schema,
    table_name,
    row_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
  AND row_count = 0;
-- Attendu : Aucun résultat

-- 3. Test d'exploration simple
SELECT 
    region,
    COUNT(*) AS customer_count
FROM SILVER.customer_demographics_clean
GROUP BY region
ORDER BY customer_count DESC
LIMIT 5;
```

---

## 📚 Documentation complémentaire

### Commandes utiles

```sql
-- Se connecter au contexte
USE DATABASE ANYCOMPANY_LAB;
USE SCHEMA SILVER;
USE WAREHOUSE ANYCOMPANY_WH;

-- Explorer une table
DESCRIBE TABLE customer_demographics_clean;
SELECT * FROM customer_demographics_clean LIMIT 10;

-- Statistiques d'une colonne
SELECT 
    MIN(annual_income) AS min_income,
    MAX(annual_income) AS max_income,
    AVG(annual_income) AS avg_income
FROM customer_demographics_clean;

-- Échantillon aléatoire
SELECT * FROM financial_transactions_clean SAMPLE (100 ROWS);
```

---

## 🔗 Ressources

- [Snowflake COPY INTO](https://docs.snowflake.com/en/sql-reference/sql/copy-into-table.html)
- [Snowflake Stages](https://docs.snowflake.com/en/user-guide/data-load-s3.html)
- [Snowflake JSON](https://docs.snowflake.com/en/user-guide/json-basics.html)
- [Snowflake Warehouses](https://docs.snowflake.com/en/user-guide/warehouses.html)

---

## 🎓 Prochaines étapes : Phase 2

La Phase 2 consistera à :
1. Explorer les données SILVER
2. Créer des analyses SQL business
3. Développer des dashboards Streamlit
4. Identifier les insights marketing

**Scripts à créer pour la Phase 2 :**
- `sql/05_sales_analysis.sql`
- `sql/06_promotion_impact.sql`
- `sql/07_campaign_performance.sql`
- `streamlit/dashboard_sales.py`
- `streamlit/dashboard_marketing.py`

---

**Date :** Janvier 2026  
**Statut :** Phase 1 - ✅ Complétée
