"""
Chart Generation
================
Produces publication-quality matplotlib/seaborn charts
for the churn analysis dashboard and reports.
"""
import logging
import warnings
import numpy  as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")          # non-interactive backend (safe for scripts)
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from sklearn.metrics import roc_curve, auc

logger   = logging.getLogger(__name__)
warnings.filterwarnings("ignore")

# ── Design tokens ────────────────────────────────────────────────────────
CORAL  = "#fb7185"
TEAL   = "#2dd4bf"
AMBER  = "#f59e0b"
SAGE   = "#86efac"
VIOLET = "#a78bfa"
COLORS = [TEAL, CORAL, AMBER, SAGE, VIOLET]

plt.rcParams.update({
    "figure.facecolor": "white",
    "axes.facecolor"  : "#f9fafb",
    "axes.grid"       : True,
    "grid.alpha"      : 0.4,
    "font.family"     : "DejaVu Sans",
})


class ChurnVisualizer:
    def __init__(self, df: pd.DataFrame, cfg):
        self.df  = df
        self.out = Path(cfg.CHARTS_DIR)
        self.out.mkdir(parents=True, exist_ok=True)

    # ── 1: Contract-type churn ─────────────────────────────────────
    def plot_churn_by_contract(self):
        rates = self.df.groupby("Contract")["Churn"].mean() * 100
        fig, ax = plt.subplots(figsize=(8, 5))
        bars = ax.bar(rates.index, rates.values,
                      color=[CORAL, AMBER, SAGE], edgecolor="white", linewidth=1.5)
        for b in bars:
            ax.text(b.get_x() + b.get_width()/2, b.get_height() + 0.5,
                    f"{b.get_height():.1f}%", ha="center", fontsize=11, fontweight="bold")
        ax.set_title("Churn Rate by Contract Type", fontsize=14, fontweight="bold", pad=12)
        ax.set_ylabel("Churn Rate (%)")
        ax.set_ylim(0, 55)
        self._save(fig, "01_churn_by_contract.png")

    # ── 2: Tenure cohort ──────────────────────────────────────────
    def plot_churn_by_tenure(self):
        if "TenureCohort" not in self.df.columns:
            return
        rates = self.df.groupby("TenureCohort", observed=True)["Churn"].mean() * 100
        fig, ax = plt.subplots(figsize=(8, 5))
        ax.plot(rates.index, rates.values, marker="o", color=CORAL,
                linewidth=2.5, markersize=8)
        ax.fill_between(range(len(rates)), rates.values, alpha=0.15, color=CORAL)
        for i, (x, v) in enumerate(zip(range(len(rates)), rates.values)):
            ax.text(x, v + 1, f"{v:.1f}%", ha="center", fontsize=10)
        ax.set_xticks(range(len(rates)))
        ax.set_xticklabels(rates.index)
        ax.set_title("Churn Rate by Tenure Cohort", fontsize=14, fontweight="bold", pad=12)
        ax.set_ylabel("Churn Rate (%)")
        ax.set_ylim(0, 65)
        self._save(fig, "02_churn_by_tenure.png")

    # ── 3: Payment method ─────────────────────────────────────────
    def plot_churn_by_payment(self):
        rates = self.df.groupby("PaymentMethod")["Churn"].mean() * 100
        colors = [CORAL if v > 35 else AMBER if v > 20 else SAGE
                  for v in rates.values]
        fig, ax = plt.subplots(figsize=(9, 5))
        ax.barh(rates.index, rates.values, color=colors, edgecolor="white")
        for i, v in enumerate(rates.values):
            ax.text(v + 0.3, i, f"{v:.1f}%", va="center", fontsize=10)
        ax.set_title("Churn Rate by Payment Method", fontsize=14, fontweight="bold", pad=12)
        ax.set_xlabel("Churn Rate (%)")
        self._save(fig, "03_churn_by_payment.png")

    # ── 4: Monthly charges distribution ───────────────────────────
    def plot_monthly_charges(self):
        churned  = self.df[self.df["Churn"] == 1]["MonthlyCharges"]
        retained = self.df[self.df["Churn"] == 0]["MonthlyCharges"]
        fig, ax = plt.subplots(figsize=(9, 5))
        ax.hist(retained, bins=30, alpha=0.6, color=TEAL,  label=f"Retained (μ=${retained.mean():.2f})")
        ax.hist(churned,  bins=30, alpha=0.6, color=CORAL, label=f"Churned  (μ=${churned.mean():.2f})")
        ax.axvline(churned.mean(),  color=CORAL, linestyle="--", linewidth=1.5)
        ax.axvline(retained.mean(), color=TEAL,  linestyle="--", linewidth=1.5)
        ax.set_title("Monthly Charges — Churned vs Retained", fontsize=14, fontweight="bold", pad=12)
        ax.set_xlabel("Monthly Charges ($)")
        ax.set_ylabel("Customer Count")
        ax.legend()
        self._save(fig, "04_monthly_charges_dist.png")

    # ── 5: ROC curves (called with model results) ─────────────────
    def plot_roc_curves(self, models: dict, X_test, y_test):
        fig, ax = plt.subplots(figsize=(8, 6))
        for (name, model), color in zip(models.items(), COLORS):
            proba = model.predict_proba(X_test)[:, 1]
            fpr, tpr, _ = roc_curve(y_test, proba)
            score = auc(fpr, tpr)
            ax.plot(fpr, tpr, color=color, linewidth=2, label=f"{name} (AUC={score:.3f})")
        ax.plot([0,1],[0,1], "k--", linewidth=1)
        ax.set_title("ROC Curves — Model Comparison", fontsize=14, fontweight="bold", pad=12)
        ax.set_xlabel("False Positive Rate")
        ax.set_ylabel("True Positive Rate")
        ax.legend(loc="lower right")
        self._save(fig, "05_roc_curves.png")

    # ── 6: Feature importance (Random Forest) ─────────────────────
    def plot_feature_importance(self, model, feature_names=None, top_n=15):
        if not hasattr(model, "feature_importances_"):
            return
        imp = model.feature_importances_
        if feature_names is None:
            feature_names = [f"f{i}" for i in range(len(imp))]
        series = pd.Series(imp, index=feature_names).nlargest(top_n)
        fig, ax = plt.subplots(figsize=(9, 6))
        series[::-1].plot.barh(ax=ax, color=TEAL, edgecolor="white")
        ax.set_title(f"Top {top_n} Feature Importances", fontsize=14, fontweight="bold", pad=12)
        ax.set_xlabel("Importance Score")
        self._save(fig, "06_feature_importance.png")

    # ── helper ────────────────────────────────────────────────────
    def _save(self, fig, name: str):
        path = self.out / name
        fig.tight_layout()
        fig.savefig(path, dpi=150, bbox_inches="tight")
        plt.close(fig)
        logger.info(f"  Saved chart: {path.name}")
