//
//  HTTPHandler.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

import Foundation

final class HTTPHandler {
	private let nextRequest: (HTTPURLRequest) async throws -> (Data, HTTPURLResponse)
	init(nextRequest: @escaping (HTTPURLRequest) async throws -> (Data, HTTPURLResponse)) {
		self.nextRequest = nextRequest
	}
	func proceed(_ newRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		try await nextRequest(newRequest)
	}
}
