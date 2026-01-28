/*Partie 2.3 – Analyses business transverses
    1.Ventes et promotions
-- 1.1 Comparaison ventes avec / sans promotion
    -- Le responsable marketing souhaite savoir si la promotion génère réellement des revenus supplémentaires ou si nous accordons simplement des remises à des clients qui auraient acheté de toute façon. Objectif : Comparer la moyenne des ventes quotidiennes des jours SANS promotion par rapport aux jours AVEC promotion.
---- Comparaison de la moyenne des ventes quotidiennes (Avec vs Sans Promo)*/

WITH daily_sales AS (
    SELECT 
        transaction_date,
        region,
        SUM(amount) AS daily_revenue
    FROM silver.financial_transactions_clean
    WHERE transaction_type = 'Sale'
    GROUP BY 1, 2
),
promo_days AS (
    SELECT DISTINCT 
        region, 
        start_date, 
        end_date
    FROM silver.promotions_clean
)
SELECT 
    CASE WHEN p.region IS NOT NULL THEN 'Día con Promoción' ELSE 'Día Normal' END AS tipo_dia,
    ROUND(AVG(daily_revenue), 2) AS promedio_venta_diaria,
    COUNT(*) AS total_dias
FROM daily_sales s
LEFT JOIN promo_days p 
    ON s.region = p.region 
    AND s.transaction_date BETWEEN p.start_date AND p.end_date
GROUP BY 1;

/* -- 1.2 Sensibilité des catégories aux promotions
  Script : Efficacité des promotions et ROI marketing
-- Objectif : Identifier quelles promotions génèrent le plus de valeur et lesquelles ne fonctionnent pas.*/

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

