#ifndef COMMON_H
#define COMMON_H

#include <conio.h>
#include <time.h>
#include <dos.h>
#include <math.h>

#define VIDEO_SEG 0xA000
#define BLACK 0
#define WHITE 15
#define SCREEN_W 320
#define SCREEN_H 200
#define TOP_LIMIT 0
#define BOTTOM_LIMIT view_h
#define LEFT_LIMIT 0
#define RIGHT_LIMIT view_w
#define pixel(x, y, color) \
    do { \
        unsigned _px = (unsigned)(x); \
        unsigned _py = (unsigned)(y); \
        if (_px < view_w && _py < view_h) \
            vram[_py * SCREEN_W + _px] = (color); \
    } while (0)

static int view_w = SCREEN_W;
static int prev_view_w = SCREEN_W;
static int view_h = SCREEN_H;
static int prev_view_h = SCREEN_W;
static clock_t last_tick;
static int fps = 60;
unsigned char far *vram = (unsigned char far *)0;

// structures

/* Точка */
typedef struct
{
 float x;
 float y;
} Point;

/* Правильный треугольник */
typedef struct
{
 float angle;  /* текущий угол поворота (рад) */
 float dangle; /* скорость вращения угла */
 float side;   /* длина стороны */
 Point points[3];
} Triangle;

/* Движущаяся фигура */
typedef struct
{
 Triangle tri;
 Point pos;     /* местоположение */
 Point vel;     /* скорость */
 float g;       /* гравитация */
 float impulse; /* импульс при отскоке */
 unsigned char color;
} Body;

// common

static void triangle_init(Triangle *t, float dangle, float side)
{
 t->dangle = dangle;
 t->side = side;
}

static void draw_line(int x0, int y0, int x1, int y1, unsigned char color)
{
 int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
 int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
 int sx = (x0 < x1) ? 1 : -1;
 int sy = (y0 < y1) ? 1 : -1;
 int err = dx - dy;

 while (1)
 {
  pixel(x0, y0, color);
  if (x0 == x1 && y0 == y1)
   break;
  {
   int e2 = 2 * err;
   if (e2 > -dy)
   {
    err -= dy;
    x0 += sx;
   }
   if (e2 < dx)
   {
    err += dx;
    y0 += sy;
   }
  }
 }
}

static void fill_rect(int x0, int y0, int x1, int y1, unsigned char color)
{
    int x, y;
    if (x0 < 0) x0 = 0;
    if (y0 < 0) y0 = 0;
    if (x1 > SCREEN_W) x1 = SCREEN_W;
    if (y1 > SCREEN_H) y1 = SCREEN_H;
    for (y = y0; y < y1; y++)
    {
        unsigned char far *row = vram + (unsigned long)y * SCREEN_W;
        for (x = x0; x < x1; x++)
            row[x] = color;
    }
}

static void color_view(void)
{
    int w = view_w;
    int h = view_h;
    int pw = prev_view_w;
    int ph = prev_view_h;

    /* --- По горизонтали --- */
    if (w > pw)
    {
        /* окно расширилось: справа появилась новая зона — красим тёмным */
        fill_rect(pw, 0, w, h, BLACK);
    }
    else if (w < pw)
    {
        /* окно сузилось: полоса справа стала "вне окна" — красим белым */
        fill_rect(w, 0, pw, ph, WHITE);
    }

    /* --- По вертикали --- */
    if (h > ph)
    {
        /* окно выросло вниз: новая зона снизу — тёмным */
        fill_rect(0, ph, w, h, BLACK);
    }
    else if (h < ph)
    {
        /* окно сузилось по высоте: полоса снизу — белым */
        fill_rect(0, h, pw, ph, WHITE);
    }

    /* Запоминаем текущие размеры как предыдущие */
    prev_view_w = w;
    prev_view_h = h;
}



// math

// вычисление мировой точки правильного треугольника
static void tri_vertex(const Body *b, int i, float *out_x, float *out_y)
{
 float local = b->tri.angle + (float)(M_PI / 2.0) + (float)i * (float)(2.0 * M_PI / 3.0);
 float r = b->tri.side / sqrt(3.0f);
 float wx = b->pos.x + r * cos(local);
 float wy = b->pos.y + r * sin(local);
 *out_x = wx + 0.5f;
 *out_y = wy + 0.5f;
}

