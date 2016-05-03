////////////////////////////////////////////////////////////////////////////////
// ledMatrix.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#pragma once

////////////////////////////////////////////////////////////////////////////////

extern "C"
{
  void SendDataByte(unsigned char c) ;
  void Nop() ;
}

extern unsigned char RndVal ;

////////////////////////////////////////////////////////////////////////////////

// one 8x8 matrix
#define MATRIX_8x8

// two 8x8 matrices  1 2
//#define MATRIX_2X8x8

// four 8x8 matrices 1 2
//                   3 4
//#define MATRIX_2x2X8x8

////////////////////////////////////////////////////////////////////////////////

class LedMatrix
{
 public:
#if defined(MATRIX_2x2X8x8)
  static const unsigned char kX = 16 ;     // LEDx x - power of 2, max 16
  static const unsigned char kShiftX = 4 ; // bits to shift from 256 to X
  static const unsigned char kY = 16 ;     // LEDs y - power of 2, max 16
  static const unsigned char kShiftY = 4 ; // bits to shift from 256 to Y
#elif defined(MATRIX_8x8)
  static const unsigned char kX = 8 ;      // LEDx x - power of 2, max 16
  static const unsigned char kShiftX = 5 ; // bits to shift from 256 to X
  static const unsigned char kY = 8 ;      // LEDs y - power of 2, max 16
  static const unsigned char kShiftY = 5 ; // bits to shift from 256 to
#elif defined(MATRIX_2X8x8)
  static const unsigned char kX = 16 ;     // LEDx x - power of 2, max 16
  static const unsigned char kShiftX = 4 ; // bits to shift from 256 to X
  static const unsigned char kY = 8 ;      // LEDs y - power of 2, max 16
  static const unsigned char kShiftY = 5 ; // bits to shift from 256 to
#else
  #error "undefined matrix layout"
#endif
  static const unsigned short kSize = kX * kY ;

  
  static void CoordToIdx(unsigned char x, unsigned char y, unsigned char &idx) ;
  static void IdxToCoord(unsigned char idx, unsigned char &x, unsigned char &y) ;
  static void Clear() ;
} ;

////////////////////////////////////////////////////////////////////////////////

class Rgb
{
public:
  void Clr(unsigned char init = 0) ;
  void Set(short r, short g, short b) ;
  void Add(const Rgb &add) ;
  void Sub(const Rgb &sub) ;
  void DivX() ;
  void Rnd(unsigned char *data, unsigned char size) ;
  void Send() const ;
  
private:
  unsigned char Rnd0(unsigned char *data, unsigned char size) ;
  
private:
    short _r ;
    short _g ;
    short _b ;
} ;

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
