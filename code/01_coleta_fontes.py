"""Fase 1: coleta automatica das fontes de dados (somente download; limpeza em Stata).

Cada fonte vai para data/raw/<fonte>/ com um _SOURCE.txt (URL, data de acesso, notas).
Downloads ja feitos sao reaproveitados; use --force para baixar de novo.
Uma fonte que falha e registrada em data/raw/_falhas.txt e o script segue com as demais.
Nenhum dado e simulado ou preenchido: o que falhar vira download manual (docs/DOWNLOADS_MANUAIS.md).
"""
import io, sys, json, time, zipfile, datetime as dt
from pathlib import Path
import requests
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
FORCE = "--force" in sys.argv
TODAY = dt.date.today().isoformat()
UA = {"User-Agent": "curl/8.4 (academic replication package)"}
IMF = "https://api.imf.org/external/sdmx/3.0"
IMF_CSV = {"Accept": "application/vnd.sdmx.data+csv;version=2.0.0"}
FAILS = []


def source_note(d: Path, lines):
    d.mkdir(parents=True, exist_ok=True)
    (d / "_SOURCE.txt").write_text("\n".join([f"Data de acesso: {TODAY}"] + lines) + "\n", encoding="utf-8")


def get(url, headers=None, tries=4, timeout=300, **kw):
    for k in range(tries):
        try:
            r = requests.get(url, headers={**UA, **(headers or {})}, timeout=timeout, **kw)
            if r.status_code == 429:
                time.sleep(30)
                continue
            r.raise_for_status()
            return r
        except Exception as e:  # noqa: BLE001
            if k == tries - 1:
                raise
            time.sleep(5 * (k + 1))


def task(name):
    def deco(f):
        def run():
            out = RAW / name
            if out.exists() and (out / "_SOURCE.txt").exists() and not FORCE:
                print(f"[cache] {name}")
                return
            print(f"[baixando] {name}")
            try:
                f(out)
            except Exception as e:  # noqa: BLE001
                FAILS.append(f"{name}: {type(e).__name__}: {e}")
                print(f"   FALHOU {name}: {e}")
        run.__name__ = name
        return run
    return deco


# ---------------------------------------------------------------- Banco Mundial
def wb_indicator(code, source=None):
    rows, page = [], 1
    while True:
        url = (f"https://api.worldbank.org/v2/country/all/indicator/{code}?format=json"
               f"&per_page=20000&date=1960:2025&page={page}" + (f"&source={source}" if source else ""))
        j = get(url).json()
        if len(j) < 2 or j[1] is None:
            msg = j[0].get("message") if isinstance(j[0], dict) else j
            raise RuntimeError(f"{code}: {msg}")
        for o in j[1]:
            rows.append((o["countryiso3code"], o["country"]["value"], int(o["date"]), o["value"]))
        if page >= j[0]["pages"]:
            break
        page += 1
    return pd.DataFrame(rows, columns=["iso3", "country", "year", code])


def wb_bulk(out, codes, source=None, note=""):
    out.mkdir(parents=True, exist_ok=True)
    df = None
    for c in codes:
        try:
            d = wb_indicator(c, source)
        except Exception as e:  # noqa: BLE001
            FAILS.append(f"{out.name}/{c}: {e}")
            print(f"   indicador indisponivel {c}: {e}")
            continue
        d = d[d.iso3.str.len() == 3]
        df = d if df is None else df.merge(d, on=["iso3", "country", "year"], how="outer")
        print(f"   {c}: {d[c].notna().sum()} obs")
    df.to_csv(out / f"{out.name}.csv", index=False)
    source_note(out, [f"API: https://api.worldbank.org/v2/country/all/indicator/<codigo>"
                      + (f"?source={source}" if source else ""), f"Indicadores: {', '.join(codes)}", note])


