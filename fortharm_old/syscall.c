

// from newlib docs at www.sourceware.org/newlib/


// _exit
// best not to implement or use

// close
int close (int file)
{
   serial_send('C');
   return 0;
}

int _close_r(void *reent, int file)
{
   return 0;
}

//environ
char *__env[1] = {0};
char **environ = __env;

// execve
#include <errno.h>
#undef errno
extern int errno;
int execve(char *name, char **argv, char **env)
{
   errno = ENOMEM;
   return -1;
}

//fork
#include <errno.h>
#undef errno
extern int errno;
int fork(void)
{
   errno = EAGAIN;
   return -1;
}

int _fork_r(void *reent)
{
   return -1;
}

//fstat
#include <sys/stat.h>
int fstat(int file, struct stat *st)
{
   serial_send('T');
   st->st_mode = S_IFCHR;
   return 0;
}

//getpid
int getpid(void)
{
   return 1;
}

// isatty
int isatty(int file)
{
   serial_send('Y');
   return 1;
}

int _isatty_r(void *reent, int fd)
{
   return 1;
}

// kill
#include <errno.h>
#undef errno
extern int errno;
int kill(int pid, int sig)
{
   errno = EINVAL;
   return -1;
}

// link
#include <errno.h>
#undef errno
extern int errno;
int link(char *old, char *new)
{
   errno = EMLINK;
   return -1;
}

int _link_r(void *reent, const char *old, const char *new)
{
   return -1;
}

// lseek
int lseek(int file, int ptr, int dir)
{
   return ESPIPE;
}

int _lseek_r(void *reent, int fd, off_t pos, int whence)
{
   serial_send('L');
   return ESPIPE;
}

// open
int open(const char *name, int flags, int mode)
{
   return 0;
}
int _open_r(void *reent, const char *name, int flags, int mode)
{
   return 0;
}

// read
int read(int file, char *ptr, int len)
{
   serial_send('R');
   return 0;
}

long _read_r(void *reent, int fd, void *buf, size_t cnt)
{
   return 0;
}

// sbrk
// Increase program data space.  As malloc and related functions depend on this, it is useful to have a 
// working implementation.  The following suffices for a standalone system.  It exploits the symbol
// _end automatically defined by the GNU linker.

caddr_t sbrk(int incr)
{
   extern char _end;       //Defined by the linker
   static char *heap_end;
   char *prev_heap_end;

   if (heap_end == 0)
   {
      heap_end = &_end;
   }
   prev_heap_end = heap_end;
/*
   if (heap_end + incr > _stack_ptr)
   {
      write (1, "Heap and stack collision\n", 25);
      abort();
   }
*/

   heap_end += incr;
   return (caddr_t) prev_heap_end;
}

char *_sbrk_r(void *reent, size_t incr)
{
   return 0;
}

#include <sys/stat.h>
// stat
int stat(const char *file, struct stat *st)
{
   st->st_mode = S_IFCHR;
   return 0;
}

int _stat_r(void *reent, const char *file, struct stat *pstat)
{
   return 0;
}
int _fstat_r(void *reent, int fd, struct stat *pstat)
{
   return 0;
}

// times
int times(struct tms *buf)
{
   return -1;
}

// unlink
#include <errno.h>
#undef errno
extern int errno;
int unlink(char *name)
{
   errno = ENOENT;
   return -1;
}

int _unlink_r(void *reent, const char *file)
{
   return -1;
}

// wait
#include <errno.h>
#undef errno
extern int errno;
int wait(int *status)
{
   errno = ECHILD;
   return -1;
}

int _wait_r(void *reent, int *status)
{
   return -1;
}

// write
// Write to a file.  libc subroutines will use this system routine for output to all files, including stdout --
// so if you need to generate any output, for example to a serial port for debugging, you should make your
// minimal write capable of doing this.  The following minimal implementation is an incomplete example.  It 
// relies on a outbyte subroutine (not show, typically you must wrte the in assembler from examples provided
// by your hardware manufacturer) to actually perform the output
int write(int file, char *ptr, int len)
{
   int todo;

   for (todo = 0; todo < len; todo++)
   {
      // outbyte(*ptr++);
      serial_send(*ptr++);
   }
   return len;
}

long _write_r(void *reent, int fd, const void *buf, size_t cnt)
{
   return write(fd, buf, cnt);
}
