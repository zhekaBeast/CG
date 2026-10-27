#ifndef _COMMON_H_
#define _COMMON_H_

#include <dos.h>

#define SCREEN_W 320
#define SCREEN_H 200

// работа с VGA (int10)
unsigned char far *VGA = (unsigned char far *)0xA0000000L;
extern unsigned char back_buffer[SCREEN_W * SCREEN_H];

//основные структуры
/* Точка */
typedef struct {
    float x;
    float y;
} Point;

/* Треугольник */
typedef struct {
    float cx, cy;        /* центр */
    float angle;         /* текущий угол поворота (рад) */
    float dangle;          /* угол изменения каждый кадр */
    float side;          /* длина стороны */
    Point v[3];          /* вершины (локальные, до поворота) */
} Triangle;

/* Движущаяся фигура */
typedef struct {
    Triangle tri;
    float x, y;          /* позиция центра */
    float vx, vy;        /* скорость */
    float g;             /* гравитация */
    float impulse;       /* импульс при отскоке */
    float mass;          /* масса */
} Body;

/* Установка режима VGA 13h */
void set_video_mode_13h(void) {
    union REGS r;
    r.h.ah = 0x00;
    r.h.al = 0x13;
    int86(0x10, &r, &r);
}

/* Возврат в текстовый режим 03h */
void set_video_mode_03h(void) {
    union REGS r;
    r.h.ah = 0x00;
    r.h.al = 0x03;
    int86(0x10, &r, &r);
}

/* Установка палитры (простая, 256 цветов) */
void set_palette(void) {
    union REGS r;
    r.h.ah = 0x10;
    r.h.al = 0x02;
    int86(0x10, &r, &r);
}

int read_key(void) {
    union REGS r;
    r.h.ah = 0x01;
    int86(0x16, &r, &r);
    if (r.x.flags & 0x40) return -1;   /* клавиша не нажата */
    r.h.ah = 0x00;
    int86(0x16, &r, &r);
    return r.h.al;
}

unsigned long get_ticks(void) {
    union REGS r;
    r.h.ah = 0x00;
    int86(0x1A, &r, &r);
    return ((unsigned long)r.x.cx << 16) | r.x.dx;
}

void wait_frame(unsigned long *last, int fps) {
    /* 18.2 тика в секунду — стандарт DOS */
    unsigned long ticks_per_frame = (unsigned long)(18.2 / fps);
    unsigned long now;
    do {
        now = get_ticks();
    } while ((now - *last) < ticks_per_frame);
    *last = now;
}

void put_pixel(int x, int y, unsigned char color) {
    if (x < 0 || x >= SCREEN_W || y < 0 || y >= SCREEN_H) return;
    back_buffer[y * SCREEN_W + x] = color;
}

void draw_line(int x0, int y0, int x1, int y1, unsigned char color) {
    int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
    int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    int err = dx - dy;

    while (1) {
        put_pixel(x0, y0, color);
        if (x0 == x1 && y0 == y1) break;
        {
            int e2 = 2 * err;
            if (e2 > -dy) { err -= dy; x0 += sx; }
            if (e2 <  dx) { err += dx; y0 += sy; }
        }
    }
}

void fill_triangle(Point a, Point b, Point c, unsigned char color) {
    /* MVP: только контур */
    draw_line((int)a.x, (int)a.y, (int)b.x, (int)b.y, color);
    draw_line((int)b.x, (int)b.y, (int)c.x, (int)c.y, color);
    draw_line((int)c.x, (int)c.y, (int)a.x, (int)a.y, color);
}



#endif