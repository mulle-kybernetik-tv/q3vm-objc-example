#include "bg_lib.h"

void printf( char* fmt, ...);
void  test_objc_code( int arg0);

/*
================
vmMain

This is the only way control passes into the module.
This must be the very first function compiled into the .qvm file
================
*/
int vmMain(int command, int arg0, int arg1, int arg2, int arg3, int arg4,
           int arg5, int arg6, int arg7, int arg8, int arg9, int arg10,
           int arg11)
{
   switch( command)
   {
   case 0:
      printf("Hello World!\n");
      return( 0);

   case 1848 :
      test_objc_code( arg0);
      return( 0);

   default :
      printf("Unknown command.\n");
   }

   return( -1);
}

void   printf( char* fmt, ...)
{
    va_list   argptr;
    char      text[ 1024];

    va_start( argptr, fmt);
    vsprintf( text, fmt, argptr);
    va_end( argptr);

    trap_Printf(text);
}

typedef char   *SEL;
#define NULL   ((void *) 0)

enum
{
   NO = 0,
   YES = 1
};

//
// as this is supposed to be platform agnostic bytecode (is it really)
// we can't optimize for 32 bit it seems
//
struct _int64_t {
   unsigned int   lo;
   int            hi;
};

typedef struct _int64_t   BOOL;
typedef struct _int64_t   NSInteger;
typedef struct _int64_t   NSUInteger;
typedef struct _int64_t   Class;
typedef struct _int64_t   id;


void   test_objc_code( int arg0)
{
   id      obj;
   Class   cls;

   objc_getClass( &cls, "Hello");               // [Hello ... 
   objc_msgSend( &obj, &cls, "new", NULL);      // obj = [cls new]
   objc_msgSend( NULL, &obj, "print", NULL);    // [objc print:x foo:y];:
}

