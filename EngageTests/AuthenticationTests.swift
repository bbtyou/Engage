//
//  AuthenticationTests.swift
//  EngageTests
//
//  Created by Charles Imperato on 2/20/19.
//  Copyright © 2019 PerpetuityMD. All rights reserved.
//

import XCTest
import wvslib
@testable import Engage

class AuthenticationTests: XCTestCase {

    class LoginMockView: LoginDelegate {
        func loginCompleted() {
            Current.log().debug("Login completed successfully")
            AuthenticationTests.loginComplete = true
        }
        
        func loginFailed(_ message: String) {
            Current.log().debug("Login failed")
            AuthenticationTests.loginFail = true
        }
        
        func navigate(_ identifier: String, _ presenter: DrawerPresenter) {
            XCTAssert(identifier == "home")
            home = true
        }
    }
    
    let view = LoginMockView()
    
    // - Check the login completed method was called
    static var loginComplete: Bool = false
    static var loginFail: Bool = false
    static var home: Bool = false
    
    override func setUp() {
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoginSuccess() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let loginSuccess = Login(success: true, failure: nil)
        let auth = Authentication { (username, password, result) in
            result(.success(loginSuccess))
        }
        
        Current.auth = { auth }
        
        let presenter = LoginPresenter.init()
        presenter.delegate = view
        presenter.login("test", password: "password")
        XCTAssert(AuthenticationTests.loginComplete)
        XCTAssert(AuthenticationTests.home)
    }
    
    func testLoginFailed() {
        let error = RestClientError.unauthorized
        let auth = Authentication { (username, password, result) in
            result(.failure(error))
        }
        
        Current.auth = { auth }
        
        let presenter = LoginPresenter.init()
        presenter.delegate = view
        presenter.login("test", password: "password")
        XCTAssert(AuthenticationTests.loginFail)
    }
}
