# EnhancedMirror

An experimental `Mirror` alternative that utilizes Swift Macros for static reflection.

## Features

- Manipulations are done by compile-time generated code, no additional metadata hacks are required.
- Ordered enumeration supports for field members.
- Fields of both `struct` and `class` can be modified.

## Quick Start

> **Note:** Swift 5.9 is in preview, and not yet stable.

To use `EnhancedMirror` in your project, add this repository to the `Package.swift` manifest:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/unixzii/EnhancedMirror.git", from: "0.1.0"),
  ],
  targets: [
    .target(name: "MyApp", dependencies: [
      .product(name: "EnhancedMirror", package: "EnhancedMirror"),
    ]),
  ]
)
```

### Add annotation

To make a type inspectable at run-time, you can place `@RuntimeInspectable` macro at your type declaration:

```swift
@RuntimeInspectable
struct Product {
    let modelName: String
    var price: Int

    // ...
}
```

### Use reflection APIs

An inspectable type conforms to `RuntimeInspectable` protocol, and you can use the APIs that protocol exposes:

```swift
let product = Product(...)

let priceField = product.field(named: "price")!

// Read the field value:
print(priceField.value)

// Write the field value:
priceField.write(999)
```

See [`RuntimeInspectable`](./Sources/EnhancedMirror/RuntimeInspectable.swift) for the full APIs.

## Notices

### Lifetime of the field accessor

The field accessor doesn't retain a copy of value-type values. You must not make it outlive the inspected value, or the memory corruption may happen. For reference-type values, there are no such restrictions because the inspected values are strongly retained.

### Project completeness

The project is not complete in current stage, but the important building blocks (accessing the value) are done. Some high-level APIs need to be designed for more ergonomic developer experience, such as recursive (de)serialization, field annotation, etc. Those features may be deferred until the stable version of Swift 5.9 releases.

While the project is at the experimental stage, you can still try it for any non-production usage.

## License

Licensed under MIT License, see [LICENSE](./LICENSE) for more information.
