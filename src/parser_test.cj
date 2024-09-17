package cjdotenv

import std.unittest.*
import std.unittest.testmacro.*

func parseAndCompare(rawLine: String, expectedKey: String, expectedValue: String) {
    let map = parse(rawLine)

    @Expect(map.contains(expectedKey))
    @Expect(map.size, 1)

    let value = map[expectedKey]
    @Expect(value, expectedValue)
}

@Test
func testParseInvalidLine() {
    let s = "INVALID LINE"
    @ExpectThrows[ParseException](parse(s))
}

@Test
func testUnquotedValues() {
    let s = "FOO=bar"
    parseAndCompare(s, "FOO", "bar")
}

@Test
func testValuesWithEmptyAround() {
    parseAndCompare("FOO=bar", "FOO", "bar")
    parseAndCompare(" FOO=bar", "FOO", "bar")
    parseAndCompare("FOO =bar", "FOO", "bar")
    parseAndCompare(" FOO =bar", "FOO", "bar")
    parseAndCompare("FOO= bar", "FOO", "bar")
    parseAndCompare(" FOO= bar", "FOO", "bar")
    parseAndCompare("FOO = bar", "FOO", "bar")
    parseAndCompare(" FOO = bar", "FOO", "bar")
    parseAndCompare("FOO=bar ", "FOO", "bar")
    parseAndCompare(" FOO=bar ", "FOO", "bar")
    parseAndCompare("FOO =bar ", "FOO", "bar")
    parseAndCompare(" FOO =bar ", "FOO", "bar")
    parseAndCompare("FOO= bar ", "FOO", "bar")
    parseAndCompare(" FOO= bar ", "FOO", "bar")
    parseAndCompare("FOO = bar ", "FOO", "bar")
    parseAndCompare(" FOO = bar ", "FOO", "bar")

    parseAndCompare("\tFOO=bar", "FOO", "bar")
    parseAndCompare("FOO=\tbar", "FOO", "bar")
    parseAndCompare("\tFOO=\tbar", "FOO", "bar")
    parseAndCompare("\tFOO=\tbar\t", "FOO", "bar")
    parseAndCompare("\tFOO=\tbar\t ", "FOO", "bar")
    parseAndCompare("\tFOO=\tbar \t", "FOO", "bar")
    parseAndCompare("\tFOO=\t bar", "FOO", "bar")
    parseAndCompare("\tFOO=\t bar ", "FOO", "bar")
    parseAndCompare("\tFOO=\t bar\t", "FOO", "bar")
    parseAndCompare("\tFOO=\t bar\t ", "FOO", "bar")
    parseAndCompare("\tFOO=\t bar \t", "FOO", "bar")
    parseAndCompare("\tFOO=\tbar", "FOO", "bar")
}

@Test
func testValuesWithSingleQuote() {
    parseAndCompare("FOO='bar'", "FOO", "bar")
    parseAndCompare("FOO=' bar'", "FOO", " bar")
    parseAndCompare("FOO='bar '", "FOO", "bar ")
    parseAndCompare("FOO=' bar '", "FOO", " bar ")
}

@Test
func testValuesWithDoubleQuote() {
    parseAndCompare("FOO=\"bar\"", "FOO", "bar")
    parseAndCompare("FOO=\" bar\"", "FOO", " bar")
    parseAndCompare("FOO=\"bar \"", "FOO", "bar ")
    parseAndCompare("FOO=\" bar \"", "FOO", " bar ")
}

@Test
func testValuesWithDoubleQuotesInside() {
    // FOO="excaped\"bar"
    parseAndCompare("FOO=\"excaped\\\"bar\"", "FOO", "excaped\"bar")
}

@Test
func testValuesWithSingleQuotesInside() {
    // FOO='excaped\'bar'
    parseAndCompare("FOO='excaped\\'bar'", "FOO", "excaped\\'bar")
}

@Test
func testValuesWithNewline() {
    // FOO="bar\nbaz"
    parseAndCompare("FOO=\"bar\\nbaz\"", "FOO", "bar\nbaz")
}

@Test
func testParseExported() {
    parseAndCompare("export FOO=bar", "FOO", "bar")
    parseAndCompare("export FOO='bar'", "FOO", "bar")
    parseAndCompare("export FOO=\"bar\"", "FOO", "bar")
    parseAndCompare("export FOO=\"bar\\nbaz\"", "FOO", "bar\nbaz")
    parseAndCompare("export FOO='excaped\\'bar'", "FOO", "excaped\\'bar")
    parseAndCompare("export FOO= bar", "FOO", "bar")
    parseAndCompare("  export FOO=bar", "FOO", "bar")
    parseAndCompare("\t export FOO=bar ", "FOO", "bar")
}

@Test
func testEmptyValue() {
    parseAndCompare("FOO=", "FOO", "")
    parseAndCompare("FOO= ", "FOO", "")
    parseAndCompare("FOO=  ", "FOO", "")
    parseAndCompare("FOO=\t", "FOO", "")
    parseAndCompare("FOO=''", "FOO", "")
    parseAndCompare("FOO=\"\"", "FOO", "")
}
