import math
from pathlib import Path

import colorcet as cc
import numpy as np

from mandelbrot.domain import ColorMap


def _get_project_root():
    path = Path(__file__)
    while not (path / "pyproject.toml").exists() and path != path.anchor:
        path = path.parent
    if path == path.anchor:
        raise ValueError("Could not find the project root")
    return path


class StoredColor:
    LOCATION = _get_project_root() / ".mandelbrot-color.txt"

    @classmethod
    def loads(cls):
        with open(cls.LOCATION) as f:
            return f.read().strip()

    @classmethod
    def dumps(cls, color: str):
        with open(cls.LOCATION, "w") as f:
            f.write(color)


class Colors:
    def __init__(self, name: str | None = None):
        self._name = ""
        self.map = []
        if name is None:
            try:
                name = StoredColor.loads()
            except FileNotFoundError:
                # Default color if none have been stored
                name = "linear_kryw_0_100_c71"  # alias: fire
        self.name = name
        self.possible_colors = cc.all_original_names(group="linear")

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, value):
        self.map = self.get_colormap(value)
        self._name = value
        StoredColor.dumps(value)

    def next(self):
        self._change_color(1)

    def previous(self):
        self._change_color(-1)

    def _change_color(self, direction: int):
        next_color = (self.possible_colors.index(self.name) + direction) % len(
            self.possible_colors
        )
        self.name = self.possible_colors[next_color]

    @staticmethod
    def get_colormap(name: str) -> ColorMap:
        mpl_colors = getattr(cc, name)
        colors = np.zeros((len(mpl_colors), 3), dtype=np.uint8)
        for idx, color in enumerate(mpl_colors):
            colors[idx, :] = [math.floor(channel * 255) for channel in color]
        return colors
