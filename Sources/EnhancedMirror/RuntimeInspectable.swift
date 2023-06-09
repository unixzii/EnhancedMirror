/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

/// A type that can be inspected at run-time.
public protocol RuntimeInspectable {
    
    /// A collection of String elements representing the name of each field.
    var allFieldNames: AnyCollection<String> { get }
    
    /// Returns a field accessor for the field of the given name.
    ///
    /// - Parameter name: Name of the field to retrieve.
    /// - Returns: The field accessor, `nil` if the field is not found.
    mutating func field(named name: String) -> FieldAccessing?
}
