#include "common.h"
#include <dos.h>
#include <time.h>

int main(void)
{
 Body body;
 body_init(
     &body,
     160.0f, 100.0f, /* позиция */
     2.0f, -3.0f,    /* начальная скорость */
     0.1f,           /* гравитация */
     0.5f,           /* импульс при отскоке */
     20.0f,          /* сторона треугольника */
     0.1f,           /* скорость поворота */
     15              /* цвет */
 );
 gfx_init();
 while (handle_input())
 {
  update(&body); /* ОЗ.Р1: новое положение */
  wait_frame();
 }
 gfx_shutdown();
 return 0;
}