-- Cette analyse est cruciale pour savoir si nous perdons des clients à cause des transporteurs ou de frais d'expédition trop élevés.

-- 1. Analyse des retards par transporteur (Carrier)
-- Quel transporteur nuit à notre image auprès du client ?

SELECT 
    carrier AS carrier,
    COUNT(*) AS total_shipments,
    AVG(DATEDIFF('day', ship_date, estimated_delivery)) AS avg_delivery_days,
    SUM(CASE WHEN status = 'Returned' THEN 1 ELSE 0 END) AS total_returns
FROM silver.logistics_and_shipping_clean
GROUP BY 1
ORDER BY total_returns DESC;

-- 2. Frais d'expédition vs Valeur de la commande
-- Est-ce que nous dépensons trop en frais d'expédition pour de petites commandes ?
SELECT 
    destination_region AS destination_region,
    AVG(shipping_cost) AS avg_shipping_cost,
    shipping_method AS shipping_method
FROM silver.logistics_and_shipping_clean
GROUP BY 1, 3
ORDER BY 2 DESC;
