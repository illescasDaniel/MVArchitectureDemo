//
//  XCTestCase+App.swift
//  MVArchitectureDemoUITests
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import XCTest

extension XCUIApplication {
	func launchWithArgs() {
		launchArguments += ["-runningUITests"]
		launch()
	}
}
