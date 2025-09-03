/*---------------------------------------------------------------------------*/
/* A simple heap allocator */
/* Chris Curl - MIT License */

#include "heap.h"

#define BTWI(n,l,h) (((l) <= (n)) && ((n) <= (h)))

typedef unsigned int uint;
typedef struct {
	uint inUse: 1, sz: 31, off;
} HEAP_T, *PHEAP;

static uint32_t hHere = 0, iHere = 0;
static HEAP_T index[HEAPINDEX_SZ];
static char heap[HEAP_SZ];
static int hASG = sizeof(char *); // alloc size granularity

void hInit(int gran) {
	hHere = iHere = 0;
	if (0 < gran) { hASG = gran; }
	for (uint i = 0; i < HEAPINDEX_SZ; i++) {
		PHEAP x = (PHEAP)&index[i];
		x->inUse = x->off = x->sz = 0;
	}
}

void hDump(int includeIndex, FILE *toFP) {
	FILE *fp = toFP ? toFP : stdout;
	fprintf(fp, "heap component information:\n");
	fprintf(fp, "----------------------------------------\n");
	fprintf(fp, "heap  - size: %u bytes, %u used\n", HEAP_SZ, hHere);
	fprintf(fp, "index - size: %u records, %u used\n", HEAPINDEX_SZ, iHere);
	fprintf(fp, "other - index struct sz: %u, granularity, %d bytes\n", sizeof(HEAP_T), hASG);
	if (includeIndex) {
		for (uint i = 0; i < iHere; i++) {
			PHEAP x = (PHEAP)&index[i];
			fprintf(fp, "%3d, inuse: %u, sz: %2u, off: %u, ptr: %p\n",
				i, x->inUse, x->sz, x->off, &heap[x->off]);
		}
	}
}

static int hFindFree(uint sz) {
	uint best = -1;
	for (uint i = 0; i < iHere; i++) {
		PHEAP x = &index[i];
		if ((x->inUse == 0) && (sz <= x->sz)) {
			if (x->sz == sz) { return i; }
			if ((best == -1) || (index[best].sz < x->sz)) { best = i; }
		}
	}
	return best;
}

char *hAlloc(int sz) {
	if (sz == 0) { sz = 1; }
	if ((sz % hASG) != 0) { sz += hASG - (sz % hASG); }

	int hi = hFindFree(sz);
	if (0 <= hi) {
		index[hi].inUse = 1;
		return &heap[index[hi].off];
	}

	if (HEAP_SZ <= (hHere + sz)) { printf("-heap full-"); return NULL; }
	if (HEAPINDEX_SZ <= iHere) { printf("-index full-"); return NULL; }

	PHEAP x = &index[iHere++];
	x->sz = sz;
	x->off = hHere;
	x->inUse = 1;
	hHere += sz;
	return &heap[x->off];
}

static int hFindIndex(char *data) {
	if (data < &heap[0]) { return -1; }
	uint off = data - &heap[0];
	if (hHere <= off) { return -1; }
	for (uint32_t i = 0; i < iHere; i++) {
		if (index[i].off == off) { return (int)i; }
	}
	return -1;
}

void hFree(char *data) {
	int hi = hFindIndex(data);
	if (hi == -1) { return; }
	PHEAP x = &index[hi];
	x->inUse = 0;
	while (0 < iHere) {
		x = (PHEAP)&index[iHere - 1];
		if (x->inUse) { break; }
		hHere = x->off;
		x->off = x->sz = 0;
		iHere--;
	}
}

char *hRealloc(char *data, int newSz) {
	int hi = hFindIndex(data);
	if (hi == -1) { return data; }
	PHEAP x = &index[hi];
	uint sz = x->sz;
	if (newSz <= sz) { return data; }
	hFree(data);
	char *y = hAlloc(newSz);
	if ((y) && (y != data)) {
		for (uint i = 0; i < sz; i++) { y[i] = data[i]; }
	}
	return y;
}
