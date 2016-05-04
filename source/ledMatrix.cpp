////////////////////////////////////////////////////////////////////////////////
// ledMatrix.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

void LedMatrix::CoordToIdx(unsigned char x, unsigned char y, unsigned char &idx)
{
#if defined(MATRIX_2x2X8x8)
  idx =
    ((x & 0x07) << 0) |
    ((y & 0x07) << 3) |
    ((x & 0x08) << 3) |
    ((y & 0x08) << 4) ;
#elif defined(MATRIX_8x8)
  idx =
    (x << 0) |
    (y << 3) ;
#elif defined(MATRIX_2X8x8)
  idx =
    ((x & 0x07) << 0) |
    ((y & 0x07) << 3) |
    ((x & 0x08) << 3) ;    
#else
  #error "undefined matrix layout"
#endif
}

void LedMatrix::IdxToCoord(unsigned char idx, unsigned char &x, unsigned char &y)
{
#if defined(MATRIX_2x2X8x8)
  x =
    ((idx >> 0) & 0x07) |
    ((idx >> 3) & 0x08) ;
  y =
    ((idx >> 3) & 0x07) |
    ((idx >> 4) & 0x08) ;
#elif defined(MATRIX_8x8)
  x =
    ((idx >> 0) & 0x07) ;
  y =
    ((idx >> 3) & 0x07) ;
#elif defined(MATRIX_2X8x8)
  x =
    ((idx >> 0) & 0x07) |
    ((idx >> 3) & 0x08) ;
  y =
    ((idx >> 3) & 0x07) ;
#else
  #error "undefined matrix layout"
#endif
}

void LedMatrix::Clear()
{
  for (unsigned short i = 0 ; i < kSize * 3 ; ++i)
    SendDataByte(0) ;
}
  
////////////////////////////////////////////////////////////////////////////////

void Rgb::Clr(unsigned char init)
{
  _r = _g = _b = init ;
}
void Rgb::Set(short r, short g, short b)
{
  _r = r ; _g = g ; _b = b ;
}
void Rgb::Add(const Rgb &add)
{
  _r += add._r ; _g += add._g ; _b += add._b ;
}
void Rgb::Sub(const Rgb &sub)
{
  _r -= sub._r ; _g -= sub._g ; _b -= sub._b ;
}
void Rgb::DivX()
{
  _r /= LedMatrix::kX ; _g /= LedMatrix::kX ; _b /= LedMatrix::kX ;
}
void Rgb::Rnd(unsigned char *data, unsigned char size)
{
  _r = Rnd0(data, size) ; _g = Rnd0(data, size) ; _b = Rnd0(data, size) ;
}
unsigned char  Rgb::Rnd0(unsigned char *data, unsigned char size)
{
  unsigned char rnd = 0 ;
  for (unsigned int i = 0 ; i < size ; ++i)
  {
    rnd += (RndVal++ + *(data++)) ^ 0x5a ;
  }      
  rnd &= 0x3f ;
  if (rnd < 0x10)
    rnd = 0x10 ;
  return rnd & 0x30 ;
}
void Rgb::Send() const
{
  SendDataByte((unsigned char)_g >> 1) ;
  SendDataByte((unsigned char)_r >> 1) ;
  SendDataByte((unsigned char)_b >> 1) ;
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
