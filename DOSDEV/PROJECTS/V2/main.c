#include <conio.h>
#include <dos.h>
#include <math.h>
#include <time.h>

#define VIDEO_SEG 0xA000
#define BLACK 0
#define WHITE 15
#define SCREEN_W 320
#define SCREEN_H 200
#define TOP_LIMIT 0
#define BOTTOM_LIMIT view_h
#define LEFT_LIMIT 0
#define RIGHT_LIMIT view_w
#define R_FACTOR 0.577350269f // 1/sqrt(3)
#define COS_TAB(i) sin_tab[((i) + 64) & 255]
#define SIN_TAB(i) sin_tab[(i) & 255]

static const int sin_tab[256] =
    {
        0, 6, 13, 19, 25, 31, 38, 44,
        50, 56, 62, 68, 74, 80, 86, 92,
        98, 104, 109, 115, 121, 126, 132, 137,
        142, 147, 152, 157, 162, 167, 171, 176,
        181, 185, 189, 193, 197, 201, 205, 209,
        212, 216, 219, 222, 225, 228, 231, 234,
        236, 239, 241, 243, 245, 247, 248, 250,
        251, 252, 253, 254, 254, 255, 255, 255,
        256, 255, 255, 255, 254, 254, 253, 252,
        251, 250, 248, 247, 245, 243, 241, 239,
        236, 234, 231, 228, 225, 222, 219, 216,
        212, 209, 205, 201, 197, 193, 189, 185,
        181, 176, 171, 167, 162, 157, 152, 147,
        142, 137, 132, 126, 121, 115, 109, 104,
        98, 92, 86, 80, 74, 68, 62, 56,
        50, 44, 38, 31, 25, 19, 13, 6,
        0, -6, -13, -19, -25, -31, -38, -44,
        -50, -56, -62, -68, -74, -80, -86, -92,
        -98, -104, -109, -115, -121, -126, -132, -137,
        -142, -147, -152, -157, -162, -167, -171, -176,
        -181, -185, -189, -193, -197, -201, -205, -209,
        -212, -216, -219, -222, -225, -228, -231, -234,
        -236, -239, -241, -243, -245, -247, -248, -250,
        -251, -252, -253, -254, -254, -255, -255, -255,
        -256, -255, -255, -255, -254, -254, -253, -252,
        -251, -250, -248, -247, -245, -243, -241, -239,
        -236, -234, -231, -228, -225, -222, -219, -216,
        -212, -209, -205, -201, -197, -193, -189, -185,
        -181, -176, -171, -167, -162, -157, -152, -147,
        -142, -137, -132, -126, -121, -115, -109, -104,
        -98, -92, -86, -80, -74, -68, -62, -56,
        -50, -44, -38, -31, -25, -19, -13, -6};

int view_w = SCREEN_W;
int prev_view_w = SCREEN_W;
int view_h = SCREEN_H;
int prev_view_h = SCREEN_W;
int fps = 60;
unsigned char far *vram = (unsigned char far *)0;

// structures
// Точка
typedef struct
{
 int x;
 int y;
} Point;

// Правильный треугольник
typedef struct
{
 int angle;  // текущий угол поворота (рад)
 int dangle; // скорость вращения угла
 int side;   // длина стороны
 Point points[3];
} Triangle;

// Движущаяся фигура
typedef struct
{
 Triangle tri;
 Point pos;   // местоположение
 Point vel;   // скорость
 int g;       // гравитация
 int impulse; // импульс при отскоке
} Body;

