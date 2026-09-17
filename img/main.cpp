// main.cpp
#include <string>
#include <vector>
#include <memory>
#include <iostream>
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

const static std::string progname = "rotate";
using data_t = std::vector<unsigned char>;

//Плюсовое решение ручных выделений памяти из си
struct StbiDeleter {
    void operator()( unsigned char* ptr ) const {
        stbi_image_free(ptr);
    }
};
using StbiPtr = std::unique_ptr<unsigned char, StbiDeleter>;


// 00 10     02 01 00   переворот картинки
// 01 11     21 11 10  
// 02 12
data_t rotate90( data_t src, int w, int h, int channels )
{
  int new_w = h;
  int new_h = w;
  data_t dst( new_w * new_h * channels );

  for ( int y = 0; y < h; y++ )
  {
    for ( int x = 0; x < w; x++ )
    {
      int new_x = h - 1 - y; 
      int new_y = x;
      
      int src_idx = ( y * w + x ) * channels;
      int dst_idx = ( new_y * new_w + new_x ) * channels;

      for( int c = 0; c < channels; c++)
      {
        dst[dst_idx + c] = src[src_idx + c];
      }
    }
  }
  return dst;
}

int main( int argc, char **argv )
{
  if ( argc < 3 )
  {
    std::cout << "Using:" << progname << "in.png out.png" << std::endl; 
    return 1;
  }

  int w, h, channels;
  StbiPtr raw(stbi_load(argv[1], &w, &h, &channels, 0));
  if ( !raw )
  {
    std::cout << "Couldn't load image: " << argv[1] << std::endl;  
    return 1;
  }
  data_t data(raw.get(), raw.get() + w * h * channels);

  data_t rotated = rotate90( data, w, h, channels );

  stbi_write_png( argv[2], h, w, channels, rotated.data(), h * channels );

  std::cout << "Save: " << argv[2] << std::endl;
  return 0;
}
