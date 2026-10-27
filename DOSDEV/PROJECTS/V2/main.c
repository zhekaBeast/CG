#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <dos.h>

#define VIEW_W 320
#define VIEW_H 200
#define PUT_PIXEL_VGA(x, y, color)                    \
 do                                                   \
 {                                                    \
  if ((x) >= 0 && (x) < 320 && (y) >= 0 && (y) < 200) \
  {                                                   \
   vga[(y) * 320 + (x)] = (color);                    \
  }                                                   \
 } while (0)
#define CLEAR_SCREEN_VGA(color) _fmemset(vga, color, 320 * 200);

/* =========================================================
 * 1. СТРУКТУРЫ И ГЛОБАЛЬНЫЕ БУФЕРЫ
 * ========================================================= */

/* Блок "Содержание" */
typedef struct
{
 unsigned long file_size;      // Размер всего контейнера (байт)
 unsigned long palette_offset; // Смещение до палитры
 unsigned long pixels_offset;  // Смещение до пикселей
} Content;

/* Блок "Заголовок" */
typedef struct
{
 char signature[4];           // "QBT1"
 unsigned short width;        // Ширина растра
 unsigned short height;       // Высота растра
 unsigned short palette_size; // Количество элементов палитры (от 4 до 8)
 unsigned short mix_bits;     // Точность коэффициента t (от 3 до 5)
} Header;

/* Блок "Палитра" */
typedef struct
{
 unsigned char r, g, b;
} RGB24;

typedef struct
{
 Content content;
 Header header;
} QBT1_FileHeader;

// Прямой доступ к видеопамяти
unsigned char far *vga;

// Глобальные переменные
Header current_header;
QBT1_FileHeader current_file_header;
RGB24 current_palette[8];
int p_bytes = 0;
/* Добавь в глобальные переменные */
unsigned char line_buffer[640]; // максимальный вес строки - 640 байт
FILE *current_file = NULL;
long total_pixels;
/* =========================================================
 * 2. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
 * ========================================================= */

void set_video_mode(unsigned char mode)
{
 union REGS regs;
 regs.h.ah = 0x00;
 regs.h.al = mode;
 int86(0x10, &regs, &regs);
}

// Функция декодирования ОДНОГО пикселя
unsigned char decode_pixel(unsigned char *pixel_data)
{
 unsigned short p = 0;
 unsigned char i1, i2, t;
 int i_bits, t_bits;
 RGB24 c1, c2;
 int r, g, b, t_scaled;
 unsigned char vga_color;

 if (current_header.palette_size <= 2)
  i_bits = 1;
 else if (current_header.palette_size <= 4)
  i_bits = 2;
 else
  i_bits = 3;

 t_bits = current_header.mix_bits;

 if (p_bytes == 1)
 {
  p = pixel_data[0];
 }
 else
 {
  p = pixel_data[0] | (pixel_data[1] << 8); // Little Endian
 }

 t = p & ((1 << t_bits) - 1);
 i1 = (p >> t_bits) & ((1 << i_bits) - 1);
 i2 = (p >> (t_bits + i_bits)) & ((1 << i_bits) - 1);

 c1 = current_palette[i1];
 c2 = current_palette[i2];

 t_scaled = (t * 255) / ((1 << t_bits) - 1);

 r = (c1.r * (255 - t_scaled) + c2.r * t_scaled) / 255;
 g = (c1.g * (255 - t_scaled) + c2.g * t_scaled) / 255;
 b = (c1.b * (255 - t_scaled) + c2.b * t_scaled) / 255;

 vga_color = (r & 0xE0) | ((g & 0xE0) >> 3) | ((b & 0xC0) >> 6);

 return vga_color;
}

/* =========================================================
 * 3. CREATE
 * ========================================================= */
