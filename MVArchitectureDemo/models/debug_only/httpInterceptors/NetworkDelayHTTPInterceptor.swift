//
//  NetworkDelayHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import HTTIES

final class NetworkDelayHTTPInterceptor: HTTPInoutRequestInterceptor {
	private var networkDelayIsSetUp = false

	func intercept(request: inout URLRequest) async throws {
		if !networkDelayIsSetUp {
			try await setUpNetworkDelay()
			networkDelayIsSetUp = true
		}
	}

	private func setUpNetworkDelay() async throws {
		let url = DI.get(ServerEnvironment.self).baseURL / "__admin/settings"
		let request = try HTTPURLRequest(
			url: url,
			httpMethod: .post,
			bodyDictionary: ["fixedDelay": Config.networkDelayInMilliseconds]
		)
		_ = try await URLSession(configuration: .default).data(for: request.urlRequest)
	}
}
#endif
