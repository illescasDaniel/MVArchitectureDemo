//
//  DebugDependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import DIC
import HTTIES

struct DebugDependencyInjection: DependencyInjection {

	let diContainer = MiniDependencyInjectionContainer()

	func registerDependencies() {
		diContainer.registerSingleton(ServerEnvironment.localApp)
		diContainer.registerSingleton(
			HTTPClientImpl(
				httpDataRequestHandler: URLSession(configuration: .ephemeral),
				requestInterceptors: [
					NetworkDelayHTTPInterceptor(),
				],
				responseInterceptors: [
					RequestLoggerHTTPInterceptor(),
				]
			),
			as: HTTPClient.self
		)
	}
}
#endif
