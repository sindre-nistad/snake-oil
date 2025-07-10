import pygame

from mandelbrot.colors import Colors


class InteractionState:
    @property
    def width(self):
        return self.screen.get_width()

    @property
    def height(self):
        return self.screen.get_height()

    @property
    def aspect_ratio(self) -> float:
        return self.width / self.height

    def ranges(self) -> tuple[tuple[float, float], tuple[float, float]]:
        x_center, y_center = self.center
        # Our scaling assumes a square (we don't use separate scaling for the x- and y-axis)
        # To ensure the fractal is not stretched, we adjust the y-axis
        ratio = 1 / self.aspect_ratio
        x_range = (x_center - self.size / 2, x_center + self.size / 2)
        y_range = (
            (y_center - self.size / 2) * ratio,
            (y_center + self.size / 2) * ratio,
        )
        return x_range, y_range

    def mouse_direction(self) -> pygame.Vector2:
        mouse_x, mouse_y = pygame.mouse.get_pos()
        width, height = self.width, self.height
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

    def __init__(self, screen: pygame.Surface):
        self.screen = screen

        self.running = True

        self.color = Colors()

        # The (mathematical) center of the screen
        self.center = pygame.Vector2(-1, 0)
        # The (mathematical) with of the screen
        self.size = 2
        self.zoom_factor = 1.2

        self.cutoff = 10

        self.detail_scale = 1.3

    def handle_events(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.running = False
            elif event.type == pygame.MOUSEMOTION:
                left, middle, right = event.buttons
                if left:
                    x_range, y_range = self.ranges()
                    diff = pygame.Vector2(
                        x=event.rel[0] / self.width * (x_range[1] - x_range[0]),
                        y=event.rel[1]
                        / self.height
                        * (y_range[1] - y_range[0])
                        * self.aspect_ratio,
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

                diff = mouse_position_before_zoom - mouse_position_after_zoom
                diff.y *= self.aspect_ratio
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
        if keys[pygame.K_c]:
            if keys[pygame.K_LSHIFT]:
                self.color.previous()
            else:
                self.color.next()
