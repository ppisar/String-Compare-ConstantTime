#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"



static int do_compare(unsigned char *a, size_t a_len, unsigned char *b, size_t b_len) {
  size_t i;
  unsigned char *s;
  unsigned char r;
  uintptr_t mask;

  /* Orchestrate a dummy compare which never matches and whose run-time does
   * not stand out if a_len != b_len */
  r = (a_len != b_len);
  /* Branching-less: s = (r) ? b : a */
  mask = (uintptr_t)0u - r;
  s = (unsigned char *)(((uintptr_t)b & mask) | ((uintptr_t)a & ~mask));

  for (i = 0; i < b_len; i++) {
    r |= *s++ ^ *b++;
  }

  return r;
}



MODULE = String::Compare::ConstantTime		PACKAGE = String::Compare::ConstantTime

PROTOTYPES: ENABLE



int
equals(a, b)
        SV *a
        SV *b
    CODE:
        size_t alen;
        unsigned char *ap;
        size_t blen;
        unsigned char *bp;
        int r;

        SvGETMAGIC(a);
        SvGETMAGIC(b);

        if (SvOK(a) && SvOK(b)) {
          ap = SvPV(a, alen);
          bp = SvPV(b, blen);

          r = !do_compare(ap, alen, bp, blen);
        } else if (SvOK(a) || SvOK(b)) {
          r = 0;
        } else {
          r = 1;
        }

        RETVAL = r;

    OUTPUT:
        RETVAL
