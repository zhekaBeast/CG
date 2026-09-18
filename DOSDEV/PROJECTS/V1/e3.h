#include "common.h"


unsigned char back_buffer[SCREEN_W * SCREEN_H];

void clear_back_buffer(unsigned char color) {
    int i;
    for (i = 0; i < SCREEN_W * SCREEN_H; i++) {
        back_buffer[i] = color;
    }
}

void blit_back_buffer(int width, int height) {
    int y;
    for (y = 0; y < height; y++) {
        unsigned char far *dst = VGA + y * SCREEN_W;
        unsigned char *src = back_buffer + y * SCREEN_W;
        int x;
        for (x = 0; x < width; x++) {
            dst[x] = src[x];
        }
    }
}