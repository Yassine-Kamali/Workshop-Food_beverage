--1. Évolution mensuelle des ventes pour identifier la baisse.
SELECT 
    DATE_TRUNC('MONTH', transaction_date) AS sales_month,
    SUM(amount) AS total_revenue,
    COUNT(transaction_id) AS order_volume
FROM silver.financial_transactions_clean
WHERE transaction_type = 'Sale'
GROUP BY 1 
ORDER BY 1;

-- 2. Ventes par catégorie de produit
-- Objectif : Identifier les zones géographiques en sous-performance.
SELECT 
    region, 
    SUM(amount) AS total_revenue,
    COUNT(transaction_id) AS total_orders,
    ROUND(AVG(amount), 2) AS average_order_value
FROM silver.financial_transactions_clean
WHERE transaction_type = 'Sale'
GROUP BY 1 
ORDER BY total_revenue DESC;

-- 3. Ventes par catégorie de produit
-- Note : Jointure avec les promotions pour lier les ventes aux catégories dans des régions spécifiques.
SELECT 
    p.product_category AS categoria_producto,
    SUM(t.amount) AS ingresos_por_categoria,
    COUNT(t.transaction_id) AS volumen_por_categoria
FROM silver.financial_transactions_clean t
INNER JOIN promotions_clean p 
    ON t.region = p.region 
    AND t.transaction_date BETWEEN p.start_date AND p.end_date
WHERE t.transaction_type = 'Sale'
GROUP BY 1
ORDER BY ingresos_por_categoria DESC;
