//
//  DebugHTTPClient.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation
import HTTIES
import SwiftUI

final class MockHTTPClient: HTTPClient, HTTPInterceptorMixin {

	static let anyPath: String = "*"
	private var stubResponseForPath: [String: (Data, HTTPURLResponse)] = [:]
	private var stubErrorForPath: [String: Error] = [:]
	private let defaultClient = HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .ephemeral))
	var requestInterceptors: [any HTTPRequestInterceptor]
	var responseInterceptors: [any HTTPResponseInterceptor]

	init(requestInterceptors: [any HTTPRequestInterceptor] = [], responseInterceptors: [any HTTPResponseInterceptor] = []) {
		self.requestInterceptors = requestInterceptors
		self.responseInterceptors = responseInterceptors
	}

	func sendRequestWithoutInterceptors(_ urlRequest: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let path = urlRequest.url?.path(percentEncoded: true) ?? String()

		if let (data, response) = stubResponseForPath[path] ?? stubResponseForPath[Self.anyPath] {
			return (data, response)
		}
		if let error = stubErrorForPath[path] ?? stubErrorForPath[Self.anyPath] {
			throw error
		}
		
		return try await defaultClient.sendRequest(HTTPURLRequest(urlRequest: urlRequest))
	}

	// MARK: Mock response

	func setMock(data: Data = Data(), response: HTTPURLResponse, path: String = MockHTTPClient.anyPath) {
		stubResponseForPath[path] = (data, response)
		stubErrorForPath.removeValue(forKey: path)
	}

	func setMock(error: Error, path: String = MockHTTPClient.anyPath) {
		stubResponseForPath.removeValue(forKey: path)
		stubErrorForPath[path] = error
	}

	func removeMockData() {
		stubResponseForPath.removeAll()
		stubErrorForPath.removeAll()
	}
}

#endif
