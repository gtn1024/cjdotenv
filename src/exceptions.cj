package cjdotenv

/**
 * The base exception for cjdotenv library.
 */
public open class DotEnvException <: Exception {
    public init(message: String) {
        super(message)
    }
}

/**
 * Exception related to the path of the file.
 */
public class PathException <: DotEnvException {
    public let path: String

    public init(path: String, message: String) {
        super(message)
        this.path = path
    }
}

/**
 * Exception related to the parsing of the file.
 */
public class ParseException <: DotEnvException {
    public init(message: String) {
        super(message)
    }
}
