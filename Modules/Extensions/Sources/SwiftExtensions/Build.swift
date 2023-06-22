public enum BuildFlag {
    public static var isAlpha: Bool = false
    #if DEBUG
    public static var isInternal: Bool = true
    #else
    public static var isInternal: Bool = false
    #endif
    public static var isProduction: Bool { !isInternal }
}
