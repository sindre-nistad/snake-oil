import math

import colorcet as cc
import numpy as np

from mandelbrot.domain import ColorMap


class Colors:
    def __init__(self, name: str):
        self._name = ""
        self.map = []
        self.name = name
        self.possible_colors = cc.all_original_names(group="linear")

    @property
    def name(self):
        return self._name

    @name.setter
    def name(self, value):
        self.map = self.get_colormap(value)
        self._name = value

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
