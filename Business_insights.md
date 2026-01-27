### 05_descriptive_performance
## 05_sales_evolution.sql
### 1. Évolution des ventes dans le temps
**Référence du script :** sql/sales_evolution.sql

**Résultats clés :** 
**Instabilité chronique :** Les revenus affichent une volatilité extrême, oscillant historiquement entre des sommets à plus de 60 000 $ (ex: Nov. 2013, Mai 2022) et des creux critiques sous la barre des 15 000 $.
**Chute brutale en 2023 :** Après un pic de performance en Mai (55 573,09 $), le chiffre d'affaires s'est effondré de 75 % pour atteindre son point le plus bas de l'année en Octobre (13 564,58 $).
**Déficit de récurrence :** Le volume de commandes est passé de 9 transactions mensuelles en moyenne lors des pics à seulement 2 transactions lors des périodes de creux, confirmant une fuite massive de la clientèle.
**Insight Business :**
AnyCompany souffre d'une « érosion par intermittence ». Les ventes ne reposent pas sur une demande organique stable, mais semblent dépendre d'événements ponctuels ou de cycles saisonniers mal maîtrisés. Cette fragilité structurelle a permis aux marques Digital-First (D2C) de s'installer : elles captent la récurrence du quotidien que AnyCompany ne parvient plus à sécuriser, transformant nos anciens clients fidèles en acheteurs d'opportunité.
**Stratégie de redressement :**
Passer d'une stratégie de "pics de vente" à une stratégie de "revenu plancher". L'objectif prioritaire pour 2025 est de sécuriser un socle de revenus minimal de 35 000 $/mois. Pour compenser la réduction du budget marketing, AnyCompany doit impérativement lisser cette courbe de volatilité en lançant des programmes de fidélisation ou de réapprovisionnement automatique (abonnement), garantissant ainsi une part de marché stable face à l'agilité des nouveaux entrants.



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

## 8. Service Client : Analyse des Interactions (Volume vs Satisfaction)
**Référence du script :** `sql/customer_service_analysis.sql`

**Résultats clés :**
- **Canaux les plus sollicités :** Les **Plaintes par Email** (289 interactions) et les **Demandes de produits par Chat** (276) dominent le flux de travail du service client.
- **Pic de Satisfaction :** Le suivi de commande (**Order Status**) via **Email** enregistre le score de satisfaction le plus élevé (**3,20**), suivi de près par les retours sur les réseaux sociaux (3,17).
- **Alerte Critique :** Le **Support Technique par Chat** est le point le plus faible de l'expérience client avec un score de seulement **2,75**, ce qui indique une incapacité à résoudre des problèmes complexes en temps réel.
- **Inefficacité du Téléphone :** Les appels pour le statut des commandes sont massifs (271 interactions) mais génèrent une satisfaction médiocre (**2,91**), suggérant un processus fastidieux pour le client.

**Insight Business :**
Les données révèlent une surcharge des canaux synchrones (Téléphone/Chat) pour des questions à faible valeur ajoutée comme le statut des commandes. Le décalage de satisfaction entre l'Email (3,20) et le Téléphone (2,91) pour une même catégorie montre que le client préfère une information écrite et précise plutôt qu'une attente téléphonique.

**Stratégie :**
1. **Automatisation "Self-Service" :** Implémenter un système de suivi de commande automatisé (chatbot ou portail client) pour réduire les 271 appels téléphoniques, permettant de réallouer le budget vers des experts techniques.
2. **Optimisation du Chat Technique :** Renforcer la base de connaissances des agents de chat ou améliorer l'escalade vers le support technique de niveau 2, car le score de 2,75 est critique pour la rétention client.
3. **Migration vers le Digital :** Encourager l'utilisation de l'Email et des réseaux sociaux pour les retours et plaintes, car ces canaux présentent une meilleure efficacité perçue par les clients.

 ## 9. Opérations : Analyse des Ruptures de Stock (Risques Logistiques)
**Référence du script :** `sql/inventory_stockout_analysis.sql`

**Résultats clés :**
- **Déficit Critique :** L'entrepôt **Wright-Warren** présente le déficit le plus alarmant pour la catégorie **Snacks** avec un manque de **388 unités** par rapport au seuil de réapprovisionnement.
- **Catégories les plus exposées :** Les **Boissons (Beverages)** et l'**Alimentation Bébé (Baby Food)** sont les catégories qui apparaissent le plus fréquemment en situation de sous-stock critique.
- **Gravité du stock actuel :** Plusieurs produits affichent un stock réel représentant moins de **25%** du seuil de sécurité (ex: Boissons chez Sims, Rodriguez and Byrd avec 101 unités pour un seuil de 439).
- **Entrepôts sous tension :** Wright-Warren, Clarke-Phillips et Wise LLC concentrent les plus gros volumes de déficit, mettant en péril la distribution régionale.

**Insight Business :**
La chaîne logistique est actuellement en mode "réactif" plutôt que "prédictif". Étant donné que AnyCompany est un acteur majeur du secteur Food & Beverage, avoir des ruptures massives sur les catégories **Beverages** (cœur de métier) et **Baby Food** (haute fidélité) est critique. Ces ruptures expliquent probablement une partie de la baisse de la part de marché (de 28% à 22%), car le produit n'est simplement pas disponible en rayon.

