////////////////////////////////////////////////////////////////////////////////
// ball.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#pragma once

////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

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
} ;

////////////////////////////////////////////////////////////////////////////////

class LedMatrixBall
{
public:
  static const unsigned char kBalls = 4 ;

  LedMatrixBall() ;
  void Run() ;

private:
  void Update() ;

private:
  Ball _balls[kBalls] ;
} ;

static_assert(sizeof(LedMatrixBall) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
