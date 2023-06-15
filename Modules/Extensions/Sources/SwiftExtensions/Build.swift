public enum BuildFlag {
    public static var isAlpha: Bool = false
    public static var isInternal: Bool = false
    public static var isProduction: Bool { !isInternal }
}