**Stratégie :**
1. **Réapprovisionnement Prioritaire :** Lancer des ordres d'achat d'urgence pour les catégories Boissons et Alimentation Bébé dans les entrepôts du Top 10 des déficits.
2. **Révision des seuils (Reorder Points) :** Ajuster les seuils de sécurité en fonction de la saisonnalité et des délais de livraison des fournisseurs (Lead Time) pour éviter que le stock ne tombe aussi bas avant le déclenchement d'une commande.
3. **Optimisation des Transferts :** Évaluer si des entrepôts avec un surplus (ex: Torres Ltd en Clothing) peuvent libérer de l'espace ou des ressources logistiques pour prioriser le flux des produits de grande consommation à forte rotation.

## 10. Logistique : Performance et Délais de Livraison
**Référence du script :** `sql/logistics_performance.sql`

**Résultats clés :**
- **Incohérence des Délais :** Les méthodes **Express** en Asie (7,94 jours) et **International** en Europe (7,93 jours) affichent les délais moyens les plus longs.
- **Échec de la Promesse Client :** La méthode **Next Day** (lendemain) ne respecte nulle part son nom, avec des délais réels oscillant entre **7,13 jours** (Amérique du Nord) et **7,84 jours** (Océanie).
- **Volume vs Rapidité :** L'Amérique du Nord concentre le plus grand nombre d'envois en mode **Standard** (203 envois) avec un délai de 7,47 jours, ce qui est paradoxalement plus rapide que certains envois Express en Asie.
- **Homogénéité Critique :** Il y a très peu de variation entre le mode le plus lent (7,94) et le plus rapide (7,13), ce qui suggère que les options prioritaires ne bénéficient d'aucun traitement de faveur réel dans la chaîne logistique.

**Insight Business :**
AnyCompany fait face à une crise de crédibilité logistique. Les clients paient probablement un supplément pour des services "Express" ou "Next Day" qui, dans les faits, mettent autant de temps que le service Standard (environ 7 à 8 jours). Cette situation est un moteur majeur d'insatisfaction et explique les mauvaises notes obtenues dans les interactions avec le service client.

**Stratégie :**
1. **Renégociation des Contrats Transporteurs :** Auditer les prestataires (Carriers) en Asie et Europe pour comprendre pourquoi les envois Express sont plus lents que les envois Standards.
2. **Alignement Marketing :** Suspendre la facturation premium pour le "Next Day" tant que les délais réels ne sont pas drastiquement réduits, afin d'éviter les plaintes pour publicité mensongère.
3. **Optimisation Régionale :** Prioriser l'amélioration du hub de distribution en Amérique du Nord, qui possède déjà le volume le plus élevé et les meilleurs délais relatifs, pour en faire un modèle d'efficacité exportable aux autres régions.

## 11. Analyse de la Satisfaction Produit (Qualité et Avis)
**Référence du script :** `sql/product_quality_analysis.sql`

**Résultats clés :**
- **Performance de Masse :** La catégorie **Plant-based Milk Alternatives** est le moteur de satisfaction avec une excellente note de **4,22** sur plus de **422 avis**, confirmant la solidité de ce segment premium.
- **Alerte Qualité :** Les **Cold-pressed Juices** (Jus pressés à froid) affichent une note décevante de **3,65** pour un volume important (356 avis). C'est le principal point de déception pour les clients réguliers.
- **Pépite de Croissance :** Les **Ready-to-eat Organic Salads** reçoivent une note exceptionnelle de **4,72**, signalant un fort potentiel de fidélisation si les investissements marketing augmentent sur ce produit.
- **Données Insuffisantes :** Les Organic Energy Bars (1.00) et Breakfast Cereals (5.00) ne comptent qu'une seule évaluation, ce qui rend ces scores statistiquement non significatifs mais nécessite une attention immédiate pour éviter un mauvais bouche-à-oreille initial.

**Insight Business :**
Il existe une corrélation directe entre la baisse de parts de marché et la qualité perçue de nos produits à fort volume comme les jus de fruits (3,65). Alors que la concurrence D2C (Direct-to-Consumer) mise sur la fraîcheur, AnyCompany semble stagner sur la qualité de ses boissons phares, ce qui pousse les clients vers des alternatives mieux notées.

**Stratégie :**
1. **Contrôle Qualité Prioritaire :** Auditer la chaîne de production et la fraîcheur des "Cold-pressed Juices" pour remonter la note au-dessus de 4.0, car c'est une catégorie stratégique pour le CA.
2. **Levier de Croissance :** Utiliser l'excellente réputation des **Salades Bio** et des **Laits Végétaux** comme "produits d'appel" dans les campagnes marketing pour regagner les 10 points de parts de marché visés.
3. **Campagne de Collecte d'Avis :** Lancer une campagne d'incitation (ex: coupons de réduction) pour les barres énergétiques et les céréales afin d'obtenir une base d'avis représentative et corriger les éventuels défauts de lancement.
