import math
from functools import lru_cache

import pygame
import numpy as np
import numpy.typing as npt
import colorcet as cc


@lru_cache(maxsize=1)
def _reverse_color_aliases():
    alias_mapping = {}
    for name, aliases in cc.aliases.items():
        for alias in aliases:
            alias_mapping[alias] = name
    return alias_mapping


def get_colormap(name: str) -> npt.NDArray[np.uint8]:
    mpl_colors = getattr(cc, _reverse_color_aliases()[name])
    colors = np.zeros((len(mpl_colors), 3), dtype=np.uint8)
    for idx, color in enumerate(mpl_colors):
        colors[idx, :] = [math.floor(channel * 255) for channel in color]
    return colors


def mandelbrot(x: float, y: float, cutoff: int) -> int:
    """Compute the margins of the mandelbrot set"""
    z = 0 + 0j
    c = x + y * 1j
    iterations = 0
    while iterations < cutoff and abs(z) <= 2:
        z = z**2 + c
        iterations += 1
    # The first iteration could be considered the zeroth, as z will always be 0
    # in that iteration, so the loop will be executed at least once.
    return iterations - 1


def compute_mandelbrot(
    width: int, height: int, x: tuple[float, float], y: tuple[float, float], cutoff: int
) -> npt.NDArray[np.uint32]:
    divergence = np.zeros((width, height), dtype=np.uint32)
    x_scale = abs(x[0] - x[1]) / width
    y_scale = abs(y[0] - y[1]) / height

    for i in range(width):
        for j in range(height):
            divergence[i, j] = mandelbrot(
                x[0] + i * x_scale, y[0] + j * y_scale, cutoff
            )
    return divergence


def apply_colormap(
    divergence: np.array,
    cutoff: int,
    colormap: list[tuple[float, float, float]]
    | npt.NDArray[tuple[float, float, float]],
):
    color_index = (divergence / cutoff * len(colormap)).astype(np.uint32)
    n, m = divergence.shape
    pixels = np.zeros((n, m, 3), dtype=np.uint8)
    for i in range(n):
        for j in range(m):
            pixels[i, j, :] = colormap[color_index[i, j]]
    return pixels


class Mandelbrot:
    def ranges(self) -> tuple[tuple[float, float], tuple[float, float]]:
        x_center, y_center = self.center
        width, height = self.screen.get_width(), self.screen.get_height()
        ratio = height / width
        x_range = (x_center - self.size / 2, x_center + self.size / 2)
        y_range = (
            (y_center - self.size / 2) * ratio,
            (y_center + self.size / 2) * ratio,
        )
        return x_range, y_range

    def mouse_direction(self) -> pygame.Vector2:
        mouse_x, mouse_y = pygame.mouse.get_pos()
        width, height = self.screen.get_width(), self.screen.get_height()
        return pygame.Vector2(
            x=(mouse_x - width / 2) / width,
            y=(mouse_y - height / 2) / height,
        )

    def mouse_position(self) -> pygame.Vector2:
        direction = self.mouse_direction()
        x_range, y_range = self.ranges()
        return pygame.Vector2(
            x=direction.x * (x_range[1] - x_range[0]),
            y=direction.y * (y_range[1] - y_range[0]),
        )

    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((1280, 720))
        pygame.display.set_caption("Mandelbrot")

        self.clock = pygame.time.Clock()
        self.running = True

        self.colors = get_colormap("fire")
        self.font = pygame.sysfont.SysFont("helveticaneue", 24)

        # The (mathematical) center of the screen
        self.center = pygame.Vector2(-1, 0)
        # The (mathematical) with of the screen
        self.size = 2
        self.zoom_factor = 1.2

        self.cutoff = 10

        self.detail_scale = 1.3
        self.info = pygame.rect.Rect(0, 0, 400, 100)

    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            elif event.type == pygame.MOUSEMOTION:
                left, middle, right = event.buttons
                if left:
                    x_range, y_range = self.ranges()
                    diff = pygame.Vector2(
                        x=event.rel[0]
                        / self.screen.get_width()
                        * (x_range[1] - x_range[0]),
                        y=event.rel[1]
                        / self.screen.get_height()
                        * (y_range[1] - y_range[0]),
                    )
                    self.center -= diff
            elif event.type == pygame.MOUSEWHEEL:
                mouse_position_before_zoom = self.mouse_position()
                if event.precise_y < 0:
                    # Zoom out
                    self.size *= self.zoom_factor
                else:
                    # Zoom in
                    self.size /= self.zoom_factor
                mouse_position_after_zoom = self.mouse_position()

                diff = (
                    mouse_position_before_zoom - mouse_position_after_zoom
                ) * self.zoom_factor
                self.center += diff

        keys = pygame.key.get_pressed()
        if keys[pygame.K_PLUS] or keys[pygame.K_KP_PLUS]:
            # Increase 'resolution'
            self.cutoff = max(int(self.cutoff * self.detail_scale), self.cutoff + 1)
        if keys[pygame.K_MINUS] or keys[pygame.K_KP_MINUS]:
            # Decrease 'resolution'
            self.cutoff = max(
                2, min(int(self.cutoff / self.detail_scale), self.cutoff - 1)
            )

    def start(self):
        while self.running:
            self.handle_events()

            x_range, y_range = self.ranges()
            divergence = compute_mandelbrot(
                self.screen.get_width(),
                self.screen.get_height(),
                x_range,
                y_range,
                self.cutoff,
            )

            pixels = apply_colormap(divergence, self.cutoff, self.colors)
            pygame.surfarray.blit_array(self.screen, pixels)

            # flip() the display to put your work on screen
            pygame.display.flip()

            dt = self.clock.tick(60) / 1000
            self.screen.blit(
                self.font.render(
                    f"{1 / dt:.2f} fps" if dt < 1 else f"{dt} spf", 1, (255, 255, 255)
                ),
                self.info,
            )
            pygame.display.update()

        pygame.quit()


def run():
    app = Mandelbrot()
    app.start()


if __name__ == "__main__":
    run()
