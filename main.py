"""
Telecom Customer Churn Intelligence Dashboard
=============================================
Pipeline entry point — orchestrates ETL, preprocessing,
model training, evaluation, and visualisation.

Usage:
    python main.py
    python main.py --skip-train    (load saved models)
    python main.py --data <path>   (custom CSV path)

Author : MCA Final Project
Dataset: IBM Watson Analytics Telco Customer Churn (7,043 records)
"""

import sys
import time
import argparse
import logging
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent / "src"))

from utils.config       import Config
from utils.logger       import setup_logger
from etl.extract        import DataExtractor
from etl.transform      import DataTransformer
from etl.load           import DataLoader
from preprocessing.preprocess import Preprocessor
from prediction.train_model   import ModelTrainer
from visualization.charts     import ChurnVisualizer

BANNER = """
╔══════════════════════════════════════════════════════════════╗
║   TELECOM CUSTOMER CHURN INTELLIGENCE DASHBOARD             ║
║   IBM Telco Dataset  ·  7,043 records  ·  21 features       ║
╚══════════════════════════════════════════════════════════════╝
"""

def parse_args():
    p = argparse.ArgumentParser(description="Churn Intelligence Pipeline")
    p.add_argument("--data",       default=None, help="Path to raw CSV (overrides config)")
    p.add_argument("--skip-train", action="store_true", help="Skip model training")
    p.add_argument("--log-level",  default="INFO", choices=["DEBUG","INFO","WARNING"])
    return p.parse_args()


def run_pipeline(args):
    cfg    = Config()
    logger = setup_logger("main", args.log_level)
    cfg.ensure_dirs()

    print(BANNER)
    t0 = time.time()

    # ── STEP 1: EXTRACT ───────────────────────────────────────────
    logger.info("STEP 1/5 ▶  Extracting data …")
    raw_path  = Path(args.data) if args.data else cfg.RAW_DATA_PATH
    extractor = DataExtractor(raw_path)
    df_raw    = extractor.load()
    logger.info(f"  Loaded {len(df_raw):,} rows · {df_raw.shape[1]} columns")

    # ── STEP 2: TRANSFORM ─────────────────────────────────────────
    logger.info("STEP 2/5 ▶  Transforming data …")
    transformer = DataTransformer(df_raw)
    df_clean    = transformer.run()
    logger.info(f"  Shape after transform: {df_clean.shape} · nulls: {df_clean.isnull().sum().sum()}")

    # ── STEP 3: LOAD ──────────────────────────────────────────────
    logger.info("STEP 3/5 ▶  Loading to warehouse …")
    loader = DataLoader(df_clean, cfg.DB_PATH)
    loader.run()

    # ── STEP 4: PREPROCESS + TRAIN ────────────────────────────────
    logger.info("STEP 4/5 ▶  Preprocessing for ML …")
    preprocessor = Preprocessor(df_clean, cfg)
    X_train, X_test, y_train, y_test = preprocessor.run()
    logger.info(f"  Train {X_train.shape[0]:,} · Test {X_test.shape[0]:,} · Features {X_train.shape[1]}")

    if not args.skip_train:
        logger.info("  Training 4 classifiers …")
        trainer = ModelTrainer(X_train, X_test, y_train, y_test, cfg)
        results = trainer.train_all()
        trainer.save_all()
        trainer.print_summary(results)
    else:
        logger.info("  --skip-train flag set; skipping training.")
        results = {}

    # ── STEP 5: VISUALISE ─────────────────────────────────────────
    logger.info("STEP 5/5 ▶  Generating charts …")
    viz = ChurnVisualizer(df_clean, cfg)
    viz.plot_churn_by_contract()
    viz.plot_churn_by_tenure()
    viz.plot_churn_by_payment()
    viz.plot_monthly_charges()
    logger.info(f"  Charts saved → {cfg.CHARTS_DIR}")

    elapsed = time.time() - t0
    logger.info(f"\n✅  Pipeline completed in {elapsed:.1f}s")
    logger.info(f"   Models  → {cfg.MODELS_DIR}")
    logger.info(f"   Charts  → {cfg.CHARTS_DIR}")
    logger.info(f"   DB      → {cfg.DB_PATH}")


if __name__ == "__main__":
    run_pipeline(parse_args())
