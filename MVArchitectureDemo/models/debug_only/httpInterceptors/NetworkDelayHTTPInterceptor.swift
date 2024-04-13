//
//  NetworkDelayHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation
import HTTIES

final class NetworkDelayHTTPInterceptor: HTTPInterceptor {
	private var networkDelayIsSetUp = false

	func data(for httpRequest: HTTPURLRequest, httpRequestChain: HTTPRequestChain) async throws -> (Data, HTTPURLResponse) {
		if !networkDelayIsSetUp {
			let url = DI.get(ServerEnvironment.self).baseURL / "__admin/settings"
			let request = try HTTPURLRequest(
				url: url,
				httpMethod: .post,
				bodyDictionary: ["fixedDelay": Config.networkDelayInMilliseconds]
			)
			_ = try await httpRequestChain.proceed(request)
			networkDelayIsSetUp = true
		}
		return try await httpRequestChain.proceed(httpRequest)
	}
}
#endif
