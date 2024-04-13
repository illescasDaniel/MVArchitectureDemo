//
//  DebugSwiftUIPreviewsDependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import DIC
import HTTIES

struct DebugSwiftUIPreviewsDependencyInjection: DependencyInjection {

	let diContainer = MiniDependencyInjectionContainer()

	func registerDependencies() {
		diContainer.registerSingleton(ServerEnvironment.localApp)
		diContainer.registerSingleton(
			MockHTTPClient(
				requestInterceptors: [
					NetworkDelayHTTPInterceptor()
				],
				responseInterceptors: [
					RequestLoggerHTTPInterceptor()
				]
			)
		)
		diContainer.registerSingleton(
			diContainer.load(MockHTTPClient.self),
			as: HTTPClient.self
		)
	}
}
#endif
