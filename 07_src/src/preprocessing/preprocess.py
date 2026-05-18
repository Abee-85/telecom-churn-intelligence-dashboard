
import logging
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing   import StandardScaler

logger = logging.getLogger(__name__)


class Preprocessor:
    def __init__(self, df: pd.DataFrame, cfg):
        self.df  = df.copy()
        self.cfg = cfg
        self.scaler = StandardScaler()

    def run(self):
        """Full preprocessing pipeline → (X_train, X_test, y_train, y_test)."""
        df = self._encode_binary(self.df)
        df = self._encode_gender(df)
        df = self._one_hot(df)
        df = self._drop_unused(df)
        X, y = self._split_xy(df)
        X_scaled = self._scale(X)
        return self._train_test(X_scaled, y)

    # ── steps ──────────────────────────────────────────────────────
    def _encode_binary(self, df):
        """Yes/No → 1/0 for binary columns."""
        for col in self.cfg.BINARY_COLS:
            if col in df.columns:
                df[col] = df[col].map({"Yes": 1, "No": 0})
        return df

    def _encode_gender(self, df):
        if "gender" in df.columns:
            df["gender"] = df["gender"].map({"Male": 1, "Female": 0})
        return df

    def _one_hot(self, df):
        """One-hot encode multi-class categorical features."""
        cats = [c for c in self.cfg.CAT_COLS if c in df.columns]
        df = pd.get_dummies(df, columns=cats, drop_first=False)
        df = df.fillna(0)   # fill any NaN from dummies
        logger.info(f"  After encoding: {df.shape[1]} columns")
        return df

    def _drop_unused(self, df):
        drop = [c for c in self.cfg.DROP_COLS if c in df.columns]
        df.drop(columns=drop, inplace=True, errors="ignore")
        return df

    def _split_xy(self, df):
        X = df.drop(columns=[self.cfg.TARGET_COL])
        y = df[self.cfg.TARGET_COL]
        return X, y

    def _scale(self, X):
        numeric = X.select_dtypes(include=[np.number]).columns.tolist()
        X[numeric] = self.scaler.fit_transform(X[numeric])
        return X

    def _train_test(self, X, y):
        return train_test_split(
            X, y,
            test_size    = self.cfg.TEST_SIZE,
            random_state = self.cfg.RANDOM_STATE,
            stratify     = y,
        )
