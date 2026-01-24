--Script 07 : Analyse de la satisfaction client et de la qualité
--Objectif : Déterminer si la qualité du produit ou du service impacte les ventes.

-- 1. Note moyenne par catégorie de produit
-- Identifier les catégories qui déçoivent les clients.
SELECT 
    product_category AS product_category,
    ROUND(AVG(rating), 2) AS average_rating,
    COUNT(*) AS total_reviews
FROM silver.product_reviews_clean
GROUP BY 1
ORDER BY average_rating ASC;


-- 2. Corrélation des problèmes de service client
-- Quelles sont les principales plaintes qui font fuir les clients ?
SELECT 
    issue_category AS issue_category,
    resolution_status AS resolution_status,
    ROUND(AVG(customer_satisfaction), 2) AS average_satisfaction_score,
    COUNT(*) AS total_cases
FROM silver.customer_service_interactions_clean
GROUP BY 1, 2
ORDER BY total_cases DESC;
