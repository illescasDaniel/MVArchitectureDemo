//
//  HTTPClientImpl.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

final class HTTPClientImpl: HTTPClient {

	let urlSession: URLSession

	init(urlSession: URLSession) {
		self.urlSession = urlSession
	}

	func data(for httpRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		let (data, response) = try await urlSession.data(for: httpRequest.urlRequest)
		return (data, response as! HTTPURLResponse)
	}
}
