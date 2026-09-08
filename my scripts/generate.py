import os
try:
    import docx
except ImportError:
    os.system('pip install python-docx')
    import docx

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

doc = Document()
for s in doc.sections: 
    s.top_margin, s.bottom_margin, s.left_margin, s.right_margin = [Inches(0.65)] * 4

style = doc.styles['Normal']
style.font.name, style.font.size, style.font.color.rgb = 'Arial', Pt(10), RGBColor(0x2C, 0x3E, 0x50)

# Header info
p = doc.add_paragraph()
r = p.add_run("KULANI BALOYI")
r.font.size, r.font.bold, r.font.color.rgb = Pt(18), True, RGBColor(0x00, 0x80, 0x80)

p_sub = doc.add_paragraph()
p_sub.add_run("DATA ENGINEER  |  DP-700 & DP-203 CERTIFIED\nCape Town, South Africa | 073 512 9545 | baloyi.93@gmail.com").font.color.rgb = RGBColor(0x7F, 0x8C, 0x8D)

def add_section(title):
    h = doc.add_paragraph()
    h.paragraph_format.space_before, h.paragraph_format.space_after = Pt(14), Pt(4)
    run = h.add_run(title.upper())
    run.font.bold, run.font.size, run.font.color.rgb = True, Pt(11), RGBColor(0x00, 0x80, 0x80)
    p_pr = h._p.get_or_add_pPr()
    p_bdr = OxmlElement('w:pBdr')
    bottom = OxmlElement('w:bottom')
    bottom.set(qn('w:val'), 'single')
    bottom.set(qn('w:sz'), '6')
    bottom.set(qn('w:space'), '4')
    bottom.set(qn('w:color'), '008080')
    p_bdr.append(bottom)
    p_pr.append(p_bdr)

add_section("Synopsis")
doc.add_paragraph(
    "Results-driven and Microsoft-certified Data Engineer with hands-on experience building end-to-end data platforms on Microsoft Azure and Microsoft Fabric, "
    "while concurrently managing high-level production operations. Proven ability to design and implement Medallion Architectures (Bronze, Silver, Gold), "
    "metadata-driven pipelines, SCD Type 2 dimensional modelling, fraud intelligence marts, and executive-grade Power BI dashboards. "
    "Brings a rigorous engineering systems-mindset—thinks in data flows, enforces strict data quality/governance at every layer, and thrives under high-pressure parallel workloads."
)

add_section("Technical Skills Matrix")
skills = [
    ("Cloud & Platforms", "Azure Databricks · Microsoft Azure · Microsoft Fabric · Unity Catalog · ADLS Gen2 · OneLake"),
    ("Data Engineering", "Medallion Architecture (Bronze/Silver/Gold) · Delta Lake · PySpark · Spark SQL · SCD Type 2 · Metadata-Driven ETL · Delta MERGE · Databricks Jobs · ADF · Dataflow Gen2"),
    ("Data Governance", "Audit Logging · Pipeline Monitoring · DQ Validation · Reject Record Handling · Duplicate Detection · ctrl_pipeline_audit Frameworks"),
    ("Programming & DBs", "Python (PySpark, Pandas) · SQL · T-SQL · Spark SQL · Oracle Autonomous DB · Azure SQL Database · PostgreSQL"),
    ("Analytics & BI", "Power BI Desktop & Service · DAX Measures · Direct Lake Mode · Executive Dashboards · Fraud Analytics · Financial Crime Intelligence")
]
for cat, desc in skills:
    p = doc.add_paragraph()
    p.add_run(f"•  {cat}: ").font.bold = True
    p.add_run(desc)

add_section("Professional Experience")
p1 = doc.add_paragraph()
p1.add_run("BrainsTI Projects — South Africa\n").font.bold = True
p1.add_run("Data Engineering Intern | May 2024 — Present").font.italic = True

