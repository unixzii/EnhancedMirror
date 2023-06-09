/*
 This source file is part of EnhancedMirror

 Copyright (c) 2023 Cyandev and project authors
 Licensed under MIT License
*/

import XCTest
import EnhancedMirror

@RuntimeInspectable
struct Product {
    let modelName: String
    var price: Int
    
    func introduce() {
    }
}

@RuntimeInspectable
class Store {
    var products: [Product]
    
    init() {
        self.products = [
            .init(modelName: "MacBook Air 15", price: 1299)
        ]
    }
}

final class EnhancedMirrorTests: XCTestCase {
    func testAllFieldNames() {
        let visionPro = Product(modelName: "Vision Pro", price: 3499)
        
        XCTAssertEqual(
            Array<String>(visionPro.allFieldNames),
            ["modelName", "price"]
        )
    }
    
    func testReadAndWrite() {
        var visionPro = Product(modelName: "Vision Pro", price: 3499)
        
        guard let nameField = visionPro.field(named: "modelName") else {
            XCTFail("Expected `modelName` field")
            return
        }
        XCTAssertTrue(nameField.isReadonly)
        XCTAssertEqual(nameField.value as! String, "Vision Pro")
        XCTAssertFalse(nameField.write("Mac Pro"))
        
        guard let priceField = visionPro.field(named: "price") else {
            XCTFail("Expected `price` field")
            return
        }
        XCTAssertTrue(priceField.write(799))
        XCTAssertEqual(visionPro.price, 799)
    }
    
    func testProtocolConformance() {
        let visionPro = Product(modelName: "Vision Pro", price: 3499)
        
        XCTAssertNotNil(visionPro as Any as? RuntimeInspectable)
    }
    
    func testReferenceType() {
        let store = Store()
        
        guard let productsField = store.field(named: "products"),
              var stocks = productsField.value as? [Product] else {
            XCTFail("Expected `products` field")
            return
        }
        XCTAssertEqual(stocks.isEmpty, false)
        XCTAssertEqual(stocks.first!.modelName, "MacBook Air 15")
        
        stocks.append(.init(modelName: "Vision Pro", price: 3499))
        XCTAssertTrue(productsField.write(stocks))
        
        XCTAssertEqual(store.products.count, 2)
        XCTAssertEqual(store.products[1].price, 3499)
    }
}
