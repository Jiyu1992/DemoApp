//
//  DemoAppTests.swift
//  DemoAppTests
//
//  Created by Lefteris Mantas on 21/2/22.
//

import XCTest
@testable import DemoApp

class DemoAppTests: XCTestCase {
    var sut: URLSession!

    override func setUpWithError() throws {
      try super.setUpWithError()
      sut = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
      sut = nil
      try super.tearDownWithError()
    }
    
    func testGetUsersFromApi() throws {

        let urlString = "https://jsonplaceholder.typicode.com/users"
        let url = URL(string: urlString)!
        
        let promise = expectation(description: "Status code: 200")

        let dataTask = sut.dataTask(with: url) { _, response, error in

            if let error = error {
            
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
    
                    promise.fulfill()
                }
                else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
    }
    
    
    func testGetTodosForAUserFromApi() throws {

        let urlString = "https://jsonplaceholder.typicode.com/todos/?userId=5"
        let url = URL(string: urlString)!
        
        let promise = expectation(description: "Status code: 200")

        let dataTask = sut.dataTask(with: url) { _, response, error in

            if let error = error {
            
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
    
                    promise.fulfill()
                }
                else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
    }
    
    func testInsertingNewUserInCoreData() throws {
        let context = CoreDataManager.sharedInstance.managedContext
        let newUser = User(context: context)
        newUser.id = 1000
        expectation(forNotification: .NSManagedObjectContextDidSave, object: CoreDataManager.sharedInstance.managedContext){_ in return true}
        CoreDataManager.sharedInstance.saveContext()
        waitForExpectations(timeout: 1.0) { error in
           XCTAssertNil(error, "Save didn't happen")
         }
        
        
    }


}
