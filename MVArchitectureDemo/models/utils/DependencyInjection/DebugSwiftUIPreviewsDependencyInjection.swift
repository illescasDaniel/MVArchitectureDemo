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
		diContainer.registerSingleton(MockRequestHTTPInterceptor())
		diContainer.registerSingleton(
			HTTPClientImpl(
				httpDataRequestHandler: URLSession(configuration: .ephemeral),
				interceptors: [
					NetworkDelayHTTPInterceptor(),
					diContainer.load(MockRequestHTTPInterceptor.self),
					RequestLoggerHTTPInterceptor()
				]
			),
			as: HTTPClient.self
		)
	}
}
#endif
