import streamlit as st

# --- CONFIGURATION GLOBALE ---
st.set_page_config(layout="wide", page_title="AnyCompany Strategic Pilot")

# --- NAVIGATION (3 Pages demandées) ---
pg = st.navigation([
    st.Page("tableau_de_tableau_des_ventes.py", title="Dashboard Exécutif", icon="📊"),
    st.Page("marketing_roi.py", title="Marketing & Expérience Client", icon="🎯"),
    st.Page("promotion_analyse.py", title="Promos & Supply Chain", icon="🏷️"),
])

# --- BARRE LATÉRALE COMMUNE ---
st.sidebar.image("https://upload.wikimedia.org/wikipedia/commons/f/ff/Snowflake_Logo.svg", width=50)
st.sidebar.title("Pilotage AnyCompany")

pg.run()