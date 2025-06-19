from abc import ABC, abstractmethod
from typing import TypeAlias

import numpy as np
import numpy.typing as npt

ColorMap: TypeAlias = (
    list[tuple[float, float, float]] | npt.NDArray[tuple[float, float, float]]
)

Pixels: TypeAlias = npt.NDArray[np.uint8]


class MandelbrotComputerInterface(ABC):
    @abstractmethod
    def compute(
        self,
        width: int,
        height: int,
        x_range: tuple[float, float],
        y_range: tuple[float, float],
        cutoff: int,
        colors: ColorMap,
    ) -> Pixels: ...
