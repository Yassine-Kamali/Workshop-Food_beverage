-- Script 06 : Efficacité des promotions et ROI marketing
-- Objectif : Identifier quelles promotions génèrent le plus de valeur et lesquelles ne fonctionnent pas.

-- 1. Performance par type de promotion
-- Quelle promotion spécifique (ex. 'Beverage Bonanza') a généré le plus de revenus ?
SELECT 
    p.promotion_type AS promotion_type,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.amount) AS total_revenue,
    ROUND(AVG(t.amount), 2) AS avg_ticket_with_promo
FROM silver.financial_transactions_clean t
INNER JOIN promotions_clean p 
    ON t.region = p.region 
    AND t.transaction_date BETWEEN p.start_date AND p.end_date
GROUP BY 1
ORDER BY total_revenue DESC;

-- 2. Performance des campagnes marketing
-- Analyse de la portée par rapport au taux de conversion pour évaluer l'efficacité.
SELECT 
    campaign_name AS campaign_name,
    product_category AS product_category,
    reach AS reach,
    conversion_rate AS conversion_rate,
    budget AS budget,
    ROUND((budget / NULLIF(reach, 0)), 2) AS cost_per_reached_customer
FROM silver.marketing_campaigns_clean
ORDER BY conversion_rate DESC;
