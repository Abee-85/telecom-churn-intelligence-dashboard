"""
Model Training
==============
Trains Logistic Regression, Decision Tree, Random Forest,
and Gradient Boosting classifiers. Evaluates each with
accuracy, precision, recall, F1, and AUC-ROC.
"""
import logging
import joblib
import numpy  as np
import pandas as pd
from pathlib import Path

from sklearn.linear_model  import LogisticRegression
from sklearn.tree          import DecisionTreeClassifier
from sklearn.ensemble      import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics       import (
    accuracy_score, precision_score, recall_score,
    f1_score, roc_auc_score, confusion_matrix,
)

logger = logging.getLogger(__name__)


class ModelTrainer:
    def __init__(self, X_train, X_test, y_train, y_test, cfg):
        self.X_train = X_train
        self.X_test  = X_test
        self.y_train = y_train
        self.y_test  = y_test
        self.cfg     = cfg
        self.models  = {}          # name → fitted model
        self.results = {}          # name → metrics dict

    # ── public API ────────────────────────────────────────────────
    def train_all(self) -> dict:
        definitions = {
            "Logistic Regression": LogisticRegression(
                solver="lbfgs", max_iter=1000, random_state=self.cfg.RANDOM_STATE
            ),
            "Decision Tree": DecisionTreeClassifier(
                random_state=self.cfg.RANDOM_STATE
            ),
            "Random Forest": RandomForestClassifier(
                n_estimators=100, random_state=self.cfg.RANDOM_STATE, n_jobs=-1
            ),
            "Gradient Boosting": GradientBoostingClassifier(
                n_estimators=100, learning_rate=0.1,
                max_depth=3, random_state=self.cfg.RANDOM_STATE
            ),
        }
        for name, model in definitions.items():
            logger.info(f"  Training {name} …")
            model.fit(self.X_train, self.y_train)
            self.models[name] = model
            self.results[name] = self._evaluate(model, name)
        return self.results

    def save_all(self):
        """Persist trained models as .pkl files."""
        out = Path(self.cfg.MODELS_DIR)
        out.mkdir(parents=True, exist_ok=True)
        for name, model in self.models.items():
            fname = name.lower().replace(" ", "_") + ".pkl"
            joblib.dump(model, out / fname)
            logger.info(f"  Saved {fname}")

    def get_best_model(self):
        """Return model with highest AUC-ROC score."""
        best = max(self.results, key=lambda n: self.results[n]["auc_roc"])
        return self.models[best]

    def print_summary(self, results: dict):
        print("\n" + "═"*70)
        print(f"{'MODEL':<25} {'ACC':>7} {'AUC':>7} {'PREC':>7} {'REC':>7} {'F1':>7}")
        print("─"*70)
        for name, m in results.items():
            star = " ⭐" if name == max(results, key=lambda n: results[n]["auc_roc"]) else ""
            print(f"{name+star:<25} {m['accuracy']:>6.2%} {m['auc_roc']:>6.2%} "
                  f"{m['precision']:>6.2%} {m['recall']:>6.2%} {m['f1']:>6.2%}")
        print("═"*70 + "\n")

    # ── private ────────────────────────────────────────────────────
    def _evaluate(self, model, name) -> dict:
        y_pred  = model.predict(self.X_test)
        y_proba = model.predict_proba(self.X_test)[:, 1]
        cm      = confusion_matrix(self.y_test, y_pred)
        metrics = {
            "accuracy" : accuracy_score(self.y_test, y_pred),
            "precision": precision_score(self.y_test, y_pred, zero_division=0),
            "recall"   : recall_score(self.y_test, y_pred, zero_division=0),
            "f1"       : f1_score(self.y_test, y_pred, zero_division=0),
            "auc_roc"  : roc_auc_score(self.y_test, y_proba),
            "cm"       : cm,
            "y_proba"  : y_proba,
        }
        logger.info(
            f"  {name}: acc={metrics['accuracy']:.4f} "
            f"auc={metrics['auc_roc']:.4f} "
            f"rec={metrics['recall']:.4f}"
        )
        return metrics
