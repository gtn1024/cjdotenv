package cjdotenv

import std.unittest.*
import std.unittest.testmacro.*
import std.os.*
import std.collection.*

@When[os == "Windows"]
let emptyString = None<String>

@When[os != "Windows"]
let emptyString = ""

func clearenv() {
    for (key in envVars().keys()) {
        removeEnv(key)
    }

    @Expect(envVars().size, 0)
}

@Test
func testLoadWithNoArgsLoadsDotEnv() {
    let e: PathException = @AssertThrows[PathException](load())
    @Expect(e.path, ".env")
}

@Test
func testReadmeExample() {
    clearenv()
    let filename = "fixtures/readme.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["DB_HOST"] = "localhost"
    expectedValues["DB_USER"] = "postgres"
    expectedValues["DB_PASS"] = "123456"
    expectedValues["DB_DATABASE"] = "postgres"

    @Expect(envVars().size, 4)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testComments() {
    clearenv()
    let filename = "fixtures/comments.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["foo"] = "bar"
    expectedValues["bar"] = "foo#baz"
    expectedValues["baz"] = "foo"

    @Expect(envVars().size, 3)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testEquals() {
    clearenv()
    let filename = "fixtures/equals.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["OPTION_A"] = "postgres://localhost:5432/database?sslmode=disable"

    @Expect(envVars().size, 1)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testExported() {
    clearenv()
    let filename = "fixtures/exported.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["OPTION_A"] = "2"
    expectedValues["OPTION_B"] = "\\n"

    @Expect(envVars().size, 2)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testInvalid() {
    clearenv()
    let filename = "fixtures/invalid1.env"
    @ExpectThrows[ParseException](load(filename))
}

@Test
func testPlain() {
    clearenv()

    let filename = "fixtures/plain.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["OPTION_A"] = "1"
    expectedValues["OPTION_B"] = "2"
    expectedValues["OPTION_C"] = "3"
    expectedValues["OPTION_D"] = "4"
    expectedValues["OPTION_E"] = "5"
    expectedValues["OPTION_F"] = emptyString
    expectedValues["OPTION_G"] = emptyString
    expectedValues["OPTION_H"] = "1 2"

    var expected = 0
    for ((_, v) in expectedValues) {
        if (v != None) {
            expected++
        }
    }

    @Expect(envVars().size, expected)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testQuoted() {
    clearenv()
    let filename = "fixtures/quoted.env"
	load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["OPTION_A"] = "1"
    expectedValues["OPTION_B"] = "2"
    expectedValues["OPTION_C"] = emptyString
    expectedValues["OPTION_D"] = "\\n"
    expectedValues["OPTION_E"] = "1"
    expectedValues["OPTION_F"] = "2"
    expectedValues["OPTION_G"] = emptyString
    expectedValues["OPTION_H"] = "\n"
    expectedValues["OPTION_I"] = "echo 'asd'"
    expectedValues["OPTION_J"] = "line 1\nline 2"
    expectedValues["OPTION_K"] = "line one\nthis is \\'quoted\\'\none more line"
    expectedValues["OPTION_L"] = "line 1\nline 2"
    expectedValues["OPTION_M"] = "line one\nthis is \"quoted\"\none more line"

    var expected = 0
    for ((_, v) in expectedValues) {
        if (v != None) {
            expected++
        }
    }

    @Expect(envVars().size, expected)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}

@Test
func testSubstitutions() {
    clearenv()
    let filename = "fixtures/substitutions.env"
    load(filename)

    let expectedValues = HashMap<String, ?String>()
    expectedValues["OPTION_A"] = "1"
    expectedValues["OPTION_B"] = "1"
    expectedValues["OPTION_C"] = "1"
    expectedValues["OPTION_D"] = "11"
    expectedValues["OPTION_E"] = emptyString
    expectedValues["OPTION_F"] = "default"
    expectedValues["OPTION_G"] = "default"
    expectedValues["OPTION_H"] = "-default"
    expectedValues["OPTION_I"] = "-default"
    expectedValues["OPTION_J"] = "\\-default"
    expectedValues["OPTION_K"] = "-default"
    expectedValues["OPTION_L"] = "default value"
    expectedValues["OPTION_N"] = "default"
    expectedValues["OPTION_M"] = "default"

    var expected = 0
    for ((_, v) in expectedValues) {
        if (v != None) {
            expected++
        }
    }

    @Expect(envVars().size, expected)
    for ((k, v) in expectedValues) {
        @Expect(getEnv(k), v)
    }
}
