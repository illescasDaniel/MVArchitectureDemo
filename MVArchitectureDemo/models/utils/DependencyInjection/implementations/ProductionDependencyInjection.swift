//
//  ProductionDependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if !DEBUG
import Foundation
import DIC
import HTTIES

struct ProductionDependencyInjection: DependencyInjection {

	let diContainer = MiniDependencyInjectionContainer()

	func registerDependencies() {
		diContainer.registerSingleton(ServerEnvironment.production)
		diContainer.registerSingleton(
			HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .default)),
			as: HTTPClient.self
		)
	}
}
#endif
