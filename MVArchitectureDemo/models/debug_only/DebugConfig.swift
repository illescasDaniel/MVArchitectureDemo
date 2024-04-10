//
//  DebugConfig.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation
import DIC

final class Config {

	static let networkDelayInMilliseconds: Int = 200

	static var isRunningUnitTests: Bool {
		UserDefaults.standard.bool(forKey: "isRunningUnitTests")
	}

	static var isRunningUITests: Bool {
		ProcessInfo.processInfo.arguments.contains("-runningUITests")
	}

	static var isRunningWithoutTests: Bool {
		!isRunningUnitTests && !isRunningUITests
	}

	static var isSwiftUIPreviewRunning: Bool {
		ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
	}
}
#endif
