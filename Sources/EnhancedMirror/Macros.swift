/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

/// A macro that implements `RuntimeInspectable` protocol for the attached type.
@attached(member, names: named(allFieldNames), named(field(named:)))
@attached(extension, conformances: RuntimeInspectable)
public macro RuntimeInspectable() = #externalMacro(module: "EnhancedMirrorMacros", type: "RuntimeInspectableMacro")