WDI_CODES = [
    "NY.GDP.PCAP.KD", "NY.GDP.PCAP.KD.ZG", "NY.GDP.MKTP.KD", "NY.GDP.MKTP.CN", "NY.GDP.DEFL.ZS",
    "NE.GDI.FTOT.ZS", "NE.GDI.FPRV.ZS", "FP.CPI.TOTL.ZG", "NY.GDP.DEFL.KD.ZG", "NE.TRD.GNFS.ZS",
    "SP.POP.TOTL", "SP.POP.GROW", "NE.CON.GOVT.ZS", "NY.GDP.TOTL.RT.ZS", "SP.POP.DPND",
    "TT.PRI.MRCH.XD.WD", "GC.XPN.COMP.ZS", "GC.XPN.TOTL.GD.ZS", "GC.REV.XGRT.GD.ZS",
    "SL.TLF.TOTL.IN", "SL.UEM.TOTL.ZS", "SL.EMP.WORK.ZS", "SL.EMP.TOTL.SP.ZS", "SE.SEC.ENRR",
]


@task("wdi")
def wdi(out):
    wb_bulk(out, WDI_CODES, note="World Development Indicators (source 2).")
    meta = get("https://api.worldbank.org/v2/country?format=json&per_page=500").json()[1]
    pd.DataFrame([{"iso3": m["id"], "name": m["name"], "region": m["region"]["value"],
                   "income": m["incomeLevel"]["value"], "lending": m["lendingType"]["value"]}
                  for m in meta]).to_csv(out / "wdi_paises.csv", index=False)


@task("wgi")
def wgi(out):
    wb_bulk(out, [f"GOV_WGI_{d}.EST" for d in ["GE", "RQ", "RL", "CC", "VA", "PV"]], source=3,
            note="Worldwide Governance Indicators (source 3), estimativas pontuais.")


@task("wwbi")
def wwbi(out):
    ind = get("https://api.worldbank.org/v2/sources/64/indicators?format=json&per_page=400").json()[1]
    pd.DataFrame([{"id": i["id"], "name": i["name"]} for i in ind]).to_csv(RAW / "wwbi_catalogo.csv", index=False)
    codes = ["BI.WAG.TOTL.GD.ZS", "BI.WAG.TOTL.PB.ZS", "BI.EMP.TOTL.PB.ZS", "BI.EMP.PWRK.PB.ZS",
             "BI.EMP.FRML.PB.ZS", "BI.WAG.PREM.PB", "BI.WAG.PREM.PB.GP", "BI.WAG.CPRS.PB.ZS"]
    codes += [i["id"] for i in ind if "tertiary education" in i["name"].lower()
              and "public paid employees" in i["name"].lower() and "female" not in i["name"].lower()
              and "male" not in i["name"].lower()][:1]
    wb_bulk(out, codes, source=64, note="Worldwide Bureaucracy Indicators (source 64).")


@task("income_hist")
def income_hist(out):
    out.mkdir(parents=True, exist_ok=True)
    u = "https://databankfiles.worldbank.org/public/ddpext_download/site-content/OGHIST.xlsx"
    (out / "OGHIST.xlsx").write_bytes(get(u).content)
    x = pd.read_excel(out / "OGHIST.xlsx", sheet_name="Country Analytical History", header=None)
    x.to_csv(out / "OGHIST_country_analytical_history.csv", index=False, header=False)
    source_note(out, [f"URL: {u}", "Classificacao historica de renda do Banco Mundial (por ano fiscal)."])


# ---------------------------------------------------------------- FMI (SDMX 3.0)
def imf_data(agency, flow, key):
    r = get(f"{IMF}/data/dataflow/{agency}/{flow}/+/{key}", headers=IMF_CSV, timeout=900)
    df = pd.read_csv(io.StringIO(r.text), low_memory=False)
    keep = [c for c in df.columns if c in ("COUNTRY", "SECTOR", "GFS_GRP", "INDICATOR", "TYPE_OF_TRANSFORMATION",
                                           "WGT_TYPE", "FREQUENCY", "TIME_PERIOD", "OBS_VALUE", "UNIT",
                                           "DERIVATION_TYPE", "STATUS")]
    return df[keep]


