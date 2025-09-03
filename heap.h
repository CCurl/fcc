/* A simple heap allocator */
/* Chris Curl - MIT License */

#ifndef __HALLOC__

#define __HALLOC__

#include <stdio.h>
#include <stdint.h>

// Change these to control the heap and index sizes.
// For details, see heap.c

#define HEAP_SZ        50000
#define HEAPINDEX_SZ    5000

extern void hInit(int gran);
extern char *hAlloc(int sz);
extern void hFree(char *data);
extern char *hRealloc(char *data, int newSz);
void hDump(int includeIndex, FILE *toFP);

#endif // __HALLOC__
