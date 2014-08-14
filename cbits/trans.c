#include <unicode/utrans.h>
#include <stdio.h>
#include "trans.h"

void *
__hs_translit_open_trans (const UChar *name, int len, UErrorCode *err)
{
  UTransliterator *tr = utrans_openU (name, len, UTRANS_FORWARD, 0, -1, 0, err);

  /* printf ("trans %p, err=%s\n", tr, u_errorName (*err)); */

  return tr;
}

void
__hs_translit_close_trans (UTransliterator *trans)
{
  /* printf ("close\n"); */
  utrans_close (trans);
}

int32_t
__hs_translit_do_trans (UTransliterator *trans, UChar *text, int32_t len,
			 int32_t capacity, UErrorCode *err)
{
  /* int len0 = len; */
  int lim = len;

  utrans_transUChars (trans, text, &len, capacity, 0, &lim, err);

  /* printf ("trans len=lim=%d cap=%d -> len=%d lim=%d err=%d\n", */
  /* 	  len0, capacity, len, lim, *err); */
  /* printf ("T: %s\n", u_errorName (*err)); */

  return lim;
}


const char *
__hs_translit_u_errorName (UErrorCode code)
{
    return u_errorName(code);
}

