//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Dmitfre on 12.08.2023.
//

import XCTest

//MARK: - синхронные тесты

/*struct ArithmeticOperations {
    
    func addition(num1: Int, num2: Int) -> Int {
        return num1 + num2
    }
    
    func subtraction(num1: Int, num2: Int) -> Int {
        return num1 - num2
    }
    
    func multiplication(num1: Int, num2: Int) -> Int {
        return num1 * num2
    }
}

final class MovieQuizTests: XCTestCase {

    func testAddition() throws {
        
        /// Given
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        
        /// When
        let result = arithmeticOperations.addition(num1: num1, num2: num2)
        
        /// Then
        XCTAssertEqual(result, 3)
    }
}
*/
//MARK: - асинхронные тесты

struct ArithmeticOperationsAsinch {
    
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 + num2)
            }
        }
        
        func subtraction(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 - num2)
            }
        }
        
        func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                handler(num1 * num2)
            }
        }
    }

final class MovieQuizAsinchTests: XCTestCase {
    
    func testAddition() throws {
        // Given
        let arithmeticOperations = ArithmeticOperationsAsinch()
        let num1 = 1
        let num2 = 2
        
        // When
        let expectation = expectation(description: "Addition function expectation")
       
       arithmeticOperations.addition(num1: num1, num2: num2) { result in
            // Then
            XCTAssertEqual(result, 3)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
}
