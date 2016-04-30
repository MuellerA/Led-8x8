////////////////////////////////////////////////////////////////////////////////
// constCol.h
// (c) Andreas Müller
//     see LICENSE.md
////////////////////////////////////////////////////////////////////////////////

extern "C" { void SendDataByte(unsigned char c) ; }

////////////////////////////////////////////////////////////////////////////////

class ConstCol
{
public:
  static const unsigned char kX = 16 ; // LEDx x - power of 2, max 16
  static const unsigned char kY = 16 ; // LEDs y - power of 2, max 16
  static const unsigned short kSize = kX * kY ;
  
  ConstCol(unsigned char r, unsigned char g, unsigned char b) ;
  void Run() ;

private:
  unsigned char _r ;
  unsigned char _g ;
  unsigned char _b ;
} ;

ConstCol::ConstCol(unsigned char r, unsigned char g, unsigned char b)
  : _r(r), _g(g), _b(b)
{
}

void ConstCol::Run()
{
  for (unsigned short i = 0 ; i < kSize ; ++i)
  {
    SendDataByte(_g) ;
    SendDataByte(_r) ;
    SendDataByte(_b) ;
  }  
}

////////////////////////////////////////////////////////////////////////////////
// EOF
////////////////////////////////////////////////////////////////////////////////

