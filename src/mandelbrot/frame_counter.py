from pathlib import Path

import numpy as np
import pygame


class FrameCounter:
    def __init__(self, screen: pygame.Surface):
        self.screen = screen
        self.clock = pygame.time.Clock()
        self.info = pygame.rect.Rect(0, 0, 100, 30)
        self.font = pygame.font.Font(
            Path(__file__).parent
            / "assets"
            / "fonts"
            / "liberation_sans"
            / "LiberationSans.ttc",
            24,
        )
        self._num_pixes = self.info.width * self.info.height

    def update(self):
        colors = pygame.surfarray.pixels3d(self.screen.subsurface(self.info).copy())
        average_color = (colors.sum(axis=(0, 1)) / self._num_pixes).astype(np.uint8)
        color = np.array([255, 255, 255], dtype=np.uint8) - average_color

        dt = self.clock.tick() / 1000
        self.screen.blit(
            self.font.render(f"{1 / dt:.2f} fps" if dt < 1 else f"{dt} spf", 1, color),
            self.info,
        )
        pygame.display.update()
