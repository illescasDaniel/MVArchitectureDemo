//
//  DelayDisabledTests.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 10/10/23.
//

import XCTest
@testable import MVArchitectureDemo

final class DelayDisabledTests: MVXCTestCase {
	
	func testIsDelayDisabled() async throws {
		XCTAssertFalse(Config.isNetworkDelayEnabled)
	}
}
