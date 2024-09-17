package cjdotenv

public open class DotEnvException <: Exception {
    public init(message: String) {
        super(message)
    }
}

public class PathException <: DotEnvException {
    public let path: String

    public init(path: String, message: String) {
        super(message)
        this.path = path
    }
}

public class ParseException <: DotEnvException {
    public init(message: String) {
        super(message)
    }
}
