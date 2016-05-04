////////////////////////////////////////////////////////////////////////////////
// flow.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Flow
{
public:
  Flow(unsigned char mode) ;

  void Run() ;

private:
  unsigned char _mode ;
  Rgb &_curRgb ;
  Rgb _deltaRgb ;
  Rgb _rgb[LedMatrix::kX] ;
} ;

static_assert(sizeof(Flow) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////

Flow::Flow(unsigned char mode) : _mode(mode), _curRgb(_rgb[0])
{
  for (Rgb *iRgb = _rgb, *eRgb = _rgb + LedMatrix::kX ; iRgb < eRgb ; ++iRgb)
    iRgb->Clr(0x10) ;
}

void Flow::Run()
{
  while (1)
  {
    _deltaRgb.Rnd((unsigned char*)this, sizeof(*this)) ;
    _deltaRgb.Sub(_curRgb) ;
    _deltaRgb.DivX() ;

    for (unsigned char x = 0 ; x < LedMatrix::kX ; ++x)
    {
      for (unsigned char x2 = LedMatrix::kX - 1 ; x2 > 0 ; --x2)
	_rgb[x2] = _rgb[x2-1] ;
      _curRgb.Add(_deltaRgb) ;
    
      for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
      {
	switch (_mode)
	{
	default:
	  {
	    unsigned char  x, y ;
	    LedMatrix::IdxToCoord(idx, x, y) ;
	    _rgb[x].Send() ;
	  }
	  break ;
	}
      }

      for (unsigned long i = 0 ; i < 0xffff ; ++i)
	Nop() ;
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////
