package cjdotenv

import std.fs.File
import std.collection.HashMap
import std.os.{envVars, setEnv}
import std.fs.FSException

func filenamesOrDefault(filenames: Array<String>) {
    if (filenames.isEmpty()) {
        return [".env"]
    }
    return filenames
}

/**
 * Loads environment variables from the specified filenames.
 *
 * @param filenames to load the environment variables from. If no filenames are provided, `.env` will be used.
 */
public func load(filenames: Array<String>) {
    let newFilenames = filenamesOrDefault(filenames)

    for (filename in newFilenames) {
        loadFile(filename, false)
    }
}

func loadFile(filename: String, overload: Bool) {
    let s = getFileData(filename)
    let envMap = parse(s)

    let currentEnv = HashMap<String, Bool>()
    let rawEnv = envVars()

    for ((k, v) in rawEnv) {
        currentEnv[k] = true
    }

    for ((k, v) in envMap) {
        if (!currentEnv.contains(k) || overload) {
            setEnv(k, v)
        }
    }
}

func getFileData(filename: String) {
    let bytes = try {
        File.readFrom(filename)
    } catch (e: FSException) {
        throw PathException(filename, "File ${filename} does not exist or permission denied!")
    }

    let data = String.fromUtf8(bytes)
    return data
}