static int resolve_collision(Body *b)
{
 Point *w = b->tri.points;
 int hit = 0;
 int i;
 /* Ищем самые «выступающие» точки по каждой оси */
 float minX = w[0].x, maxX = w[0].x;
 float minY = w[0].y, maxY = w[0].y;
 for (i = 0; i < 3; i++)
 {
  if (w[i].x < minX)
   minX = w[i].x;
  if (w[i].x > maxX)
   maxX = w[i].x;
  if (w[i].y < minY)
   minY = w[i].y;
  if (w[i].y > maxY)
   maxY = w[i].y;
 }

 /* ---------- ГОРИЗОНТАЛЬНЫЕ СТЕНКИ: только зеркало, без импульса ---------- */
 if (minX < LEFT_LIMIT)
 {
  b->pos.x += (LEFT_LIMIT - minX); /* выталкиваем внутрь */
  b->vel.x = -b->vel.x;            /* отражение */
  hit |= 4;
 }
 else if (maxX > RIGHT_LIMIT)
 {
  b->pos.x -= (maxX - RIGHT_LIMIT);
  b->vel.x = -b->vel.x;
  hit |= 8;
 }

 /* ---------- ВЕРХ: зеркало, импульс опционален ---------- */
 if (minY < TOP_LIMIT)
 {
  b->pos.y += (TOP_LIMIT - minY);
  b->vel.y = 0;
  hit |= 1;
 }

 /* ---------- НИЗ: зеркало + импульс вверх ---------- */
 if (maxY > BOTTOM_LIMIT)
 {
  b->pos.y -= (maxY - BOTTOM_LIMIT);
  b->vel.y = -b->vel.y; /* отражение */

  /* Добавляем импульс ВВЕРХ.*/
  b->vel.y -= b->impulse;
  hit |= 2;
 }

 return hit;
}

static void draw_triangle(const Triangle *t, unsigned char color)
{
 int i;
 /* Три стороны треугольника */
 for (i = 0; i < 3; ++i)
 {
  int j = (i + 1) % 3;
  Point pa = t->points[i];
  Point pb = t->points[j];
  draw_line(pa.x, pa.y, pb.x, pb.y, color);
 }
}

static void update_parameters(Body *b)
{
 int i;
 // Гравитация
 b->vel.y += b->g;
 // Сдвиг центра
 b->pos.x += b->vel.x;
 b->pos.y += b->vel.y;
 // Вращение
 b->tri.angle += b->tri.dangle;
 // Вычисление новых точек
 for (i = 0; i < 3; i++)
  tri_vertex(b, i, &b->tri.points[i].x, &b->tri.points[i].y);
 // Меняем по колизиям векторы
 resolve_collision(b);
}

// публичные функции

void body_init(Body *b,
               float x, float y,
               float vx, float vy,
               float g, float impulse, float side,
               float dangle, unsigned char color)
{
 b->pos.x = x;
 b->pos.y = y;
 b->vel.x = vx;
 b->vel.y = vy;
 b->g = g;
 b->impulse = impulse;
 b->color = color;
 triangle_init(&b->tri, dangle, side);
}

void gfx_init(void)
{
 union REGS r;
 r.h.ah = 0x00; /* set video mode */
 r.h.al = 0x13; /* VGA 320x200x256 */
 int86(0x10, &r, &r);

 /* сегмент видеопамяти A000:0000 */
 vram = (unsigned char far *)MK_FP(VIDEO_SEG, 0);
 last_tick = clock();
}

void gfx_shutdown(void)
{
 union REGS r;
 r.h.ah = 0x00;
 r.h.al = 0x03; /* возврат в текстовый режим */
 int86(0x10, &r, &r);
}

void wait_frame(void)
{
 /* Сколько тиков должно пройти между кадрами (float!) */
 delay(1000/fps);
}

void update(Body *b)
{
 draw_triangle(&b->tri, BLACK);
 update_parameters(b);
 draw_triangle(&b->tri, b->color);
}

int handle_input(void)
{
 /* 5. Обработка клавиш (ДЗ.Е3) */
 int key;
 if (!kbhit()) /* нет нажатия — выходим */
  return 1;
 key = getch();
 switch (key)
 {
 case 27: // esc
  return 0;
 case '+': 
 case '=': 
  if (fps < 300)
   fps += 60;
  break;
 case '-':
 case '_':
  if (fps > 30)
   fps -= 30;
  break;
 case '[':
  if (view_w > 80)
   view_w -= 40;
  if (view_h > 50)
   view_h -= 25;
  color_view();
  break;
 case ']':
  if (view_w < SCREEN_W)
   view_w += 40;
  if (view_h < SCREEN_H)
   view_h += 25;
  color_view();
  break;
 default:
  break;
 }
 return 1;
}

#endif