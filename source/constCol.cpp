////////////////////////////////////////////////////////////////////////////////
// constCol.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

#include "ledMatrix.h"

////////////////////////////////////////////////////////////////////////////////

class ConstCol
{
public:
  ConstCol(unsigned char r, unsigned char g, unsigned char b) ;
  void Run() ;

private:
  Rgb _rgb ;
} ;

ConstCol::ConstCol(unsigned char r, unsigned char g, unsigned char b)
{
  _rgb.Set(r, g, b) ;
}

void ConstCol::Run()
{
  for (unsigned short i = 0 ; i < LedMatrix::kSize ; ++i)
    _rgb.Send() ;
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////

