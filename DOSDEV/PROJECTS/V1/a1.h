#include <math.h>
#include "common.h"

#define PI 3.14159265358979323846f

/* Инициализация равностороннего треугольника */
void triangle_init(Triangle *t, float cx, float cy, float side) {
    int i;
    t->cx = cx;
    t->cy = cy;
    t->angle = 0.0f;
    t->side = side;

    /* Вершины равностороннего треугольника в локальных координатах */
    for (i = 0; i < 3; i++) {
        float a = (float)(2.0 * PI * i / 3.0);
        t->v[i].x = side * (float)cos(a);
        t->v[i].y = side * (float)sin(a);
    }
}

/* Поворот вершины относительно центра (ДЗ.Б1) */
void triangle_rotate(Triangle *t, float dangle) {
    int i;
    float c = (float)cos(dangle);
    float s = (float)sin(dangle);
    t->angle += dangle;
    for (i = 0; i < 3; i++) {
        float x = t->v[i].x;
        float y = t->v[i].y;
        t->v[i].x = x * c - y * s;
        t->v[i].y = x * s + y * c;
    }
}

/* Получить мировые координаты вершин */
void triangle_world(const Triangle *t, Point out[3]) {
    int i;
    for (i = 0; i < 3; i++) {
        out[i].x = t->cx + t->v[i].x;
        out[i].y = t->cy + t->v[i].y;
    }
}