import streamlit as st
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

session = get_active_session()

def load_data(table_name):
    return session.table(f'ANYCOMPANY_LAB.SILVER."{table_name}"')

# Filtre régional partagé pour cette page
region_list = ["Toutes", "Africa", "Asia", "Europe", "Middle East", "North America", "Oceania", "South America"]
selected_region = st.sidebar.selectbox("Filtrer par Région :", region_list, key="mkt_reg")

# --- SECTION 1 : MARKETING & ROI ---
st.header(f"ROI des Campagnes ({selected_region})")
try:
    df_mkt = load_data("MARKETING_CAMPAIGNS_CLEAN")
    if selected_region != "Toutes":
        df_mkt = df_mkt.filter(col("REGION") == selected_region)
    
    df_pd = df_mkt.to_pandas()
    st.scatter_chart(df_pd, x="BUDGET", y="CONVERSION_RATE", color="CAMPAIGN_TYPE")
    
    if not df_pd.empty:
        avg_conv = df_pd["CONVERSION_RATE"].mean()
        st.success(f"**Insight Marketing ({selected_region}) :** Taux de conversion moyen de {avg_conv:.1%}.")
except Exception as e:
    st.error(f"Erreur Marketing : {e}")

st.divider()

# --- SECTION 2 : EXPÉRIENCE CLIENT (⭐) ---
st.header(f"Qualité & Satisfaction (Toutes les régions)")
try:
    df_cx = load_data("PRODUCT_REVIEWS_CLEAN")
    df_pd_cx = df_cx.to_pandas()

    if not df_pd_cx.empty:
        df_stats = df_pd_cx.groupby("PRODUCT_CATEGORY")["RATING"].mean().reset_index()
        df_stats = df_stats.sort_values("RATING")
        reg_avg = df_stats["RATING"].mean()

        chart_color = "#FF4B4B" if reg_avg < 3.8 else "#28a745"
        st.subheader(f"Moyenne des notes : {reg_avg:.1f}/5")
        st.bar_chart(df_stats.set_index("PRODUCT_CATEGORY"), color=chart_color)

        if reg_avg < 3.5:
            st.error(f"**Alerte Qualité Critique :** Satisfaction moyenne de {reg_avg:.1f}/5.")
        elif reg_avg < 4.0:
            st.warning(f"**Insight Qualité :** Performance moyenne ({reg_avg:.1f}/5).")
        else:
            st.success(f"**Insight Qualité :** Excellente satisfaction globale ({reg_avg:.1f}/5).")
except Exception as e:
    st.error(f"Erreur d'affichage CX : {e}")