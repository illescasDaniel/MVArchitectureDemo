//
//  DebugUnitTestsDependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import DIC
import HTTIES

struct DebugUnitTestsDependencyInjection: DependencyInjection {

	let diContainer = MiniDependencyInjectionContainer()

	func registerDependencies() {
		diContainer.registerSingleton(ServerEnvironment.localTests)
		diContainer.registerSingleton(MockRequestHTTPInterceptor())
		diContainer.registerSingleton(
			HTTPClientImpl(
				httpDataRequestHandler: URLSession(configuration: .ephemeral),
				interceptors: [
					diContainer.load(MockRequestHTTPInterceptor.self),
					RequestLoggerHTTPInterceptor()
				]
			),
			as: HTTPClient.self
		)
	}
}
#endif
