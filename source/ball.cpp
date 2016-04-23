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
  _c[2] =_ball.Rnd(kBall) ;
  if (_c[2] >= 0x70) _c[2] = 0x6f ;
  if (_c[2] <  0x18) _c[2] = 0x18 ;
  _c[1] = 0 ;
  _c[0] = 0 ;
}

void Ball::Col::Update()
{
  if (_dc < 0)
  {
    if (_c[2] < 0x10)
      _dc = _ball.Rnd(kColUp) ;
  }
  else
  {
    if (_c[2] >= 0x80)
      _dc = -_ball.Rnd(kColDown) ;
  }
  _c[2] += _dc ;
  _c[1] = _c[2] >> 2 ;
  _c[0] = _c[1] >> 2 ;
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


extern unsigned char RndVal ;

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
// LedMatrix
////////////////////////////////////////////////////////////////////////////////

LedMatrix::LedMatrix()
{
  Clear() ;
}

void LedMatrix::Clear()
{
  for (unsigned char *iData = _data, *eData = _data + kSize/2 ; iData < eData ; ++iData)
    *iData = 0 ;
}

void LedMatrix::Update()
{
  Clear() ;

  unsigned char ballId = 0x00 ;
  for (Ball *iBall = _balls, *eBall = _balls + kBalls ; iBall < eBall ; ++iBall)
  {
    Ball &ball = *iBall ;

    ball.Update() ;
    unsigned char x = ball.X() >> kShiftX ;
    unsigned char y = ball.Y() >> kShiftY ;

    if (x > 0)
    {
      if (y > 0)    Set(x-1, y-1, ballId | 0x04) ;
                    Set(x-1, y  , ballId | 0x08) ;
      if (y < kY-1) Set(x-1, y+1, ballId | 0x04) ;
    }

    if (y > 0)    Set(x, y-1, ballId | 0x08) ;
                  Set(x, y  , ballId | 0x0c) ;
    if (y < kY-1) Set(x, y+1, ballId | 0x08) ;

    if (x < kX-1)
    {
      if (y > 0)    Set(x+1, y-1, ballId | 0x04) ;
                    Set(x+1, y  , ballId | 0x08) ;
      if (y < kY-1) Set(x+1, y+1, ballId | 0x04) ;
    }

    ++ballId ;
  }
}

const unsigned char* LedMatrix::Data() const
{
  return _data ;
}

const unsigned short LedMatrix::Size()
{
  return kSize / 2 ;
}

void LedMatrix::Set(unsigned char x, unsigned char y, unsigned char data)
{
  unsigned char idx = 0x00 ;

  idx |= (x & 0x06) >> 1 ;
  idx |= (y & 0x07) << 2 ;
  idx |= (x & 0x08) << 2 ;
  idx |= (y & 0x08) << 3 ;

  if (x & 0x01)
  {
    if (!(_data[idx] & 0x0f))
      _data[idx] |= data << 0 ;
  }
  else 
  {
    if (!(_data[idx] & 0xf0))
      _data[idx] |= data << 4 ;
  }
}

extern "C" { void SendDataByte(unsigned char c) ; }

void LedMatrix::GetColBall(unsigned char byte) const
{
  unsigned char ballId =  (byte & 0x03) >> 0      ;
  unsigned char intens = ((byte & 0x0c) >> 2) - 1 ;

  const Ball &ball = _balls[ballId] ;
  SendDataByte(ball.G(intens)) ;
  SendDataByte(ball.R(intens)) ;
  SendDataByte(ball.B(intens)) ;  
}

void LedMatrix::GetCol(unsigned char byte) const
{
  if (byte & 0xf0)
  {
    GetColBall(byte >> 4) ;
  }
  else
  {
    SendDataByte(0x00) ;
    SendDataByte(0x00) ;
    SendDataByte(0x00) ;
  }
  
  if (byte & 0x0f)
  {
    GetColBall(byte >> 0) ;
  }
  else
  {
    SendDataByte(0x00) ;
    SendDataByte(0x00) ;
    SendDataByte(0x00) ;
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
