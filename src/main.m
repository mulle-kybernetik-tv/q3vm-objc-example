#import "import-private.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "vm.h"

@interface Hello : NSObject

- (void) print;

@end


@implementation Hello

- (void) print
{
   printf( "VfL Bochum %d\n", Q3VM_OBJC_EXAMPLE_VERSION);
}

@end


/* Callback from the VM that something went wrong */
void Com_Error(vmErrorCode_t level, const char* error)
{
    fprintf( stderr, "Err (%i): %s\n", level, error);
    exit( level);
}

/* Callback from the VM for memory allocation */
void* Com_malloc(size_t size, vm_t* vm, vmMallocType_t type)
{
   return( mulle_malloc( size));
}

/* Callback from the VM for memory release */
void Com_free(void* p, vm_t* vm, vmMallocType_t type)
{
    mulle_free(p );
}

static uint8_t* loadImage(const char* filepath, int* size)
{
    FILE*    f;            /* bytecode input file */
    uint8_t* image = NULL; /* bytecode buffer */
    int      sz;           /* bytecode file size */

    *size = 0;
    f     = fopen( filepath, "rb");
    if (!f)
    {
        fprintf(stderr, "Failed to open file %s.\n", filepath);
        return NULL;
    }
    /* calculate file size */
    fseek(f, 0L, SEEK_END);
    sz = ftell(f);
    if (sz < 1)
    {
        fclose(f);
        return NULL;
    }
    rewind(f);

    image = (uint8_t*) mulle_malloc(sz);
    if (!image)
    {
        fclose(f);
        return NULL;
    }

    if (fread(image, 1, sz, f) != (size_t)sz)
    {
        free(image);
        fclose(f);
        return NULL;
    }

    fclose(f);
    *size = sz;
    return image;
}



struct int64bit {
   uint32_t   lo;
   int32_t    hi;
};

static inline void   int64bit_set( struct int64bit *p, intptr_t value)
{
   p->lo = (uint32_t) value;
   p->hi = (int32_t) (value >> 32);
}

static inline intptr_t   int64bit_get( struct int64bit *p)
{
   return( ((intptr_t) p->hi << 32) | p->lo);
}


static inline void   *int64bit_get_pointer( struct int64bit *p)
{
   return( p ? (void *) int64bit_get( p) : NULL);
}

static inline void   int64bit_set_pointer( struct int64bit *p, void *value)
{
   if( p)
      int64bit_set( p, (intptr_t) value);
}


/* Callback from the VM: system function call */
static intptr_t systemCalls(vm_t* vm, intptr_t* args)
{
   int callid = -1 - args[0];

   switch( callid)
   {
   case -1: /* PRINTF */
      return printf("%s", (char*)VMA(1, vm));

   case -2: /* ERROR */
      return fprintf(stderr, "%s", (char*)VMA(1, vm));

   case -3: /* MEMSET */
      if (VM_MemoryRangeValid(args[1] /*addr*/, args[3] /*len*/, vm) == 0)
      {
         memset(VMA(1, vm), args[2], args[3]);
      }
      return args[1];

   case -4: /* MEMCPY */
      if (VM_MemoryRangeValid(args[1] /*addr*/, args[3] /*len*/, vm) == 0 &&
         VM_MemoryRangeValid(args[2] /*addr*/, args[3] /*len*/, vm) == 0)
      {
         memcpy(VMA(1, vm), VMA(2, vm), args[3]);
      }
      return args[1];

   case -5 : /* objc_getClass */
   {
      char                   *name;
      Class                  cls;
      mulle_objc_classid_t   classid;
      struct int64bit        *vmcls;

      name    = (char*) VMA(1, vm);
      vmcls   = (struct int64bit *) VMA(2, vm);
      classid = mulle_objc_classid_from_string( name);
      cls     = mulle_objc_inline_unfailingfastlookup_infraclass( classid);
      int64bit_set_pointer( vmcls, cls);
      return( (intptr_t) 0);
   }

   case -6 : /* objc_msgSend */
   {
      id                obj;
      void              *result;
      char              *selName;
      void              *_param;
      struct int64bit   *rval;
      SEL               _cmd;

      obj     = (id) int64bit_get_pointer( (struct int64bit *) VMA( 2, vm));
      selName = (char *) VMA( 3, vm);
      _param  = (void *) int64bit_get_pointer( (struct int64bit *) VMA( 4, vm));

      _cmd    = mulle_objc_methodid_from_string( selName);
      result  = MulleObjCPerformSelector( obj, _cmd, _param);

      rval    = (struct int64bit *) VMA( 1, vm);
      int64bit_set_pointer( rval, result);

      return( (intptr_t) result != 0);
   }

   case -7 : /* objc_msgSend2 */
   {
      id                obj;
      void              *result;
      char              *selName;
      void              *_param0;
      void              *_param1;
      struct int64bit   *rval;
      SEL               _cmd;

      obj     = (id) int64bit_get_pointer( (struct int64bit *) VMA( 2, vm));
      selName = (char *) VMA( 3, vm);
      _param0 = (void *) int64bit_get_pointer( (struct int64bit *) VMA( 4, vm));
      _param1 = (void *) int64bit_get_pointer( (struct int64bit *) VMA( 5, vm));

      _cmd    = mulle_objc_methodid_from_string( selName);
      result  = MulleObjCPerformSelector2( obj, _cmd, _param0, _param1);

      rval    = (struct int64bit *) VMA( 1, vm);
      int64bit_set_pointer( rval, result);

      return( (intptr_t) result != 0);
   }

    default:
        fprintf(stderr, "Bad system call: %ld\n", (long int)args[0]);
    }
    return 0;
}



int  main( int argc, char *argv[])
{
   vm_t     vm;
   int      rval;
   char     *filepath;
   uint8_t  *image;
   int      imageSize;

   if( argc < 2)
   {
      printf("No virtual machine supplied. Example: q3vm-objc-example bytecode.qvm\n");
      return( -1);
   }

   filepath = argv[1];
   image    = loadImage(filepath, &imageSize);
   if( ! image)
      return( -1);

   if( VM_Create( &vm, filepath, image, imageSize, systemCalls))
      return( -1);
   
   rval = VM_Call( &vm, 1848);
   
   // VM_VmProfile_f(&vm); /* output profile information in DEBUG_VM build */
   VM_Free(&vm);
   mulle_free(image); /* we can release the memory now */

   return( rval);
}