def imf_task(out, agency, flow, key, note):
    out.mkdir(parents=True, exist_ok=True)
    df = imf_data(agency, flow, key)
    df.to_csv(out / f"{flow.lower()}.csv", index=False)
    print(f"   {flow}: {len(df)} linhas, {df.COUNTRY.nunique()} paises")
    source_note(out, [f"API: {IMF}/data/dataflow/{agency}/{flow}/+/{key}", note])


GFS_IND = ["G21_T", "G2_T", "G1_T", "G11_T", "GNLB_T", "GPB_T", "G31_A_T", "NNFAG_A_T", "G22_T", "G24_T",
           "G25_T", "G26_T", "G27_T", "G28_T"]
GFS_SEC = ["S13", "S1311", "S1321", "S1311B", "S1311MIXED"]


@task("imf_gfs")
def imf_gfs(out):
    out.mkdir(parents=True, exist_ok=True)
    parts = []
    for ind in GFS_IND:  # um indicador por chamada para nao estourar o servidor
        key = f"*.{'+'.join(GFS_SEC)}.*.{ind}.POGDP_PT+POTO_PT.A"
        d = imf_data("IMF.STA", "GFS_SOO", key)
        print(f"   GFS {ind}: {len(d)} linhas")
        parts.append(d)
    pd.concat(parts).to_csv(out / "gfs_soo.csv", index=False)
    source_note(out, [f"API: {IMF}/data/dataflow/IMF.STA/GFS_SOO/+/*.<setor>.*.<indicador>.POGDP_PT+POTO_PT.A",
                      f"Indicadores: {', '.join(GFS_IND)}", f"Setores: {', '.join(GFS_SEC)}",
                      "GFS Statement of Operations; G21 = compensation of employees."])


@task("imf_icsd")
def imf_icsd(out):
    imf_task(out, "IMF.FAD", "ICSD", "*.P51G_S13_Q_POGDP_PT+P51G_PUPVT_Q_POGDP_PT+P51G_PS_Q_POGDP_PT"
             "+CAPSTCK_S13_Q_POGDP_PT+CAPSTCK_PUPVT_Q_POGDP_PT.A",
             "Investment and Capital Stock Dataset: investimento e estoque publico (S13) e privado (PUPVT), % PIB.")


@task("imf_gdd")
def imf_gdd(out):
    imf_task(out, "IMF.FAD", "GDD", "*.FL_S13_POGDP_PT+FL_S1311MIXED_POGDP_PT+FL_PS_POGDP_PT.A",
             "Global Debt Database: divida publica, % PIB.")


@task("imf_ctot")
def imf_ctot(out):
    imf_task(out, "IMF.RES", "CTOT", "*.CEMPI_CTOTXM_GDP+CEMPI_CTOTNX_TT.H_FW_IX+H_RW_IX.A",
             "Commodity Terms of Trade (Gruss e Kebhaj), anual; pesos fixos (FW) e moveis (RW).")


@task("imf_fd")
def imf_fd(out):
    imf_task(out, "IMF.STA", "FD", "*.*.*.A", "Fiscal Decentralization dataset.")


@task("imf_world")
def imf_world(out):
    imf_task(out, "IMF.FAD", "WORLD", "*.*.*.A", "World Revenue Longitudinal Database (WoRLD).")


@task("imf_weo")
def imf_weo(out):
    imf_task(out, "IMF.RES", "WEO", "*.GGX_NGDP+GGR_NGDP+GGXCNL_NGDP+GGXWDG_NGDP+NGDP_RPCH.A",
             "World Economic Outlook (ultima edicao na API): despesa, receita, resultado e divida do governo geral.")


# ---------------------------------------------------------------- outras fontes
def download(out, fname, url, note, check=None):
    out.mkdir(parents=True, exist_ok=True)
    r = get(url, timeout=1200)
    if check and not r.content[:len(check)] == check:
        raise RuntimeError(f"conteudo inesperado em {url}: {r.content[:80]!r}")
    (out / fname).write_bytes(r.content)
    source_note(out, [f"URL: {url}", note])


