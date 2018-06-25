//
//  ZypeUITests.swift
//  ZypeUITests
//
//  Created by Andy Zheng on 6/22/18.
//  Copyright © 2018 Zype. All rights reserved.
//

import XCTest

class ZypeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFastlaneSnapshot() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        let collectionViewsQuery = app.collectionViews

        var alertExists = app.alerts.element(boundBy: 0).exists
        if (alertExists) {
            app.alerts.element(boundBy: 0).buttons["Don't Allow"].tap()
        }
        alertExists = app.alerts.element(boundBy: 0).exists
        if (alertExists) {
            app.alerts.element(boundBy: 0).buttons["Don't Allow"].tap()
        }
        
        // First screenshot - Home Screen
        snapshot("01HomeScreen")
        
        // Second screenshot - First Playlist
        let isIpadDevice = (UIDevice.current.userInterfaceIdiom == .pad)
        if isIpadDevice {
            collectionViewsQuery.cells.element(boundBy: 0).tap()
        } else {
            tablesQuery.cells.element(boundBy: 0).tap()
        }
        snapshot("02Playlist")
        
        // Third screenshot - Settings Screen
        app.navigationBars.element(boundBy: 0).buttons["Back"].tap()
        app.tabBars.buttons["More"].tap()
        snapshot("03Settings")

        // Fourth screenshot - Sign In Screen
        app.buttons["SIGN IN"].tap()
        snapshot("04SignInScreen")
        app.buttons["universal gray cancel"].tap()

    }
    
}
