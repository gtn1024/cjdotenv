package cjdotenv

import std.collection.HashMap
import std.regex.Regex

const commentChar = r"#"
const singleQuote = r"\'"
const doubleQuote = r"\""
const exportPrefix = "export"

let escapeRegex = Regex("\\\\.")

/**
 * Parse environment variables from a string.
 *
 * @param data The string to parse.
 * @return Key-value pairs of environment variables.
 */
public func parse(data: String) {
    let src = data.replace("\r\n", "\n")

    let vars = HashMap<String, String>()
    parseData(src, vars)

    vars
}

func parseData(src: String, out: HashMap<String, String>): Unit {
    var remain = src

    while (true) {
        remain = getStatementStart(remain)
        if (remain == "") {
            break
        }

        let key: String
        var left: String

        (key, left) = extractKey(remain)

        if (key == "") {
            throw ParseException("Invalid statement near ${remain}")
        }

        let value: String
        (value, left) = extractValue(left, out)

        out[key] = value
        remain = left
    }
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

func extractKey(src: String) {
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

    key = key.trimEnd(isSpace)
    let rem = s[offset..].trimStart(isSpace)
    return (key, rem)
}

func extractValue(src: String, vars: HashMap<String, String>) {
    let hasPrefix = hasQuotePrefix(src)
    if (!hasPrefix) {
        // unquoted cvalue, read until eol
        var eolIndex = indexOfEnter(src)
        if (eolIndex == -1) {
            eolIndex = src.size
        }

        if (eolIndex == 0) {
            return ("", src[eolIndex..])
        }

        let line = src[0..eolIndex]

        var endOfVar = line.size
        if (endOfVar == 0) {
            return ("", src[eolIndex..])
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

        return (expandVariables(trimmed, vars), src[eolIndex..])
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
        var value = src[0..i].trimStart(trimFunc).trimEnd(trimFunc)

        if (quoteChar == doubleQuote) {
            // process escape, variable substitution...
            value = expandVariables(expandEscapes(value), vars)
        }

        return (value, src[i + 1..])
    }

    throw ParseException("Unclosed quote in ${src}")
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

func expandEscapes(src: String) {
    var str = ""
    var lastPos = 0

    let matcher = escapeRegex.matcher(src)
    while (let Some(v) <- matcher.find()) {
        let pos = v.matchPosition()

        str += src[lastPos..pos.start]

        let s = v.matchStr()
        let c = s[1..]
        match (c) {
            case "n" => str += "\n"
            case "r" => str += "\r"
            case _ => str += c
        }

        lastPos = pos.end
    }

    str += src[lastPos..]

    str
}

// (\$)\{?([A-Z0-9_]+)(:.*)?\}?
let expandVarRegex = Regex("(\\$)\\{?([A-Z0-9_]+)(:.*)?\\}?")

func expandVariables(src: String, vars: HashMap<String, String>) {
    var str = ""
    var lastPos = 0

    let matcher = expandVarRegex.matcher(src)
    while (let Some(v) <- matcher.find()) {
        let pos = v.matchPosition()

        str += src[lastPos..pos.start]

        let s = v.matchStr()
        let name: String
        let default: String
        (name, default) = getNameAndDefaultValue(s)

        str += match(vars.get(name)) {
            case Some(v) => v
            case None => default
        }

        lastPos = pos.end
    }

    str += src[lastPos..]

    str
}

func getNameAndDefaultValue(src: String) {
    if (Rune(src[1]) != r"{") {
        // without braces
        return (src[1..], "")
    }

    let pos = src.indexOf(':') ?? -1
    if (pos == -1) {
        // without default value
        return (src[2..src.size - 1], "")
    }

    let name = src[2..pos]
    var default = src[pos + 1..src.size - 1]

    if (default.size > 0) {
        let c = Rune(default[0])
        match (c) {
            case r"-" => default = default[1..]
            case _ => ()
        }
    }

    default = default.trimStart(isSpace).trimEnd(isSpace)

    (name, expandEscapes(default))
}

func hasQuotePrefix(src: String) {
    src.size > 0 && (Rune(src[0]) == singleQuote || Rune(src[0]) == doubleQuote)
}
