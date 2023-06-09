/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

fileprivate extension VariableDeclSyntax {
    var isReadonlyField: Bool {
        if case .keyword(Keyword.let) = bindingKeyword.tokenKind {
            return true
        }
        
        guard let binding = bindings.first else {
            fatalError("compiler bug: expected a binding from VariableDeclSyntax")
        }
        
        guard let accessors =
                binding.accessor?.as(AccessorBlockSyntax.self)?.accessors else {
            // `var` declarations without accessors should not be readonly.
            return false
        }
        
        // Search for the setter for the field to be read-write.
        for accessor in accessors {
            if case .keyword(Keyword.set) = accessor.accessorKind.tokenKind {
                return false
            }
        }
        
        // Setter is not found, the field is read-only.
        return true
    }

    var fieldName: String {
        guard let binding = bindings.first else {
            fatalError("compiler bug: expected a binding from VariableDeclSyntax")
        }
        
        guard let ident = binding.pattern.as(IdentifierPatternSyntax.self) else {
            fatalError("compiler bug: unknown binding pattern (\(binding.pattern))")
        }
        
        return ident.identifier.text
    }
}

public struct RuntimeInspectableMacro: MemberMacro, ConformanceMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let isValueType =
            (declaration.as(StructDeclSyntax.self) != nil) ||
            (declaration.as(EnumDeclSyntax.self) != nil)
        
        let fieldMembers = declaration.memberBlock.members.compactMap {
            return $0.decl.as(VariableDeclSyntax.self)
        }
        
        // Synthesize `allFieldNames` implementation.
        let fieldNames = fieldMembers.map(\.fieldName)
        let allFieldNamesDecl: DeclSyntax =
            """
            var allFieldNames: AnyCollection<String> {
                return AnyCollection(\(literal: fieldNames))
            }
            """
        
        // Synthesize `field(named:)` implementation.
        let fieldNamedMethodDecl = synthesizeFieldNamedMethod(
            with: fieldMembers,
            usingUnsafePointer: isValueType
        )
        
        return [allFieldNamesDecl, fieldNamedMethodDecl]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        return [("RuntimeInspectable", nil)]
    }
    
    private static func synthesizeFieldNamedMethod(
        with fieldMembers: [VariableDeclSyntax],
        usingUnsafePointer: Bool
    ) -> DeclSyntax {
        let branches = fieldMembers.map {
            let fieldName = $0.fieldName
            
            let writerExpr: ExprSyntax = if $0.isReadonlyField {
                .init(NilLiteralExprSyntax())
            } else if usingUnsafePointer {
                """
                {
                    pointer.pointee.\(raw: fieldName) = $0
                }
                """
            } else {
                """
                {
                    self.\(raw: fieldName) = $0
                }
                """
            }
            
            let stmt: StmtSyntax = if usingUnsafePointer {
                """
                if name == \(literal: fieldName) {
                    return withUnsafeMutablePointer(to: &self) { pointer in
                        return FieldAccessor(
                            type: type(of: pointer.pointee.\(raw: fieldName)),
                            name: \(literal: fieldName),
                            reader: {
                                return pointer.pointee.\(raw: fieldName)
                            },
                            writer: \(writerExpr)
                        )
                    }
                }
                """
            } else {
                """
                if name == \(literal: fieldName) {
                    return FieldAccessor(
                        type: type(of: self.\(raw: fieldName)),
                        name: \(literal: fieldName),
                        reader: {
                            return self.\(raw: fieldName)
                        },
                        writer: \(writerExpr)
                    )
                }
                """
            }
            
            return stmt
        }
        
        let mutatingKeyword = if usingUnsafePointer {
            TokenSyntax.keyword(.mutating)
        } else {
            TokenSyntax.unknown("")
        }
        
        let methodDecl: DeclSyntax =
            """
            \(mutatingKeyword) func field(named name: String) -> FieldAccessing? {
                \(CodeBlockItemListSyntax(branches.map {
                    .init(item: .stmt($0))
                }))
                return nil
            }
            """
        
        return methodDecl
    }
}

@main
struct EnhancedMirrorPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RuntimeInspectableMacro.self,
    ]
}
