//
//  NetworkDelayHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

#if DEBUG
import Foundation

final class NetworkDelayHTTPInterceptor: HTTPInterceptor {
	private var networkDelayIsSetUp = false

	func data(for httpRequest: HTTPURLRequest, httpHandler: HTTPHandler) async throws -> (Data, HTTPURLResponse) {
		if !networkDelayIsSetUp {
			try await setUpNetworkDelay()
			networkDelayIsSetUp = true
		}
		return try await httpHandler.proceed(httpRequest)
	}

	private func setUpNetworkDelay() async throws {
		let body = #"{ "fixedDelay": \#(Config.networkDelayInMilliseconds) }"#
		var request = URLRequest(url: DI.get(ServerEnvironment.self).baseURL.appending(path: "__admin/settings"))
		request.httpMethod = "POST"
		request.httpBody = Data(body.utf8)
		_ = try await URLSession(configuration: .default).data(for: request)
	}
}
#endif
