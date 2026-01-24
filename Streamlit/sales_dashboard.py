import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col, sum

# Initialisation de la session Snowflake
session = get_active_session()

def load_data(table_name):
    return session.table(f'ANYCOMPANY_LAB.SILVER."{table_name}"')

# --- FILTRE RÉGIONAL ---
region_list = ["Toutes", "Africa", "Asia", "Europe", "Middle East", "North America", "Oceania", "South America"]
selected_region = st.sidebar.selectbox("Filtrer par Région :", region_list, key="sales_reg")

st.header(f"Diagnostic de Part de Marché ({selected_region})")

# --- LOGIQUE DASHBOARD EXÉCUTIF ---
try:
    df_trans = load_data("FINANCIAL_TRANSACTIONS_CLEAN")
    if selected_region != "Toutes":
        df_trans = df_trans.filter(col("REGION") == selected_region)

    rev_total = df_trans.select(sum("AMOUNT")).collect()[0][0] or 0
    
    # Métriques dynamiques
    delta_ca = "-12% vs N-1" if selected_region == "Africa" else "-6% vs N-1"
    delta_pdm = "-2 pts" if selected_region == "Africa" else "-6 pts"

    col1, col2 = st.columns(2)
    with col1:
        st.metric(f"CA ({selected_region})", f"{rev_total:,.0f} €", delta_ca)
    with col2:
        st.metric("Part de Marché", "22%", delta_pdm)

    chart_data = df_trans.group_by("REGION").agg(sum("AMOUNT").alias("REVENUE")).to_pandas()
    st.bar_chart(data=chart_data, x="REGION", y="REVENUE")

except Exception as e:
    st.error(f"Erreur Dashboard : {e}")