plats = [
    ("Platform 1: Ubuntu Bank Financial Crime Risk Assessment Engine (Azure Databricks & Oracle)", [
        "Designed and delivered an end-to-end Financial Crime Risk Assessment Platform processing 2.2M+ banking transactions across 8 Oracle source entities using Azure Databricks, Delta Lake, and Power BI.",
        "Engineered a fully metadata-driven Bronze ingestion framework reading from ctrl_ingestion_config at runtime—adding a new source table requires only a metadata configuration row with zero notebook changes.",
        "Implemented Bronze-layer data quality controls: null percentage checks, row count validation, schema inspection, duplicate detection, and per-table exception handling with full audit logging to ctrl_pipeline_audit.",
        "Built Silver-layer PySpark transformation frameworks including SCD Type 2 via Delta MERGE (MD5 hash on business keys), null handling, deduplication, business rule enforcement, string standardisation, and cast operations.",
        "Engineered silver_transaction_features—a purpose-built fraud feature store pre-computing 14 fraud signals including velocity windows (1d/7d/30d), off_hours_flag, shared_device_flag, high_risk_amount_flag, and new_merchant_flag.",
        "Built five Gold fraud intelligence marts: customer risk profiling (28K+ profiles), FIU velocity networks, device linkage ring detection (18K+ assessments), merchant syndicate anomaly mart (1,986 merchants), and a base enriched transactions table.",
        "Developed a multi-dimensional fraud risk scoring engine producing an enterprise_risk_score (0–100) and risk band (CRITICAL/HIGH/MEDIUM/LOW) using six explainable weighted sub-scores without machine learning, ensuring full auditable compliance.",
        "Built 8-page executive Power BI dashboards connected live to the Gold layer via Databricks covering fraud exposure command centre, FIU investigation, device fraud rings, merchant syndicates, geographic risk, and a drill-through investigation workbench."
    ]),
    ("Platform 2: End-to-End Credit Card Fraud Analytics (Microsoft Fabric & OneLake)", [
        "Delivered a complete Microsoft Fabric credit card fraud detection platform ingesting 60,500+ transactions across 300+ customers, 60+ merchants, and 5 years of synthetic South African banking data with a realistic 15% fraud rate on high-risk merchants.",
        "Built a metadata-driven Fabric Data Pipeline using Lookup and ForEach activities to dynamically iterate over source tables—landing CSV files in OneLake Bronze Lakehouse and promoting them via PySpark notebooks to Delta tables.",
        "Developed Dataflow Gen2 Silver-layer transformations applying strict cleansing rules, null rejection, deduplication, string standardisation, and business column derivation (FraudScore, SpendCategory, AgeGroup, CardTier, IsExpired).",
        "Engineered a Gold-layer star schema dimensional model comprising Fact_Transactions and four SCD Type 2 dimensions: Dim_Customer (relocations), Dim_Card (upgrades/status changes), Dim_Merchant (category/risk reclassifications), and Dim_Date (weekend flag, quarter intelligence).",
        "Built a Fabric Semantic Model on the Gold layer, connecting Power BI via Direct Lake mode for live, in-memory performance eliminating import latency."
    ])
]

for title, bullets in plats:
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(6)
    p.add_run(title).font.bold = True
    for b in bullets:
        doc.add_paragraph(b, style='List Bullet')

p2 = doc.add_paragraph()
p2.paragraph_format.space_before = Pt(12)
p2.add_run("Twinsaver Group — South Africa\n").font.bold = True
p2.add_run("Shift Production Lead | Jan 2019 — Present (Parallel Active Role)").font.italic = True
for b in [
    "Concurrently manages end-to-end tissue manufacturing processes on PM4, overseeing complex shift workflows from raw material intake to quality-assured finished output.",
    "Leads a team of 10+ machine operators and production staff across rotating shifts, coordinating workloads, resolving operational escalations, and maintaining production SLAs.",
    "Monitors and interprets real-time production KPIs using process data platforms to identify operational trends, eliminate bottlenecks, and close efficiency gaps.",
    "Drives continuous improvement initiatives using production data to reduce raw material waste and optimize shift production throughput."
]:
    doc.add_paragraph(b, style='List Bullet')

add_section("Education & Credentials")
doc.add_paragraph("Bachelor of Chemical Engineering (Cum Laude — Dean's Merit Award) | Durban University of Technology", style='List Bullet').runs[0].font.bold = True
doc.add_paragraph("National Diploma: Chemical Engineering (Pulp & Paper Technology) | Durban University of Technology", style='List Bullet').runs[0].font.bold = True

add_section("Languages")
doc.add_paragraph("English · Xitsonga · isiZulu · Tshivenda · Xhosa · Tswana · Sepedi")

doc.save("Kulani_Baloyi_Refined_CV.docx")
print("Successfully generated Kulani_Baloyi_Refined_CV.docx on your desktop!")