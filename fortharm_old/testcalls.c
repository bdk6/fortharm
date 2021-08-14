
// test the parameter passing mechanism
int gl;

void f(void)
{
   return;
}

int g(int x)
{
   return x*2+9;
}

int h(int x, char y)
{return x+2*y;}
int i(int a, int b, int c, int d, int e, int f)
{
   int x = a + 2 * b + 3*c + 4 *d + 5 * e + 6 *f;
   gl = x;
   return gl;
}

int main2(void)
{
   int x = 0;
   int y = 1;
   char c = 'a';
   f();
   x = (g(x));
   x = h(y,c);
   x= i(1,2,3,4,5,6);

   return 0;
}
