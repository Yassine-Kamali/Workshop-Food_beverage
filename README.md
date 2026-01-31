# Workshop - Data-Driven Marketing Analytics avec Snowflake et Streamlit

## 📊 Contexte du projet

**AnyCompany Food & Beverage** - Transformation digitale marketing data-driven



---

## 🔐 Accès Snowflake

**URL :** https://dnb65599.snowflakecomputing.com  
**Login :** workshop_user  
**Password :** VotreMotDePasse123!  
**Database :** ANYCOMPANY_LAB  
**Warehouse :** ANYCOMPANY_WH

---

## 📁 Structure du projet

```
Food-Beverage/
├── Business_insights.md                    # Synthèse des analyses business
├── sql/                                    # Scripts SQL Snowflake
│   ├── 00_GUIDE_EXECUTION.sql             # Guide d'ordre d'exécution
│   ├── 01_setup_environment.sql           # Configuration Snowflake
│   ├── 02_create_bronze_tables.sql        # Ingestion (BRONZE)
│   ├── 03_load_data.sql                   # Chargement S3
│   ├── 04_clean_data.sql                  # Transformation (SILVER)
│   ├── 05_sales_trend_analysis.sql        # Analytics - Ventes
│   ├── 06_promotion_marketing_impact.sql  # Analytics - Promotions
│   ├── 11_create_analytics_schema.sql     # Création schéma ANALYTICS
│   ├── 12_create_analytics_tables.sql     # Data Product (Tables orchestrées)
│   └── 13_feature_engineering.sql         # Préparation des données ML
├── streamlit/                              # Dashboards Interactifs
│   ├── streamlit_app.py                   # Portier Streamlit
│   ├── marketing_roi.py                   # Analyse du ROI
│   └── promotion_analyse.py               # Analyse promo
├── ml/                                     # Intelligence Artificielle
│   ├── customer_segmentation.ipynb        # Segmentation K-Means
│   ├── promotion_response_model.ipynb     # Prédiction réponse promo
│   └── purchase_propensity.ipynb          # Modèle de propension
└── README.md
```

---

## ✅ Phase 1 - Data Preparation & Ingestion

### Objets créés dans Snowflake

- **Database :** `ANYCOMPANY_LAB`
- **Schémas :** `BRONZE` (données brutes), `SILVER` (données nettoyées)
- **Tables :** 11 tables par schéma (22 au total)
- **Warehouse :** `ANYCOMPANY_WH` (XSMALL, auto-suspend 60s)

### Tables créées

| Table | Description |
|-------|-------------|
| customer_demographics | Données démographiques clients |
| customer_service_interactions | Interactions service client |
| financial_transactions | Transactions financières |
| promotions_data | Promotions commerciales |
| marketing_campaigns | Campagnes marketing |
| product_reviews | Avis produits |
| inventory | Niveaux de stock (JSON) |
| store_locations | Localisations magasins (JSON) |
| logistics_and_shipping | Données logistiques |
| supplier_information | Informations fournisseurs |
| employee_records | Données employés |

### Transformations appliquées (SILVER)

#### 1. **Suppression des doublons**
```sql
-- Utilisation de QUALIFY avec ROW_NUMBER pour garder uniquement la première occurrence
QUALIFY ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY name) = 1
```
- Dédoublonnage sur les identifiants uniques (customer_id, transaction_id, etc.)
- Conservation de l'enregistrement le plus récent ou le plus complet

#### 2. **Gestion des valeurs NULL**
```sql
WHERE customer_id IS NOT NULL
  AND name IS NOT NULL
  AND date_of_birth IS NOT NULL
```
- Exclusion des enregistrements avec identifiants manquants
- Filtrage des dates NULL critiques
- Conservation des NULL pour champs optionnels (description, notes)

#### 3. **Standardisation des formats**
```sql
TRIM(name) AS name,                          -- Suppression espaces
UPPER(TRIM(gender)) AS gender,               -- Majuscules
LOWER(TRIM(email)) AS email,                 -- Minuscules
CASE 
    WHEN UPPER(follow_up_required) IN ('YES', 'Y', '1') THEN 'Yes'
    WHEN UPPER(follow_up_required) IN ('NO', 'N', '0') THEN 'No'
END AS follow_up_required                    -- Uniformisation booléens
```

#### 4. **Validation des valeurs**
```sql
WHERE annual_income >= 0                      -- Revenus positifs
  AND rating BETWEEN 1 AND 5                 -- Notes valides
  AND discount_percentage BETWEEN 0 AND 1    -- Pourcentages 0-100%
  AND start_date <= end_date                 -- Cohérence dates
  AND customer_satisfaction BETWEEN 1 AND 5  -- Satisfaction 1-5
```

#### 5. **Colonnes calculées ajoutées**

