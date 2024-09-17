package cjdotenv

import std.collection.HashMap

struct Tuple<K, V> {
    let first: K
    let second: V

    init(first: K, second: V) {
        this.first = first
        this.second = second
    }
}

const commentChar = r"#"
const singleQuote = r"\'"
const doubleQuote = r"\""
const exportPrefix = "export"

/**
 * Parse environment variables from a string.
 *
 * @param data The string to parse.
 * @return Key-value pairs of environment variables.
 */
public func parse(data: String) {
    let src = data.replace("\r\n", "\n")

    parseData(src)
}

func parseData(src: String) {
    let res = HashMap<String, String>()

    var remain = src

    while (true) {
        remain = getStatementStart(remain)
        if (remain == "") {
            break
        }

        var t = locateKeyName(remain)
        let key = t.first
        var left = t.second
        if (key == "") {
            throw ParseException("Invalid statement near ${remain}")
        }

        t = extractVarValue(left)
        let value = t.first
        left = t.second

        res[key] = value
        remain = left
    }

    res
}

func extractVarValue(src: String) {
    let hasPrefix = hasQuotePrefix(src)
    if (!hasPrefix) {
        // unquoted cvalue, read until eol
        var eolIndex = indexOfEnter(src)
        if (eolIndex == -1) {
            eolIndex = src.size
        }

        if (eolIndex == 0) {
            return Tuple("", src[eolIndex..])
        }

        let line = src[0..eolIndex]

        var endOfVar = line.size
        if (endOfVar == 0) {
            return Tuple("", src[eolIndex..])
        }

        for (i in 0..line.size) {
            let c = Rune(line[i])
            if (c == commentChar && i > 0) {
                if (isSpace(Rune(line[i - 1]))) {
                    endOfVar = i
                    break
                }
            }
        }

        let trimmed = line[0..endOfVar].trimStart(isSpace).trimEnd(isSpace)

        return Tuple(trimmed, src[eolIndex..].trimAsciiStart())
    }

    // find the closing quote
    let quoteChar = Rune(src[0])
    for (i in 1..src.size) {
        if (Rune(src[i]) != quoteChar) {
            continue
        }

        if (Rune(src[i - 1]) == r"\\") {
            continue
        }

        func trimFunc(c: Rune) {
            return c == quoteChar
        }
        let value = src[0..i].trimStart(trimFunc).trimEnd(trimFunc)

        if (quoteChar == doubleQuote) {
            // process escape, variable substitution...
        }

        return Tuple(value, src[i + 1..])
    }

    throw ParseException("Unclosed quote in ${src}")
}

func hasQuotePrefix(src: String) {
    src.size > 0 && (Rune(src[0]) == singleQuote || Rune(src[0]) == doubleQuote)
}

func locateKeyName(src: String) {
    var s = src.trimStart(isSpace)
    if (s.startsWith(exportPrefix)) {
        let tmp = s[exportPrefix.size..]
        if (indexFunc(tmp, isSpace) == 0) {
            s = tmp.trimStart(isSpace)
        }
    }

    var offset = 0
    var key = ""
    for (i in 0..s.size) {
        let c = Rune(s[i])
        if (isSpace(c)) {
            continue
        }

        match(c) {
            case '=' => key = s[0..i]
                        offset = i + 1
                        break
            case ':' => key = s[0..i]
                        offset = i + 1
                        break
            case _ => if (c.isAsciiNumberOrLetter() || c == r"_") {
                continue
            }
            throw ParseException("Unexpected character ${c} in variable name near ${s}")
        }
    }

    key = key.trimAsciiEnd()
    let rem = s[offset..].trimStart(isSpace)
    return Tuple<String, String>(key, rem)
}

func getStatementStart(src: String): String {
    var pos = indexOfNonSpaceChar(src)
    if (pos == -1) {
        return ""
    }

    let rem = src[pos..]
    if (Rune(rem[0]) != commentChar) {
        return rem
    }

    pos = indexOfEnter(rem)
    if (pos == -1) {
        return ""
    }

    return getStatementStart(src[pos..])
}

func indexOfEnter(src: String) {
    let pos = src.indexOf('\n')
    match (pos) {
        case Some(p) => p
        case None => -1
    }
}

func indexOfNonSpaceChar(src: String) {
    for (i in 0..src.size) {
        if (!src[i].isAsciiWhiteSpace()) {
            return i
        }
    }

    return -1
}

func isSpace(c: Rune): Bool {
    [r" ", r"\t", r"\v", r"\f", r"\r"].contains(c)
}