void create_image(void)
{
 // ... (код создания оставляем без изменений, он работает) ...
 char filename[100];
 int w, h, palette_size, t_bits;
 RGB24 pal[8];
 int b;
 long i;
 FILE *f;
 QBT1_FileHeader fh;
 int i_bits, pixel_bits;
 char input[100];
 int r, g, bl;

 printf("\n--- Create New QBT1 File ---\n");

 while (1)
 {
  printf("Enter filename: ");
  gets(input);
  if (strcmp(input, "cancel") == 0)
   return;
  if (strlen(input) == 0)
  {
   printf("Error: Empty name.\n");
   continue;
  }
  strcpy(filename, input);
  break;
 }

 while (1)
 {
  printf("Enter width (1..320): ");
  gets(input);
  w = atoi(input);
  if (w > 0 && w <= 320)
   break;
  printf("Error: 1..320.\n");
 }

 while (1)
 {
  printf("Enter height (1..200): ");
  gets(input);
  h = atoi(input);
  if (h > 0 && h <= 200)
   break;
  printf("Error: 1..200.\n");
 }

 while (1)
 {
  printf("Enter palette size (2..8): ");
  gets(input);
  palette_size = atoi(input);
  if (palette_size >= 2 && palette_size <= 8)
   break;
  printf("Error: 2..8.\n");
 }

 printf("Enter %d colors (R G B) separated by spaces:\n", palette_size);
 for (i = 0; i < palette_size; i++)
 {
  while (1)
  {
   printf("Color %d: ", i);
   gets(input);
   if (sscanf(input, "%d %d %d", &r, &g, &bl) == 3)
   {
    if (r >= 0 && r <= 255 && g >= 0 && g <= 255 && bl >= 0 && bl <= 255)
    {
     pal[i].r = (unsigned char)r;
     pal[i].g = (unsigned char)g;
     pal[i].b = (unsigned char)bl;
     break;
    }
   }
   printf("Error: Need 3 numbers (0..255).\n");
  }
 }

 printf("Enter t precision (3..5) [default 5]: ");
 gets(input);
 t_bits = atoi(input);
 if (t_bits < 3 || t_bits > 5)
  t_bits = 5;

 if (palette_size <= 2)
  i_bits = 1;
 else if (palette_size <= 4)
  i_bits = 2;
 else
  i_bits = 3;

 pixel_bits = i_bits + i_bits + t_bits;
 p_bytes = (pixel_bits + 7) / 8;

 memcpy(fh.header.signature, "QBT1", 4);
 fh.header.width = (unsigned short)w;
 fh.header.height = (unsigned short)h;
 fh.header.palette_size = (unsigned short)palette_size;
 fh.header.mix_bits = (unsigned short)t_bits;

 fh.content.palette_offset = sizeof(QBT1_FileHeader);
 fh.content.pixels_offset = fh.content.palette_offset + (sizeof(RGB24) * palette_size);
 fh.content.file_size = fh.content.pixels_offset + (w * h * p_bytes);

 f = fopen(filename, "wb");
 if (!f)
 {
  printf("Error: Cannot create file '%s'.\n", filename);
  return;
 }

 fwrite(&fh, sizeof(QBT1_FileHeader), 1, f);
 fwrite(pal, sizeof(RGB24), palette_size, f);
 total_pixels = (long)w * h;
 printf("%ld\n", total_pixels);
 for (i = 0; i < total_pixels; i++)
 {
  unsigned short p = 0;
  unsigned char idx1 = 0;
  unsigned char idx2 = 1;
  unsigned char t_val = 0;
  int x = i % w;
  int y = i / w;
  int max_t = (1 << t_bits) - 1;
  // case 3:
  // {
  //  int band = x / 4;
  //  idx1 = (band % 2 == 0) ? 0 : 1;
  //  idx2 = (band % 2 == 0) ? 1 : 0;
  //  t_val = (x % 4) * max_t / 3;
  //  break;
  // }
  // case 4:
  // {
  //  int diag = (x + y) / 2;
  //  idx1 = (diag % 2 == 0) ? 0 : 1;
  //  idx2 = (diag % 2 == 0) ? 1 : 0;
  //  t_val = (diag * 3) % max_t;
  //  break;
  // }
  // case 5:
  // {
   int cx = w / 2;
   int cy = h / 2;
   int dx = x - cx;
   int dy = y - cy;
   int dist = (dx * dx + dy * dy) / 10;
   idx1 = (dist % 2 == 0) ? 0 : 1;
   idx2 = (dist % 2 == 0) ? 1 : 0;
   t_val = dist % max_t;
  //  break;
  // }
  // default:
  // {
  //  idx1 = 0;
  //  idx2 = 1;
  //  t_val = 0;
  //  break;
  // }
  // }

  p = (idx2 << (t_bits + i_bits)) | (idx1 << t_bits) | t_val;

  for (b = 0; b < p_bytes; b++)
  {
   fputc((p >> (8 * b)) & 0xFF, f);
  }
 }

 fclose(f);

 printf("\nSuccess! File '%s' created.\n", filename);
 printf("Size: %dx%d, Colors: %d, Pixel size: %d bits (%d bytes)\n",
        w, h, palette_size, pixel_bits, p_bytes);
}

/* =========================================================
 * 4. VIEW
 * ========================================================= */
