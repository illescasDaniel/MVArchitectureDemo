//
//  DependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

import Foundation
import DIC

final class DependencyInjection {

	static let diContainer = MiniDependencyInjectionContainer()

	static func registerDependencies() {
		#if DEBUG
		diContainer.registerSingleton(MockRequestHTTPInterceptor())
		diContainer.registerSingleton(
			HTTPClientImpl(
				urlSession: URLSession(configuration: .ephemeral),
				interceptors: [diContainer.load(MockRequestHTTPInterceptor.self), RequestLoggerHTTPInterceptor()]
			),
			as: HTTPClient.self
		)
		#else
		diContainer.registerSingleton(
			HTTPClientImpl(urlSession: URLSession(configuration: .default)),
			as: HTTPClient.self
		)
		#endif
	}
}

func get<T>(_ type: T.Type) -> T {
	DependencyInjection.diContainer.load(type)
}
