////////////////////////////////////////////////////////////////////////////////
// ball.h
////////////////////////////////////////////////////////////////////////////////

#pragma once

////////////////////////////////////////////////////////////////////////////////

class Ball
{
  class Pos
  {
  public:
    Pos(const Ball &ball) ;
    void Update() ;
    unsigned char operator()() const ;

  private:
    const Ball &_ball ;
    unsigned char _p ;
    char _dp ;
  } ;

  class Col
  {
  public:
    Col(const Ball &ball) ;
    void Update() ;
    unsigned char operator()(unsigned char sel) const ;

  private:
    const Ball &_ball ;
    unsigned char _c[3] ;
    char _dc ;
  } ;

public:
  enum RndType
  {
    kBall,
    kPos,
    kColUp,
    kColDown,
  } ;

  Ball() ;
  void Update() ;
  unsigned char Rnd(RndType type) const ;
  unsigned char X() const  { return _x()  ; }
  unsigned char Y() const  { return _y()  ; }
  unsigned char R(unsigned char intens) const { return _r(intens) ; }
  unsigned char G(unsigned char intens) const { return _g(intens) ; }
  unsigned char B(unsigned char intens) const { return _b(intens) ; }

private:
  Pos _x, _y ;
  Col _r, _g, _b ;
  static unsigned char _rnd ;
} ;

////////////////////////////////////////////////////////////////////////////////

class LedMatrix
{
public:
#if 1
  static const unsigned char kX = 8 ; // LEDx x - power of 2, max 16
  static const unsigned char kShiftX = 5 ; // bits to shift from 256 to X
  static const unsigned char kY = 8 ; // LEDs y - power of 2, max 16
  static const unsigned char kShiftY = 5 ; // bits to shift from 256 to
#else
  static const unsigned char kX = 16 ; // LEDx x - power of 2, max 16
  static const unsigned char kShiftX = 4 ; // bits to shift from 256 to X
  static const unsigned char kY = 16 ; // LEDs y - power of 2, max 16
  static const unsigned char kShiftY = 4 ; // bits to shift from 256 to Y
#endif
  static const unsigned short kSize = kX * kY ;
  static const unsigned char kBalls = 3 ; // number of balls - max 4

  LedMatrix() ;
  void Update() ;
  const unsigned char* Data() const ;
  void GetCol(unsigned char byte) const ;
  static const unsigned short Size() ;
  
private:
  void Clear() ;
  void Set(unsigned char x, unsigned char y, unsigned char data) ;
  void GetColBall(unsigned char byte) const ;
  
private:
  unsigned char _data[kSize/2] ; // each entry: 2x (2bit colIntensity | 2bit ballId)
  Ball _balls[kBalls] ;
} ;

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
