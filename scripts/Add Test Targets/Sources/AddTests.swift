import Foundation
import PathKit
import XcodeProj // @tuist ~> 8.0.0

enum Error: Swift.Error {
    case invalidModule
}

private let decoder = JSONDecoder()

/// Run an xcrun command
/// - Parameter command: The command to run, comma separated rather than spaces.
/// - Returns: SDOUT or SDERR contents as Data
private func xcrun(command: String...) -> Data {
    let process = Process()
    let pipe = Pipe()

    process.standardOutput = pipe
    process.standardError = pipe
    process.arguments = command
    process.launchPath = "/usr/bin/xcrun"

    print("⌛️", "xcrun", command.joined(separator: " "))

    process.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    return data
}

/// Minimum data needed from swift package description
private struct Package: Decodable {
    let targets: [Target]

    struct Target: Decodable {
        let name: String
        let type: String
    }
}

/// Extract swift package description
/// - Parameter path: Folder containing swift package
/// - Throws: JSON Decoding errors
/// - Returns: A `Package` struct describing the containing swift package
private func packageDump(path: String) throws -> Package {
    let data = xcrun(command: "swift", "package", "dump-package", "--package-path", "Modules/\(path)")
    var output = String(decoding: data, as: UTF8.self)
    var errorDescription: String?
    if !output.hasPrefix("{"), let bracket = output.firstIndex(of: "{") {
        output = String(output[bracket...])
        errorDescription = String(output[...bracket])
    }
    do {
        return try decoder.decode(Package.self, from: Data(output.utf8))
    } catch {
        print("❌", path)
        print(errorDescription ?? output)
        throw error
    }
}

extension Path {

    /// Check if this path is a swift package
    fileprivate func containsSwiftPackage() throws -> Bool {
        try isDirectory && children().lazy.map(\.lastComponent).contains("Package.swift")
    }

    /// The name of the folder the swift package is in
    fileprivate func swiftPackageModule() throws -> String {
        guard !components.isEmpty else {
            throw Error.invalidModule
        }

        return components[1]
    }

    /// The test targets the swift package contains
    fileprivate func swiftPackageTestTargets() throws -> [String] {
        let module = try swiftPackageModule()
        let package = try packageDump(path: module)
        return package.targets
            .filter { $0.type == "test" }
            .map(\.name)
    }
}

/// Create `xcodeproj` testable references from given modules path
/// - Parameter modules: Directory containing all project modules
/// - Returns: An array of testable references for injecting into a project's schemes.
private func testableReferences(in modules: Path) async throws -> [XCScheme.TestableReference] {
    try await withThrowingTaskGroup(of: [XCScheme.TestableReference].self) { group in

        for path in try modules.children() where try path.containsSwiftPackage() {

            group.addTask {
                let module = try path.swiftPackageModule()
                let targets = try path.swiftPackageTestTargets()
                return targets.reduce(into: [XCScheme.TestableReference]()) { results, target in
                    let reference = XCScheme.BuildableReference(
                        referencedContainer: "container:Modules/\(module)",
                        blueprintIdentifier: target,
                        buildableName: target,
                        blueprintName: target
                    )
                    let testableReference = XCScheme.TestableReference(
                        skipped: false,
                        parallelizable: false,
                        randomExecutionOrdering: true,
                        buildableReference: reference
                    )
                    results.append(testableReference)
                }
            }
        }

        return try await group.reduce(into: [XCScheme.TestableReference]()) { sum, next in
            sum.append(contentsOf: next)
        }
    }
}

func updateVisibleSchemes() throws {
    let username = NSUserName()
    let url = URL(fileURLWithPath: "./Blockchain.xcodeproj/xcuserdata/\(username).xcuserdatad/xcschemes/xcschememanagement.plist")
    let plist = try NSMutableDictionary(contentsOf: url, error: ())
    var state = plist["SchemeUserState"] as! [String: [String: Any]]
    state.removeAll()
    try plist.write(to: url)
}

@main
struct AddTests {

    static func main() async throws {
        print("Adding swift package test targets to schemes")
        do {

            let path = Path("Blockchain.xcodeproj")
            let xcodeproj = try XcodeProj(path: path)
            let modules = Path("Modules")

            let testableReferences = try await testableReferences(in: modules)

            xcodeproj.sharedData?.schemes
                .filter { $0.name.hasPrefix("Blockchain") }
                .forEach { scheme in
                    print("Adding to \(scheme.name)")
                    scheme.testAction?.testables.append(contentsOf: testableReferences)
                }

            try xcodeproj.write(path: path)

            try? updateVisibleSchemes()

            print("Done!")
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
}
