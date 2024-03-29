//
//  DebugConfig.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation

final class Config {

	static let httpClient: DebugHTTPClient = DebugHTTPClient(urlSession: URLSession(configuration: .ephemeral))

	// Debug user could change environment in Settings app
	// then we could get the current environment using UserDefaults.
	// Currently, the environment is different for unit tests.
	static var environment: ServerEnvironment = ServerEnvironment.localApp

	static var isRunningUnitTests: Bool {
		UserDefaults.standard.bool(forKey: "isRunningUnitTests")
	}

	static var isRunningUITests: Bool {
		ProcessInfo.processInfo.arguments.contains("-runningUITests")
	}

	static var isRunningWithoutTests: Bool {
		!isRunningUnitTests && !isRunningUITests
	}
}
#endif
