//
//  DebugConfig.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation

final class Config {

	static let mockInterceptor: MockRequestHTTPInterceptor = MockRequestHTTPInterceptor()
	static let httpClient: HTTPClient = HTTPClientImpl(
		urlSession: URLSession(configuration: .ephemeral),
		interceptors: [Config.mockInterceptor, RequestLoggerHTTPInterceptor()]
	)

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

	static var isSwiftUIPreviewRunning: Bool {
		ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
	}
}
#endif
