import pygame

from mandelbrot.domain import MandelbrotComputerInterface, Pixels
from mandelbrot.frame_counter import FrameCounter
from mandelbrot.state import InteractionState


class Mandelbrot:
    def __init__(self):
        pygame.init()
        self.screen = pygame.display.set_mode((1280, 720))
        pygame.display.set_caption("Mandelbrot")

        self.state = InteractionState(self.screen)

        self.frame_counter = FrameCounter(self.screen)

    def start(self, mandelbrot_computer: MandelbrotComputerInterface):
        while self.state.running:
            self.state.handle_events()

            x_range, y_range = self.state.ranges()
            pixels = mandelbrot_computer.compute(
                self.screen.get_width(),
                self.screen.get_height(),
                x_range,
                y_range,
                self.state.cutoff,
                self.state.color.map,
            )

            self.update_screen(pixels)

            self.frame_counter.update()

        pygame.quit()

    def update_screen(self, pixels: Pixels) -> None:
        pygame.surfarray.blit_array(self.screen, pixels)
        # flip() the display to put your work on screen
        pygame.display.flip()


def run():
    from mandelbrot.implementations.nvidia_cuda import MandelbrotComputer

    app = Mandelbrot()
    app.start(MandelbrotComputer())


if __name__ == "__main__":
    run()
