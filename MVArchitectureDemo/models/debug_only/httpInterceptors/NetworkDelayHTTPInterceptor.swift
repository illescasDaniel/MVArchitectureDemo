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
			try await setUpNetworkDelay()
			networkDelayIsSetUp = true
		}
		return try await httpRequestChain.proceed(httpRequest)
	}

	private func setUpNetworkDelay() async throws {
		let body = #"{ "fixedDelay": \#(Config.networkDelayInMilliseconds) }"#
		let url = DI.get(ServerEnvironment.self).baseURL / "__admin/settings"
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = Data(body.utf8)
		_ = try await URLSession(configuration: .default).data(for: request)
	}
}
#endif
