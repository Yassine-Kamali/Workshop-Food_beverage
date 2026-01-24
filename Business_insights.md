### 05_descriptive_performance
### 1. Évolution des ventes dans le temps
**Requête :** `SELECT DATE_TRUNC('MONTH', transaction_date)...`

**Résultats clés :**
- **Pic le plus haut (2023) :** Mai ($55,573.09)
- **Point le plus bas (2023) :** Octobre ($13,564.58)
- **Tendance :** Volatilité critique avec une incapacité à maintenir le niveau de revenus au-dessus de $40k sur le dernier trimestre.

**Insight Business :** 
La baisse des ventes n'est pas graduelle, elle est irrégulière. Cela indique une fragilité face à la concurrence. Pour regagner 10 points de part de marché, AnyCompany doit lisser cette courbe et sécuriser un revenu plancher de $35,000/mois via une fidélisation accrue.


### 2. Performance par Produit et Région (Sous Promotion)
**Requête :** `SELECT t.region, p.product_category, SUM(t.amount)... INNER JOIN silver.promotions_clean...`

**Top 3 Performances :**
1. **North America | Organic Meal Solutions :** $59,064.80 (8 commandes) - Leader incontesté.
2. **South America | Organic Meal Solutions :** $39,598.77 (7 commandes).
3. **Asia | Organic Beverages :** $28,489.92 (AOV record de $9,496.64).

**Insight Business :**
Le succès de AnyCompany repose sur les "Meal Solutions" en Amérique. Cependant, l'efficacité des promotions est inégale : alors qu'elles boostent les ventes en Amérique, elles génèrent des revenus marginaux pour les "Snacks" en Asie et en Afrique. 
**Décision :** Réallouer le budget marketing des catégories sous-performantes (Snacks Afrique/Asie) vers le renforcement des "Meal Solutions" en Amérique pour sécuriser la part de marché actuelle.

### 3. Répartition des clients (Segmentation Multi-dimensionnelle)
**Requête :** `WITH customer_base AS (...) SELECT region, gender, age_group, income_segment...`

**Résultats clés :**
- **Segment Dominant :** Seniors (>55 ans) et Adultes (30-55 ans) avec "High Income".
- **Top Cluster :** South America | Female | Seniors | High Income (1.14% de la base totale).
- **Point Faible :** Le segment "Youth (<30 ans)" est quasi inexistant (<0.20% par région en moyenne).

**Insight Business :**
AnyCompany est une marque de "niche premium" pour les clients mûrs. La perte de part de marché (de 28% à 22%) s'explique par l'incapacité de la marque à attirer les nouvelles générations qui préfèrent les startups D2C. 
**Stratégie de redressement :** Utiliser les modèles ML de la Phase 3 pour identifier les attributs produits qui pourraient convertir le segment "Youth" sans cannibaliser la marge des segments "Senior" actuels.

### 06_marketing_promotion_impact
