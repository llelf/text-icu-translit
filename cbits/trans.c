#include <unicode/utrans.h>
#include <stdio.h>

void *openTrans (const UChar *name)
{
  UErrorCode err = 0;
  UTransliterator *tr = utrans_openU (name, -1, UTRANS_FORWARD, 0, -1, 0, &err);

  printf ("trans %p\n", tr);

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
  utrans_transUChars (trans, text, 0, len, 0, &lim, &err);

}


