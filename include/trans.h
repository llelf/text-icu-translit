
void *__hs_translit_open_trans (const UChar *name, int len, UErrorCode *err);
void __hs_translit_close_trans (UTransliterator *trans);

int32_t __hs_translit_do_trans (UTransliterator *trans,
				UChar *text, int32_t len,
				int32_t capacity, UErrorCode *err);

const char *__hs_translit_u_errorName (UErrorCode code);


