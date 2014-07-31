#include <unicode/utrans.h>
#include <stdio.h>

void *openTrans (const UChar *name, int len, UErrorCode *err)
{
  UTransliterator *tr = utrans_openU (name, len, UTRANS_FORWARD, 0, -1, 0, err);

  printf ("trans %p, err=%s\n", tr, u_errorName (*err));

  return tr;
}

void closeTrans (UTransliterator *trans)
{
  printf ("close\n");
}

int32_t doTrans (UTransliterator *trans, UChar *text, int32_t len,
		 int32_t capacity, UErrorCode *err)
{
  int was1 = len, was2 = capacity;
  int lim = len;

  utrans_transUChars (trans, text, &len, capacity, 0, &lim, err);

  printf ("trans len=%d,%d->%d,%d err=%d\n", was1, was2, capacity, lim, *err);
  printf ("T: %s\n", u_errorName (*err));

  return lim;
}

const char *__hs_u_errorName(UErrorCode code)
{
    return u_errorName(code);
}