**Durées et périodes :**
```sql
DATEDIFF(day, start_date, end_date) AS promotion_duration_days
DATEDIFF(year, hire_date, CURRENT_DATE()) AS years_of_service
DATEDIFF(year, date_of_birth, CURRENT_DATE()) AS age
```

**Métriques métier :**
```sql
CASE 
    WHEN reach > 0 THEN budget / reach 
    ELSE NULL 
END AS cost_per_reach                        -- Coût par portée

CASE 
    WHEN current_stock <= reorder_point THEN 'Low Stock'
    WHEN current_stock <= reorder_point * 1.5 THEN 'Medium Stock'
    ELSE 'High Stock'
END AS stock_status                          -- Statut inventaire
```

**Valeurs absolues :**
```sql
ABS(amount) AS amount                        -- Montants toujours positifs
```

#### 6. **Exemple complet : customer_demographics_clean**
```sql
CREATE OR REPLACE TABLE SILVER.customer_demographics_clean AS
SELECT DISTINCT
    customer_id,
    TRIM(name) AS name,                      -- Nettoyage espaces
    date_of_birth,
    UPPER(TRIM(gender)) AS gender,           -- Standardisation
    TRIM(region) AS region,
    TRIM(country) AS country,
    TRIM(city) AS city,
    TRIM(marital_status) AS marital_status,
    annual_income
FROM BRONZE.customer_demographics
WHERE customer_id IS NOT NULL                -- Validation
  AND name IS NOT NULL
  AND date_of_birth IS NOT NULL
  AND annual_income >= 0                     -- Contrôle qualité
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id 
    ORDER BY name
) = 1;                                       -- Dédoublonnage
```

---

## 🚀 Exécution rapide

### Option 1 : Guide d'exécution principal
```sql
-- Suivre l'ordre défini dans :
-- @sql/00_GUIDE_EXECUTION.sql
```

### Option 2 : Pipeline de données (Step-by-Step)
```sql
-- 1. Infrastructure & Ingestion
@sql/01_setup_environment.sql
@sql/02_create_bronze_tables.sql
@sql/03_load_data.sql

-- 2. Nettoyage & Transformation
@sql/04_clean_data.sql

-- 3. Data Product & Analytics
@sql/11_create_analytics_schema.sql
@sql/12_create_analytics_tables.sql
@sql/13_feature_engineering.sql
```

---

## 🎯 Validation

```sql
-- Vérifier les tables créées
SHOW TABLES IN SCHEMA BRONZE;
SHOW TABLES IN SCHEMA SILVER;

-- Compter les lignes
SELECT table_schema, COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema IN ('BRONZE', 'SILVER')
GROUP BY table_schema;

-- Test d'exploration
SELECT region, COUNT(*) AS customer_count 
FROM SILVER.customer_demographics_clean 
GROUP BY region 
ORDER BY customer_count DESC;
```

### 3. Vérification des dashboards Streamlit
- Lancer localement : `streamlit run streamlit_app.py` depuis le dossier racine du projet
- Vérifier l'affichage des pages, la navigation et le chargement des widgets
- Contrôler que les visualisations utilisent les tables `SILVER` (ex : `SILVER.customer_demographics_clean`) et que les chiffres correspondent aux requêtes SQL ci-dessus
- Tester les interactions (filtres, export CSV, rafraîchissement des données) et noter les erreurs ou messages dans la console


## 📧 Soumission du projet

**Email :** axel@logbrain.fr  
**Objet :** MBAESG_EVALUATION_ARCHITECTURE_BIGDATA_2026

**Contenu requis :**
- 🔗 Lien GitHub du projet
- 🔐 Credentials Snowflake (fournis ci-dessus)

---


### Phase 2 - Analyses Business
- Analyses SQL exploratoires
- Dashboards Streamlit
- Insights marketing

### Phase 3 - Data Product & ML
- ✅ Tables analytiques (schéma ANALYTICS) : enriched_sales, active_promotions, enriched_customers
- ✅ Feature Engineering : ml_features, customer_ml_features
- ✅ Modèles ML : segmentation clients (K-means), réponse aux promotions (Random Forest), propension achat (classification)
- ✅ Notebooks Jupyter complets avec analyses et recommandations

---

**Date :** 30 Janvier 2026  
**Statut :** Phase 1 - ✅ Complétée
**statut :** Phase 2 - ✅ Complétée
**Statut :** Phase 3 - ✅ Complétée

### 🤖 Modélisation Machine Learning (Phase 3)

Le projet intègre trois cas d'usage principaux développés dans le dossier `ml/` :

1. **Segmentation Clients (`customer_segmentation.ipynb`)** :
   - Algorithme : K-Means Clustering sur les données de consommation.
2. **Réponse aux Promotions (`promotion_response_model.ipynb`)** :
   - Objectif : Prédire l'impact des campagnes sur le comportement d'achat.
3. **Propension à l'Achat (`purchase_propensity.ipynb`)** :
   - Objectif : Estimer la probabilité de conversion pour chaque profil client.

---


