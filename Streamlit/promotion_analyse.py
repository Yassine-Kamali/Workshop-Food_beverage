import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

session = get_active_session()

def load_data(table_name):
    return session.table(f'ANYCOMPANY_LAB.SILVER."{table_name}"')

# Filtre régional partagé pour cette page
region_list = ["Toutes", "Africa", "Asia", "Europe", "Middle East", "North America", "Oceania", "South America"]
selected_region = st.sidebar.selectbox("Filtrer par Région :", region_list, key="promo_reg")

# --- SECTION 1 : ANALYSE PROMOS ---
st.header(f"Efficacité des Promotions ({selected_region})")
try:
    df_promo = load_data("PROMOTIONS_CLEAN")
    if selected_region != "Toutes":
        df_promo = df_promo.filter(col("REGION") == selected_region)
    df_pd = df_promo.to_pandas()
    
    if not df_pd.empty:
        cat_means = df_pd.groupby('PRODUCT_CATEGORY')['DISCOUNT_PERCENTAGE'].mean().reset_index()
        st.bar_chart(cat_means, x="PRODUCT_CATEGORY", y="DISCOUNT_PERCENTAGE")
        top_cat = cat_means.loc[cat_means['DISCOUNT_PERCENTAGE'].idxmax()]['PRODUCT_CATEGORY']
        st.warning(f"**Insight Promotions ({selected_region}) :** La catégorie {top_cat} est la plus remisée.")
except Exception as e:
    st.error(f"Erreur Promos : {e}")

st.divider()

# --- SECTION 2 : SUPPLY CHAIN (🚚) ---
st.header(f"État des Stocks & Alertes ({selected_region})")
try:
    df_inv = load_data("INVENTORY_CLEAN")
    if selected_region != "Toutes":
        df_inv = df_inv.filter(col("REGION") == selected_region)
    
    # Alertes Ruptures
    df_stock = df_inv.filter(col("CURRENT_STOCK") < col("REORDER_POINT")).to_pandas()

    if not df_stock.empty:
        df_stock['Urgence Réappro.'] = df_stock['CURRENT_STOCK'] / df_stock['REORDER_POINT']
        st.warning(f"⚠️ {len(df_stock)} produits sous le seuil d'alerte :")
        st.data_editor(df_stock[['PRODUCT_ID', 'CURRENT_STOCK', 'REORDER_POINT', 'Urgence Réappro.']], hide_index=True)
    else:
        st.success(f"✅ Aucun produit sous le seuil d'alerte en {selected_region}.")

    st.subheader("Vision globale des stocks par catégorie")
    st.bar_chart(df_inv.to_pandas(), x="PRODUCT_CATEGORY", y="CURRENT_STOCK")
except Exception as e:
    st.error(f"Erreur Supply : {e}")