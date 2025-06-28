from pathlib import Path

import pygame


class FrameCounter:
    def __init__(self, screen: pygame.Surface):
        self.screen = screen
        self.clock = pygame.time.Clock()
        self.info = pygame.rect.Rect(0, 0, 400, 100)
        self.font = pygame.font.Font(
            Path(__file__).parent
            / "assets"
            / "fonts"
            / "liberation_sans"
            / "LiberationSans.ttc",
            24,
        )

    def update(self):
        dt = self.clock.tick(60) / 1000
        self.screen.blit(
            self.font.render(
                f"{1 / dt:.2f} fps" if dt < 1 else f"{dt} spf", 1, (255, 255, 255)
            ),
            self.info,
        )
        pygame.display.update()
