//
//  HTTPClientImpl.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

final class HTTPClientImpl: HTTPClient {

	let urlSession: URLSession
	let interceptors: [any HTTPInterceptor]

	init(urlSession: URLSession, interceptors: [any HTTPInterceptor] = []) {
		self.urlSession = urlSession
		self.interceptors = interceptors
	}

	func data(for httpRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		var handler = HTTPHandler { request in
			let (data, response) = try await self.urlSession.data(for: httpRequest.urlRequest)
			return (data, response as! HTTPURLResponse)
		}
		var lastResponse: (Data, HTTPURLResponse)?
		for interceptor in interceptors {
			let response = try await interceptor.data(for: httpRequest, httpHandler: handler)
			lastResponse = response
			handler = HTTPHandler { request in
				return response
			}
		}
		
		if let lastResponse {
			return lastResponse
		} else {
			return try await handler.proceed(httpRequest)
		}
	}
}
