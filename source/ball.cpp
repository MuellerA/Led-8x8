////////////////////////////////////////////////////////////////////////////////
// ball.cpp
////////////////////////////////////////////////////////////////////////////////

#include "ball.h"

////////////////////////////////////////////////////////////////////////////////
// Ball
////////////////////////////////////////////////////////////////////////////////

Ball::Pos::Pos(const Ball &ball) : _ball(ball), _p(_ball.Rnd(kBall)), _dp(_ball.Rnd(kPos))
{
  if (_p >= 0xf0) _p = 0xef ;
  if (_p <  0x10) _p = 0x10 ;
}

void Ball::Pos::Update()
{
  if (_dp < 0)
  {
    if (_p < (unsigned char)-_dp)
      _dp = _ball.Rnd(kPos) ;
  }
  else
  {
    if (_p >= (unsigned char)-_dp)
      _dp = -_ball.Rnd(kPos) ;
  }
  _p += _dp ;
}

unsigned char Ball::Pos::operator()() const
{
  return _p ;
}

////////////////////////////////////////////////////////////////////////////////

Ball::Col::Col(const Ball &ball) : _ball(ball), _dc(_ball.Rnd(kColUp))
{
  _c[0] =_ball.Rnd(kBall) ;
  if (_c[0] >= 0x70) _c[0] = 0x6f ;
  if (_c[0] <  0x18) _c[0] = 0x18 ;
  _c[1] = 0 ;
  _c[2] = 0 ;
}

void Ball::Col::Update()
{
  if (_dc < 0)
  {
    if (_c[0] < 0x10)
      _dc = _ball.Rnd(kColUp) ;
  }
  else
  {
    if (_c[0] >= 0x80)
      _dc = -_ball.Rnd(kColDown) ;
  }

  _c[0] += _dc ;
  _c[1] = _c[0] >> 2 ;
  _c[2] = _c[1] >> 2 ;
}

unsigned char Ball::Col::operator()(unsigned char sel) const
{
  return _c[sel] ;
}

////////////////////////////////////////////////////////////////////////////////

Ball::Ball() : _x(*this), _y(*this), _r(*this), _g(*this), _b(*this)
{
}

void Ball::Update()
{
  _x.Update() ;
  _y.Update() ;
  
  _r.Update() ;
  _g.Update() ;
  _b.Update() ;
}

unsigned char Ball::Rnd(Ball::RndType type) const
{
  unsigned char rnd = 0 ;
  unsigned char *ch = (unsigned char*) this ;
  for (unsigned int i = 0 ; i < sizeof(*this) ; ++i)
  {
    rnd += (RndVal++ + *(ch++)) ^ 0x5a ;
  }      

  switch (type)
  {
  case kBall   :                                        break ;
  case kPos    : rnd &= 0x0f ; if (rnd <  5) rnd =  5 ; break ;
  case kColUp  : rnd &= 0x07 ; if (rnd <  2) rnd =  2 ; break ;
  case kColDown: rnd &= 0x03 ; if (rnd <  1) rnd =  1 ; break ;
  }

  return rnd ;	 
}

////////////////////////////////////////////////////////////////////////////////
// LedMatrixBall
////////////////////////////////////////////////////////////////////////////////

LedMatrixBall::LedMatrixBall()
{
}

void LedMatrixBall::Run()
{
  while (1)
  {
    Update() ;
    for (unsigned short i = 0 ; i < 0x7fff ; ++i)
      Nop() ;
  }
}

void LedMatrixBall::Update()
{
  for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
  {
    iBall->Update() ;
  }

  for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
  {
    unsigned char x, y ;

    LedMatrix::IdxToCoord(idx, x, y) ;

    unsigned char r = 0 ;
    unsigned char g = 0 ;
    unsigned char b = 0 ;
    
    for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
    {
      unsigned char bx = iBall->X() >> LedMatrix::kShiftX ;
      unsigned char by = iBall->Y() >> LedMatrix::kShiftY ;

      char dx = bx - x ;
      char dy = by - y ;

      if (dx < 0) dx = -dx ;
      if (dy < 0) dy = -dy ;

      if ((dx <= 1) && (dy <= 1))
      {
	unsigned char d = dx + dy ;
	r = iBall->R(d) ;
	g = iBall->G(d) ;
	b = iBall->B(d) ;
	break ;
      }
    }

    SendDataByte(g) ;
    SendDataByte(r) ;
    SendDataByte(b) ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
