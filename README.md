ICU transliteration for Haskell

    >>> IO.putStrLn $ transliterate (trans "name-any; ru") "\\N{RABBIT FACE} Nu pogodi!"
    🐰 Ну погоди!

    >>> IO.putStrLn $ transliterate (trans "nl-title") "gelderse ijssel"
    Gelderse IJssel

    >>> IO.putStrLn $ transliterate (trans "ja") "Amsterdam"
    アムステルダム

