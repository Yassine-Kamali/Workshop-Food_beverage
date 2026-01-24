import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark import functions as F

st.set_page_config(layout="wide", page_title="Promo Impact Calculator")
st.title("📊 Calculateur Impact Promotions")

try:
    session = get_active_session()
    
    # Requête SQL pour calculer les moyennes de ventes avec/sans promotion
    query = """
    WITH daily_sales AS (
        SELECT 
            transaction_date,
            region,
            SUM(amount) AS daily_revenue
        FROM SILVER.FINANCIAL_TRANSACTIONS_CLEAN
        WHERE transaction_type = 'Sale'
        GROUP BY transaction_date, region
    ),
    promo_dates AS (
        SELECT DISTINCT region, start_date, end_date
        FROM SILVER.PROMOTIONS_CLEAN
    ),
    daily_with_promo AS (
        SELECT 
            s.transaction_date,
            s.region,
            s.daily_revenue,
            CASE WHEN p.region IS NOT NULL THEN 1 ELSE 0 END AS has_promo
        FROM daily_sales s
        LEFT JOIN promo_dates p 
            ON s.region = p.region 
            AND s.transaction_date >= p.start_date 
            AND s.transaction_date <= p.end_date
    )
    SELECT 
        CASE WHEN has_promo = 1 THEN 'Jour AVEC Promotion' ELSE 'Jour SANS Promotion' END AS type_jour,
        ROUND(AVG(daily_revenue), 2) AS moyenne_vente_quotidienne,
        COUNT(*) AS nb_jours
    FROM daily_with_promo
    GROUP BY has_promo
    ORDER BY has_promo DESC;
    """
    
    # Exécuter la requête
    result_df = session.sql(query).to_pandas()
    
    st.success("✅ Requête exécutée avec succès !")
    st.dataframe(result_df, use_container_width=True)
    
    # Afficher les résultats de manière lisible
    st.subheader("📈 Résultats")
    
    for idx, row in result_df.iterrows():
        st.write(f"**{row['TYPE_JOUR']}** : {row['MOYENNE_VENTE_QUOTIDIENNE']:,.2f}€ ({row['NB_JOURS']} jours)")
    
    # Calculer la différence
    if len(result_df) == 2:
        avec_promo = result_df[result_df['TYPE_JOUR'] == 'Jour AVEC Promotion']['MOYENNE_VENTE_QUOTIDIENNE'].values[0]
        sans_promo = result_df[result_df['TYPE_JOUR'] == 'Jour SANS Promotion']['MOYENNE_VENTE_QUOTIDIENNE'].values[0]
        difference = avec_promo - sans_promo
        pct_diff = (difference / sans_promo * 100) if sans_promo != 0 else 0
        
        st.subheader("🔍 Analyse")
        st.write(f"**Différence** : {difference:,.2f}€ ({pct_diff:+.1f}%)")
        
        if pct_diff < 0:
            st.warning("⚠️ Les promotions génèrent MOINS de ventes (effet de cannibilisation)")
        elif pct_diff > 0:
            st.success("✅ Les promotions génèrent PLUS de ventes")
        else:
            st.info("➡️ Les promotions n'ont pas d'impact sur les ventes")

except Exception as e:
    st.error(f"❌ Erreur lors de l'exécution : {e}")
