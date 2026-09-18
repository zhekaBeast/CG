#include "common.h"


void body_init(Body *b, float x, float y, float vx, float vy,
               float g, float mass, float impulse, float side) {
    b->x = x;
    b->y = y;
    b->vx = vx;
    b->vy = vy;
    b->g = g;
    b->mass = mass;
    b->impulse = impulse;
    triangle_init(&b->tri, x, y, side);
}

/* Обновление состояния фигуры за dt */
void body_update(Body *b, float dt) {
    /* Движение с гравитацией */
    b->vy += b->g * dt;
    b->x  += b->vx * dt;
    b->y  += b->vy * dt;

    /* Переносим центр в треугольник */
    b->tri.cx = b->x;
    b->tri.cy = b->y;

    /* Отскок от границ (простая модель: по осям) */
    {
        Point w[3];
        int i;
        triangle_world(&b->tri, w);

        for (i = 0; i < 3; i++) {
            if (w[i].x < 0) {
                b->x += (0 - w[i].x);
                b->vx = -b->vx + b->impulse / b->mass;
                break;
            }
            if (w[i].x >= SCREEN_W) {
                b->x -= (w[i].x - (SCREEN_W - 1));
                b->vx = -b->vx + b->impulse / b->mass;
                break;
            }
        }
        for (i = 0; i < 3; i++) {
            if (w[i].y < 0) {
                b->y += (0 - w[i].y);
                b->vy = -b->vy + b->impulse / b->mass;
                break;
            }
            if (w[i].y >= SCREEN_H) {
                b->y -= (w[i].y - (SCREEN_H - 1));
                b->vy = -b->vy + b->impulse / b->mass;
                break;
            }
        }
    }

    /* Постепенное вращение (ДЗ.Б1) */
    triangle_rotate(&b->tri, 0.02f);
}