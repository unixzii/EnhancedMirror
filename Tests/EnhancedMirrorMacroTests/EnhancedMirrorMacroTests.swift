/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import EnhancedMirrorMacros

let testMacros: [String: Macro.Type] = [
    "RuntimeInspectable": RuntimeInspectableMacro.self,
]

final class EnhancedMirrorMacroTests: XCTestCase {
    func testStruct() {
        assertMacroExpansion(
            """
            @RuntimeInspectable
            struct MyType {
                var foo: Int
                var bar: String {
                    return "hello"
                }
                var bar2: String {
                    get {
                        return "world"
                    }
                    set {
                        print(newValue)
                    }
                }
                let baz = true
                
                func myFunction() {
                }
            }
            """,
            expandedSource:
            """
            
            struct MyType {
                var foo: Int
                var bar: String {
                    return "hello"
                }
                var bar2: String {
                    get {
                        return "world"
                    }
                    set {
                        print(newValue)
                    }
                }
                let baz = true
                
                func myFunction() {
                }
                var allFieldNames: AnyCollection<String> {
                    return AnyCollection(["foo", "bar", "bar2", "baz"])
                }
                mutating func field(named name: String) -> FieldAccessing? {
                    if name == "foo" {
                        return withUnsafeMutablePointer(to: &self) { pointer in
                            return FieldAccessor(
                                type: type(of: pointer.pointee.foo),
                                name: "foo",
                                reader: {
                                    return pointer.pointee.foo
                                },
                                writer: {
                        pointer.pointee.foo = $0
                    }
                            )
                        }
                    }
                if name == "bar" {
                        return withUnsafeMutablePointer(to: &self) { pointer in
                            return FieldAccessor(
                                type: type(of: pointer.pointee.bar),
                                name: "bar",
                                reader: {
                                    return pointer.pointee.bar
                                },
                                writer: {
                        pointer.pointee.bar = $0
                    }
                            )
                        }
                    }
                if name == "bar2" {
                        return withUnsafeMutablePointer(to: &self) { pointer in
                            return FieldAccessor(
                                type: type(of: pointer.pointee.bar2),
                                name: "bar2",
                                reader: {
                                    return pointer.pointee.bar2
                                },
                                writer: {
                        pointer.pointee.bar2 = $0
                    }
                            )
                        }
                    }
                if name == "baz" {
                        return withUnsafeMutablePointer(to: &self) { pointer in
                            return FieldAccessor(
                                type: type(of: pointer.pointee.baz),
                                name: "baz",
                                reader: {
                                    return pointer.pointee.baz
                                },
                                writer: nil
                            )
                        }
                    }
                    return nil
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testClass() {
        assertMacroExpansion(
            """
            @RuntimeInspectable
            class MyClass {
                var foo: Int
            }
            """,
            expandedSource:
            """
            
            class MyClass {
                var foo: Int
                var allFieldNames: AnyCollection<String> {
                    return AnyCollection(["foo"])
                }
             func field(named name: String) -> FieldAccessing? {
                if name == "foo" {
                    return FieldAccessor(
                        type: type(of: self.foo),
                        name: "foo",
                        reader: {
                            return self.foo
                        },
                        writer: {
                    self.foo = $0
                }
                    )
                }
                return nil
                }
            }
            """,
            macros: testMacros
        )
    }
}
