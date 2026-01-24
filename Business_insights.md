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
### 4.Comparaison des Ventes (Avec vs Sans Promotion)
**Référence du script :** `sql/promotion_comparison.sql`

**Résultats clés :**
- **Volume de ventes :** La grande majorité des transactions sont organiques (947 commandes) contre seulement 42 transactions sous promotion.
- **Domination des revenus :** Les ventes organiques génèrent 4,74 M$, représentant plus de 95% du chiffre d'affaires total.
- **Impact sur le Panier Moyen (AOV) :** Le ticket moyen est **plus élevé** lors des promotions (**5 308,83 $**) par rapport aux ventes organiques (**5 009,16 $**), soit une augmentation de **6%**.

**Insight Business :**
Les promotions de AnyCompany ne sont pas perçues comme de simples réductions de prix, mais comme un levier d'**Upselling**. Les clients profitent des offres pour monter en gamme ou acheter des volumes plus importants. Cependant, le très faible nombre de transactions sous promotion indique un manque d'exposition ou de pertinence des offres actuelles.

**Stratégie de redressement :**
Augmenter la fréquence des promotions ciblées. Puisque chaque vente promotionnelle génère en moyenne **300 $ de plus** qu'une vente normale, l'extension de ces campagnes permettra d'augmenter le revenu global et de compenser la réduction du budget marketing.


## 5. Sensibilité des Catégories aux Promotions
**Référence du script :** `sql/category_sensitivity.sql`

**Résultats clés :**
- **Le Leader :** La catégorie **Organic Meal Solutions** est la plus réactive, générant **133 105,58 $** (60% du revenu promo total).
- **Efficacité du rabais :** Les "Meal Solutions" obtiennent ce résultat avec le rabais moyen le plus faible (**11,63%**).
- **Dépendance aux remises :** La catégorie **Organic Beverages** nécessite une remise beaucoup plus agressive (**17,07%**) pour des revenus moindres (73 598 $).

**Insight Business :**
**Organic Meal Solutions** est la catégorie "moteur" de l'entreprise : elle déclenche des achats importants sans sacrifier trop de marge. À l'inverse, les boissons (Beverages) sont très sensibles au prix y consomment trop de budget promotionnel pour un retour sur investissement plus faible.

**Stratégie de redressement :**
Prioriser les remises sur les **Meal Solutions** pour maximiser le chiffre d'affaires immédiat. Pour les catégories moins performantes comme les Snacks ou Beverages, tester des stratégies de "Bundling" (offres groupées) avec les repas au lieu de faire des remises directes qui érodent la rentabilité.

## 6. Performance des Campagnes Marketing (Lien Budget vs Conversion)
**Référence du script :** `sql/campaign_impact.sql`

**Résultats clés :**
- **Allocation Budgétaire :** Les budgets les plus massifs sont alloués au **Personal Care via Email** (32,4 M$) et à l'**Electronique via Social Media** (31,3 M$).
- **Champions de la Conversion :** Le taux de conversion le plus élevé est détenu par le **Baby Food via Influencer (6,11%)**, suivi de près par les **Beverages via Content Marketing (6,00%)**.
- **Stabilité de l'Électronique :** Cette catégorie performe extrêmement bien sur le **Content Marketing (5,96%)** et l'**Email (5,99%)**, avec un reach cumulé dépassant les 110 millions de prospects.
- **Points Faibles :** Les campagnes **Radio pour le Household (5,04%)** et le **TV pour les Beverages (5,05%)** présentent les conversions les plus basses malgré des budgets significatifs.

**Insight Business :**
L'investissement n'est pas toujours aligné sur la performance. Nous sur-investissons dans des canaux traditionnels pour certaines catégories (Email/Personal Care) alors que des niches comme les **Influenceurs (Baby Food)** ou le **Content Marketing (Beverages)** offrent un bien meilleur taux de conversion. L'électronique est notre catégorie la plus équilibrée entre visibilité et efficacité.

**Stratégie de redressement :**
Pour respecter la baisse de 30% du budget marketing, il est impératif de **réallouer les fonds** des canaux TV/Radio vers le **Marketing d'Influence et de Contenu**. Nous recommandons de réduire de 20% le budget Email du Personal Care pour le réinjecter dans le segment Baby Food/Influencers, où le potentiel de conversion est maximal.

## 7. Identification des Campagnes les plus efficaces (ROI)
**Référence du script :** `sql/campaign_roi.sql`

**Résultats clés :**
- **Canal le plus rentable :** Le **Marketing d'Influence** affiche le coût par conversion le plus bas du marché (**8,71 $**).
- **Efficacité du Contenu :** Le **Content Marketing** suit de près avec un coût de **8,83 $**, confirmant que l'engagement organique est très économique.
- **Canal le plus coûteux :** La **Radio** est le moins performant avec un coût de **9,85 $** par client (13% plus cher que les influenceurs).
- **Volume vs Coût :** Le Social Media et l'Email génèrent le plus gros volume de conversions, mais à un coût moyen plus élevé (~9,20 $).

**Insight Business :**
Il existe une opportunité majeure d'optimisation. La **Radio** et la **TV** sont des canaux "chers et peu performants" pour AnyCompany. Le Marketing d'Influence et le Contenu permettent d'acquérir des millions de clients à un coût nettement inférieur.

**Stratégie de redressement :**
Pour absorber la réduction budgétaire de 30%, AnyCompany doit **éliminer les investissements en Radio** et réduire drastiquement la TV. La réallocation de ces fonds vers les **Influenceurs et le Content Marketing** permettra de maintenir le volume d'acquisition tout en réduisant les coûts fixes, sécurisant ainsi l'objectif de reconquête de part de marché.

## 07_Expérience Client & Opérations
