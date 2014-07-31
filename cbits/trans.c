#include <unicode/utrans.h>
#include <stdio.h>

void *openTrans (const UChar *name, int len)
{
  UErrorCode err = 0;
  UTransliterator *tr = utrans_openU (name, len, UTRANS_FORWARD, 0, -1, 0, &err);

  printf ("trans %p, err=%s\n", tr, u_errorName(err));

  return tr;
}

void closeTrans (UTransliterator *trans)
{
  printf ("close\n");
}

int doTrans (UTransliterator *trans, UChar *text, int len)
{
  UErrorCode err = 0;
  int lim = len;
  utrans_transUChars (trans, text, &len, len, 0, &lim, &err);

  printf ("trans len=%d err=%d\n", len, err);
  printf ("T: %s\n", u_errorName (err));

}

const char *__hs_u_errorName(UErrorCode code)
{
    return u_errorName(code);
}

