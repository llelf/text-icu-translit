#include <stdio.h>
#include <unicode/utrans.h>
#include <unicode/ustring.h>
#include <unicode/ustdio.h>

int main()
{
  UErrorCode err = 0;

  /* UEnumeration *all = utrans_openIDs (&err); */
  /* const char *x; */
  /* while (x = uenum_next (all, 0, &err)) */
  /*   u_printf ("-%s\n", x); */


  UChar name[128];
  u_strFromUTF8 (name, sizeof name, 0, "Katakana-Hiragana", -1, &err);

  UTransliterator *trans = utrans_openU (name, -1, UTRANS_FORWARD, 0, -1, 0, &err);

  UChar text[128];
  u_strFromUTF8 (text, sizeof text, 0, "чебурашка π カタカナ", -1, &err);

  int32_t lim = u_strlen(text);
  utrans_transUChars (trans, text, 0, sizeof text, 0, &lim, &err);
  if (err)
    printf ("T: %s\n", u_errorName(err));

  const UChar *id = utrans_getUnicodeID (trans, &err);
  u_printf ("id=%S\n", id);

  u_printf ("%S\n", text);

}

