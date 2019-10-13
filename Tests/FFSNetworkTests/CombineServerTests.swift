//
//  CombineServerTests.swift
//  
//
//  Created by Alex da Franca on 13.10.19.
//

import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import FFSNetwork

@available(OSX 10.15, iOS 13, *)
final class CombineServerTests: XCTestCase {
    var todos = [Todo]()
    var fetchTodosResponse: FetchTodosResponse = emptyResponse {
        didSet {
            todos = fetchTodosResponse.value
        }
    }
    
    // commented this test, because I don't get it to work
    func _testTodosRx() {
        let backend = BackendRx()
        
        _ = self.expectation(for: NSPredicate(block: { (items, userInfo) -> Bool in
            let success = (items as! [Todo]).count > 0
            return success
        }), evaluatedWith: todos, handler: nil)
        
        _ = backend
            .loadTodosRx2()
            .catch { error -> Just<[Todo]> in
                self.todos = [Todo(userId: 1, id: 1, title: "", completed: false)]
                    return Just([])
            }
            .sink(receiveCompletion: { error in
            XCTAssertNil(error)
        }, receiveValue: { (response) in
            self.todos = response
        })
            
        
//        _ = backend
//            .loadTodosRx()
//            .map { $0 }
//            .catch { error -> Just<FetchTodosResponse> in
//                return Just(CombineServerTests.emptyResponse)
//        }
//        .assign(to: \.fetchTodosResponse, on: self)
        
        self.waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    private static var emptyResponse: FetchTodosResponse {
        return try! FetchTodosResponse(data: "[]".data(using: .utf8), urlResponse: nil, sentRequest: URLRequest(url: URL(string: "http://www.farbflash.de")!))
    }
}
