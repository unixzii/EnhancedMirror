/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

/// An interface for accessing the metadata of a type field.
public protocol FieldAccessing {
    
    /// The name of the inspected field.
    var name: String { get }
    
    /// The type-erased value of the inspected field.
    var value: Any { get }
    
    /// The static type of the inspected field.
    var type: Any.Type { get }
    
    /// A Boolean value indicating whether the inspected field is read-only.
    var isReadonly: Bool { get }
    
    /// Modifies the inspected field to the given value.
    ///
    /// - Parameter value: The new value to be written to the inspected field.
    /// - Returns: A Boolean value indicating whther the modification is successful.
    ///            `false` when the field is read-only or type of the new value can
    ///            not be casted to the field type.
    nonmutating func write(_ value: Any) -> Bool
}

// Make it public for macros to access, should not be used by client code.
public struct FieldAccessor<T>: FieldAccessing {
    public let _name: String
    public let _reader: () -> T
    public let _writer: ((T) -> ())?
    
    public var name: String {
        return _name
    }
    
    public var value: Any {
        return _reader()
    }
    
    public var type: Any.Type {
        return T.self
    }
    
    public var isReadonly: Bool {
        return _writer == nil
    }
    
    public init(
        type: T.Type,
        name: String,
        reader: @escaping () -> T,
        writer: ((T) -> ())?
    ) {
        let _ = type  // For type inference only.
        self._name = name
        self._reader = reader
        self._writer = writer
    }
    
    public func write(_ value: Any) -> Bool {
        guard let writer = _writer else {
            return false
        }
        guard let castedValue = value as? T else {
            return false
        }
        writer(castedValue)
        return true
    }
}