@task("vdem")
def vdem(out):
    download(out, "V-Dem-CY-Core-v16_csv.zip", "https://v-dem.net/media/datasets/V-Dem-CY-Core-v16_csv.zip",
             "V-Dem Country-Year Core v16.", check=b"PK")
    with zipfile.ZipFile(out / "V-Dem-CY-Core-v16_csv.zip") as z:
        name = [n for n in z.namelist() if n.endswith(".csv")][0]
        cols = ["country_name", "country_text_id", "year", "v2stcritrecadm", "v2clrspct", "v2excrptps",
                "v2stcritrecadm_osp", "v2clrspct_osp", "v2x_polyarchy", "v2x_rule"]
        with z.open(name) as f:
            df = pd.read_csv(f, usecols=lambda c: c in cols, low_memory=False)
    df.to_csv(out / "vdem_subset.csv", index=False)


@task("qog")
def qog(out):
    download(out, "qog_std_ts_jan26.csv", "https://www.qogdata.pol.gu.se/data/qog_std_ts_jan26.csv",
             "QoG Standard Dataset, time-series, janeiro 2026. Inclui ICTD/UNU-WIDER GRD (ictd_*) e NELDA.",
             check=b"ccode")
    r = get("https://www.qogdata.pol.gu.se/data/qog_exp_agg_20.csv")
    (out / "qog_exp_agg_20.csv").write_bytes(r.content)
    with open(out / "_SOURCE.txt", "a", encoding="utf-8") as f:
        f.write("URL: https://www.qogdata.pol.gu.se/data/qog_exp_agg_20.csv (QoG Expert Survey 2020, agregado)\n")


@task("pwt")
def pwt(out):
    download(out, "pwt110.dta", "https://dataverse.nl/api/access/datafile/554024",
             "Penn World Table 11.0 (Groningen Growth and Development Centre), arquivo Stata. "
             "Link 'Stata' da pagina https://www.rug.nl/ggdc/productivity/pwt/", check=b"<stata_dta>")


@task("dpi")
def dpi(out):
    download(out, "DPI2020_stata13.dta", "https://data.iadb.org/files/download/d201c239-ac19-4a78-99b1-c3dff0cb496b",
             "Database of Political Institutions 2020 (BID), arquivo Stata 13. "
             "Pagina: https://data.iadb.org/dataset/the-database-of-political-institutions-dpi-2020",
             check=b"<stata_dta>")


@task("ilostat")
def ilostat(out):
    out.mkdir(parents=True, exist_ok=True)
    base = "https://rplumber.ilo.org/data/indicator/?id={}&sex=SEX_T&classif1=AGE_AGGREGATE_TOTAL&timefrom=1990&format=.csv"
    for ind in ["EMP_PUBL_SEX_AGE_NB_A", "EMP_TEMP_SEX_AGE_NB_A"]:
        r = get(base.format(ind), timeout=900)
        (out / f"{ind}.csv").write_bytes(r.content)
        nlin = r.content.count(b"\n")
        print(f"   ILO {ind}: {nlin} linhas")
    source_note(out, ["API: " + base.format("<indicador>"),
                      "EMP_PUBL = emprego no setor publico (mil); EMP_TEMP = emprego total (mil). Total por sexo e idade."])


@task("eurostat")
def eurostat(out):
    download(out, "gov_10a_main.csv",
             "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/gov_10a_main/A.PC_GDP.S13+S1311.D1PAY+TE+TR.?format=SDMX-CSV",
             "Eurostat gov_10a_main: D1PAY (compensation of employees, payable), TE (total expenditure), TR (total revenue), % PIB, S13 e S1311.")


TASKS = [wdi, wgi, wwbi, income_hist, imf_gfs, imf_icsd, imf_gdd, imf_ctot, imf_fd, imf_world, imf_weo,
         vdem, qog, pwt, dpi, ilostat, eurostat]

if __name__ == "__main__":
    only = [a for a in sys.argv[1:] if not a.startswith("--")]
    for t in TASKS:
        if not only or t.__name__ in only:
            t()
    (RAW / "_falhas.txt").write_text("\n".join(FAILS) + ("\n" if FAILS else ""), encoding="utf-8")
    print("\nFalhas:", FAILS or "nenhuma")