Body body;
//готово
void draw_line(int x0, int y0, int x1, int y1, unsigned char color)
{
 int dx = (x1 > x0) ? (x1 - x0) : (x0 - x1);
 int dy = (y1 > y0) ? (y1 - y0) : (y0 - y1);
 int sx = (x0 < x1) ? 1 : -1;
 int sy = (y0 < y1) ? 1 : -1;
 int err = dx - dy;

 while (1)
 {
  if (x0 < view_w && y0 < view_h)
   vram[y0 * SCREEN_W + x0] = color;
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
//готово
void fill_rect(int x0, int y0, int x1, int y1, unsigned char color)
{
 int x, y;
 if (x0 < 0)
  x0 = 0;
 if (y0 < 0)
  y0 = 0;
 if (x1 > SCREEN_W)
  x1 = SCREEN_W;
 if (y1 > SCREEN_H)
  y1 = SCREEN_H;
 for (y = y0; y < y1; y++)
 {
  unsigned char far *row = vram + (unsigned long)y * SCREEN_W;
  for (x = x0; x < x1; x++)
   row[x] = color;
 }
}
//готово
void color_view(void)
{
 int w = view_w;
 int h = view_h;
 int pw = prev_view_w;
 int ph = prev_view_h;

 // --- По горизонтали ---
 if (w > pw)
 {
  // окно расширилось: справа появилась новая зона — красим тёмным
  fill_rect(pw, 0, w, h, BLACK);
 }
 else if (w < pw)
 {
  // окно сузилось: полоса справа стала "вне окна" — красим белым
  fill_rect(w, 0, pw, ph, WHITE);
 }

 // --- По вертикали ---
 if (h > ph)
 {
  // окно выросло вниз: новая зона снизу — тёмным
  fill_rect(0, ph, w, h, BLACK);
 }
 else if (h < ph)
 {
  // окно сузилось по высоте: полоса снизу — белым
  fill_rect(0, h, pw, ph, WHITE);
 }

 // Запоминаем текущие размеры как предыдущие
 prev_view_w = w;
 prev_view_h = h;
}

// math

// готово
void resolve_collision(void)
{
 int i;
 Point *w = body.tri.points;
 int minX = w[0].x, maxX = w[0].x;
 int minY = w[0].y, maxY = w[0].y;
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
 if (minX < LEFT_LIMIT)
 {
  body.pos.x += (LEFT_LIMIT - minX); // выталкиваем внутрь
  body.vel.x = -body.vel.x;          // отражение
 }
 else if (maxX > RIGHT_LIMIT)
 {
  body.pos.x -= (maxX - RIGHT_LIMIT);
  body.vel.x = -body.vel.x;
 }
 if (minY < TOP_LIMIT)
 {
  body.pos.y += (TOP_LIMIT - minY);
  body.vel.y = 0;
 }
 else if (maxY > BOTTOM_LIMIT)
 {
  body.pos.y -= (maxY - BOTTOM_LIMIT);
  body.vel.y = -body.vel.y; // отражение
  body.vel.y -= body.impulse;
 }
}
// готово
void draw_triangle(unsigned char color)
{
 int i;
 const Triangle *t = &body.tri;
 // Три стороны треугольника
 for (i = 0; i < 3; ++i)
 {
  int j = (i + 1) % 3;
  Point pa = t->points[i];
  Point pb = t->points[j];
  draw_line(pa.x, pa.y, pb.x, pb.y, color);
 }
}

int handle_input(void)
{
 // 5. Обработка клавиш (ДЗ.Е3)
 int key;
 if (!kbhit()) // нет нажатия — выходим
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
// готово
void gfx_init(void)
{
 union REGS r;
 r.h.ah = 0x00; // set video mode
 r.h.al = 0x13; // VGA 320x200x256
 int86(0x10, &r, &r);
 // сегмент видеопамяти A000:0000
 vram = (unsigned char far *)MK_FP(VIDEO_SEG, 0);
}
// готово
void gfx_shutdown(void)
{
 union REGS r;
 r.h.ah = 0x00;
 r.h.al = 0x03; // возврат в текстовый режим
 int86(0x10, &r, &r);
}

int main(void)
{
int i;
int r_factor;
int angle_idx;
int local_idx;
 body.pos.x = 160;
 body.pos.y = 100;
 body.vel.x = 2;
 body.vel.y = -3;
 body.g = 1;
 body.impulse = 1;
 body.tri.dangle = 10;
 body.tri.side = 20;

 gfx_init();
 while (handle_input())
 {
  draw_triangle(BLACK);
  // сила тяжести
  body.vel.y += body.g;
  // Сдвиг центра
  body.pos.x += body.vel.x;
  body.pos.y += body.vel.y;
  // Вращение
  body.tri.angle += body.tri.dangle;
  // Вычисление новых точек
  r_factor = (body.tri.side * 148) >> 8;
  angle_idx = body.tri.angle & 255;
  for (i = 0; i < 3; i++)
  {
   local_idx = (angle_idx + 64 + i * 85) & 255; // 85 ≈ 256/3
   body.tri.points[i].x = body.pos.x + ((r_factor * sin_tab[(local_idx + 64) & 255]) >> 8);
   body.tri.points[i].y = body.pos.y + ((r_factor * sin_tab[local_idx]) >> 8);
  }
  // Меняем по колизиям векторы
  resolve_collision();
  draw_triangle(WHITE);

  delay(1000 / fps);
 }
 gfx_shutdown();

 return 0;
}