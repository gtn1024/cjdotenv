package cjdotenv

func indexFunc(s: String, predicate: (Rune) -> Bool) {
    for (i in 0..s.size) {
        if (predicate(Rune(s[i]))) {
            return i
        }
    }

    -1
}
