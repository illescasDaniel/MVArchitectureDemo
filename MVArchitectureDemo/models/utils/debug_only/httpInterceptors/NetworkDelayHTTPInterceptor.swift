//
//  NetworkDelayHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import HTTIES

actor NetworkDelayHTTPInterceptor: HTTPInoutRequestInterceptor {
	private var networkDelayIsSetUp = false

	func intercept(request: inout URLRequest) async throws {
		if !networkDelayIsSetUp {
			try await setUpNetworkDelay()
			networkDelayIsSetUp = true
		}
	}

	private func setUpNetworkDelay() async throws {
		let url = await DI.load(ServerEnvironment.self).baseURL / "__admin/settings"
		let request = try HTTPURLRequest(
			url: url,
			httpMethod: .post,
			body: ["fixedDelay": Config.networkDelayInMilliseconds],
			encoder: JSONBodyEncoder()
		)
		_ = try await URLSession(configuration: .default).data(for: request.urlRequest)
	}
}
#endif
