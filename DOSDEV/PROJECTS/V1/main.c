#include <dos.h>
#include "a1.h"
#include "b1.h"
#include "v5.h"
#include "e3.h"
#include "common.h"

int main(void)
{
 Body body;
 unsigned long last_tick;
 int fps = 60;
 int view_w = SCREEN_W;
 int view_h = SCREEN_H;
 int running = 1;

 /* Инициализация графики */
 set_video_mode_13h();
 set_palette();

 /* Инициализация фигуры */
 body_init(&body,
           160.0f, 100.0f, /* позиция */
           2.0f, -3.0f,    /* начальная скорость */
           0.15f,          /* гравитация */
           1.0f,           /* масса */
           1.5f,           /* импульс при отскоке */
           20.0f);         /* сторона треугольника */

 last_tick = get_ticks();

 while (running)
 {
  int key;

  /* 1. Обновление состояния (ДЗ.В5 + ДЗ.Б1) */
  body_update(&body, 1.0f);

  /* 2. Очистка заднего буфера (ДЗ.Е3) */
  clear_back_buffer(0);

  /* 3. Отрисовка в задний буфер (ДЗ.А1 + ДЗ.Б1) */
  {
   Point w[3];
   triangle_world(&body.tri, w);
   fill_triangle(w[0], w[1], w[2], 15);
  }

  /* 4. Перенос заднего буфера на экран (ДЗ.Е3) */
  blit_back_buffer(view_w, view_h);

  /* 5. Обработка клавиш (ДЗ.Е3) */
  key = read_key();
  if (key == 27)
  { /* Esc */
   running = 0;
  }
  else if (key == '+' || key == '=')
  {
   if (fps < 120)
    fps += 15;
  }
  else if (key == '-' || key == '_')
  {
   if (fps > 15)
    fps -= 15;
  }
  else if (key == '[')
  {
   if (view_w > 80)
    view_w -= 40;
   if (view_h > 50)
    view_h -= 25;
  }
  else if (key == ']')
  {
   if (view_w < SCREEN_W)
    view_w += 40;
   if (view_h < SCREEN_H)
    view_h += 25;
  }

  /* 6. Ограничение FPS (ДЗ.Е3) */
  wait_frame(&last_tick, fps);
 }

 /* Возврат в текстовый режим */
 set_video_mode_03h();
 return 0;
}