void view_image(void)
{
 int offset_x = 0;
 int offset_y = 0;
 int zoom = 1;
 int running = 1;
 int y, x, dy, dx, key;
 int shift_step = 20;
 long file_offset;
 int row_size;
 int bytes_read;

 set_video_mode(0x13);

 while (running)
 {
  int start_x, end_x, start_y, end_y;
  CLEAR_SCREEN_VGA(7);

  // --- Вычисляем границы видимой области ---
  start_x = (offset_x < 0) ? (-offset_x / zoom) : 0;
  start_y = (offset_y < 0) ? (-offset_y / zoom) : 0;
  end_x = (VIEW_W - offset_x) / zoom + 1;
  end_y = (VIEW_H - offset_y) / zoom + 1;

  if (end_x > current_header.width)
   end_x = current_header.width;
  if (end_y > current_header.height)
   end_y = current_header.height;
  if (start_x < 0)
   start_x = 0;
  if (start_y < 0)
   start_y = 0;

  row_size = current_header.width * p_bytes;

  // --- Цикл отрисовки ---
  for (y = start_y; y < end_y; y++)
  {
   // Вычисляем смещение начала этой строки в файле
   file_offset = current_file_header.content.pixels_offset + (long)y * current_header.width * p_bytes;

   // Читаем строку в буфер
   fseek(current_file, file_offset, SEEK_SET);
   bytes_read = fread(line_buffer, 1, row_size, current_file);
   if (bytes_read < row_size)
    break; // Ошибка чтения или конец файла

   for (x = start_x; x < end_x; x++)
   {
    int idx = x * p_bytes; // Смещение пикселя внутри line_buffer
    unsigned char color = decode_pixel(&line_buffer[idx]);

    // Рисуем с учетом zoom
    for (dy = 0; dy < zoom; dy++)
    {
     for (dx = 0; dx < zoom; dx++)
     {
      PUT_PIXEL_VGA(offset_x + x * zoom + dx,
                    offset_y + y * zoom + dy, color);
     }
    }
   }
  }

  // --- Обработка ввода ---
  key = getch();
  if (key == 0)
  {
   key = getch();
   switch (key)
   {
   case 72:
    offset_y += shift_step;
    break;
   case 80:
    offset_y -= shift_step;
    break;
   case 75:
    offset_x += shift_step;
    break;
   case 77:
    offset_x -= shift_step;
    break;
   }
  }
  else
  {
   if (key == 27)
    running = 0;
   else if (key == '+' || key == '=')
    zoom++;
   else if (key == '-' || key == '_')
   {
    if (zoom > 1)
     zoom--;
   }
  }
 }
 set_video_mode(0x03);
}

/* =========================================================
 * 5. OPEN
 * ========================================================= */
void open_image(char *filename)
{
 int i_bits;

 current_file = fopen(filename, "rb");
 if (!current_file)
 {
  printf("Error: Cannot open %s\n", filename);
  return;
 }

 if (fread(&current_file_header, sizeof(QBT1_FileHeader), 1, current_file) != 1)
 {
  printf("Error: Read error.\n");
  fclose(current_file);
  current_file = NULL;
  return;
 }
 current_header = current_file_header.header;

 if (memcmp(current_header.signature, "QBT1", 4) != 0)
 {
  printf("Error: Invalid format.\n");
  fclose(current_file);
  current_file = NULL;
  return;
 }

 if (current_header.palette_size <= 2)
  i_bits = 1;
 else if (current_header.palette_size <= 4)
  i_bits = 2;
 else
  i_bits = 3;
 p_bytes = (i_bits + i_bits + current_header.mix_bits + 7) / 8;

 fseek(current_file, current_file_header.content.palette_offset, SEEK_SET);
 fread(current_palette, sizeof(RGB24), current_header.palette_size, current_file);

 // Запускаем просмотр
 view_image();

 // Закрываем файл после выхода
 fclose(current_file);
 current_file = NULL;
}

void print_help(void)
{
 printf("QBT1 MVP (Turbo C)\n");
 printf("Commands:\n");
 printf("  h - help\n");
 printf("  c - crerate\n");
 printf("  o - open\n");
 printf("  e - exit\n\n");
}

/* =========================================================
 * 6. ГЛАВНЫЙ ЦИКЛ (КОНСОЛЬ)
 * ========================================================= */
int main()
{
 char input[200];
 vga = (unsigned char far *)0xA0000000L;
 print_help();
 while (1)
 {
  printf("> ");
  gets(input);
  if (strcmp(input, "e") == 0)
   break;
  if (strcmp(input, "h") == 0)
   print_help();
  else if (strcmp(input, "c") == 0)
   create_image();
  else if (strncmp(input, "o ", 2) == 0)
   open_image(input + 2);
  else
   printf("Unknown command.\n");
 }
 return 0;
}