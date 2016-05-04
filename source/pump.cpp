////////////////////////////////////////////////////////////////////////////////
// pump.cpp
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class Pump
{
public:
  Pump(unsigned char mode) ;

  void Run() ;

private:
  unsigned char _mode ;
  Rgb &_curRgb ;
  Rgb _deltaRgb ;
  Rgb _rgb[LedMatrix::kX/2] ;
} ;

static_assert(sizeof(Pump) < (RAMSIZE - 0x28), "not enough RAM") ;

////////////////////////////////////////////////////////////////////////////////

Pump::Pump(unsigned char mode) : _mode(mode), _curRgb(_rgb[LedMatrix::kX/2 - 1])
{
  for (Rgb *iRgb = _rgb, *eRgb = _rgb + LedMatrix::kX/2 ; iRgb < eRgb ; ++iRgb)
    iRgb->Clr(0x10) ;
}

void Pump::Run()
{
  while (1)
  {
    _deltaRgb.Rnd((unsigned char*)this, sizeof(*this)) ;
    _deltaRgb.Sub(_curRgb) ;
    _deltaRgb.DivX() ;

    for (unsigned char x = 0 ; x < LedMatrix::kX ; ++x)
    {
      for (unsigned char x2 = 0 ; x2 < LedMatrix::kX/2 - 1 ; ++x2)
	_rgb[x2] = _rgb[x2+1] ;
      _curRgb.Add(_deltaRgb) ;
    
      for (unsigned short idx = 0 ; idx < LedMatrix::kSize ; ++idx)
      {
	switch (_mode)
	{
	case 1:
	  {
	    unsigned char  x, y ;
	    LedMatrix::IdxToCoord(idx, x, y) ;
	    if (x >= LedMatrix::kX/2)
	      x = LedMatrix::kX-1 - x ;
	    if (y >= LedMatrix::kY/2)
	      y = LedMatrix::kY-1 - y ; 
	    if (y < x)
	      x = y ;
	    _rgb[x].Send() ;
	  }
	  break ;
	default:
	  {
	    _curRgb.Send() ;
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
