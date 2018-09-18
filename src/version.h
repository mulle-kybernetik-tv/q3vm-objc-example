#ifndef q3vm_objc_example_version_h__
#define q3vm_objc_example_version_h__

/*
 *  version:  major, minor, patch
 */
#define Q3VM_OBJC_EXAMPLE_VERSION  ((0 << 20) | (7 << 8) | 56)


static inline unsigned int   q3vm_objc_example_get_version_major( void)
{
   return( Q3VM_OBJC_EXAMPLE_VERSION >> 20);
}


static inline unsigned int   q3vm_objc_example_get_version_minor( void)
{
   return( (Q3VM_OBJC_EXAMPLE_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   q3vm_objc_example_get_version_patch( void)
{
   return( Q3VM_OBJC_EXAMPLE_VERSION & 0xFF);
}

#endif
