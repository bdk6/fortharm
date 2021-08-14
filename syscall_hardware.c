//////////////////////////////////////////////////////////////////////////////
///
///  \file syscall_hardware.c
///  copyright(c) 2014 William R Cooke
///
///  \brief  low level file interface routines for LPC1114
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "LPC11xx/LPC11xx.h"
#include "LPC11xx/uart.h"
#include <sys/stat.h>
#include "LPC11xx/syscall_hardware.h"


//////////////////////////////////////////////////////////////////////////////
///
///  \b _write
///
///  \brief writes string to uart
///
///  @param[in] fd  file to write -- not used
///  @param[in] s   pointer to string to write
///  @param[in] len  length of string to write
///  @return    number of chars written
///
//////////////////////////////////////////////////////////////////////////////
int _write(int fd, char *s, int len)
{
   int chars = len;
   while(chars > 0)
   {
      _uartwrch(*s);
      ++s;
      --chars;
   }
   return len;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b _read
///
///  \brief reads a string from uart
///
///  \param[in] fd  file to read -- not used
///  \param[out] s  pointer to string buffer
///  \param[in]  len number of chars to read
///  \return     number of chars read
///
//////////////////////////////////////////////////////////////////////////////
int _read(int fd, char *s, int len)
{
   int ch = 0;
   int chars = 0;

   while(chars < len)
   {
      while((ch = _uartrdch()) == -1);  // wait for a char (block)
      *s = (char)ch;
      ++s;
      ++chars;
   }
  
   return chars;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b _fstat
///
///  \brief returns information on file 
///
///  \param[in]   fd  file number to check
///  \param[out]  st  pointer to stat buffer
///  \return      Zero (success)
///
//////////////////////////////////////////////////////////////////////////////
int _fstat(int file, struct stat *st)
{
   st->st_mode = S_IFCHR;
   return 0;
}


//////////////////////////////////////////////////////////////////////////////
///
///  \b _isatty
///
///  \brief indicates if a file number is connected to a teletype
///
///  \param[in]   fd  file number to check
///  return       1 for a teletype, 0 otherwise (always 1 here)
///
//////////////////////////////////////////////////////////////////////////////
int _isatty(int fd)
{
   return 1;
}


//////////////////////////////////////////////////////////////////////////////
///
///  \b _open
///
///  \brief connects a file name with a file number and prepares for i/o
///
///  \param[in]  name  The name of the file or device file to open
///  \param[in]  flags Mode flags for ways  to open the file
///  \param[in]  mode read, write, create, etc
///  \return     File number of the opened file, -1 on error
///
//////////////////////////////////////////////////////////////////////////////
int _open(const char *name, int flags, int mode)
{
   static int fd = 0;
   _uartwrch(fd+48);
   _uartwrch('F');
   return fd++;
}


