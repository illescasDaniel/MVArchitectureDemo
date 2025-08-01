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

struct MockRequest: Hashable, ExpressibleByStringLiteral {
	let path: String
	let method: String

	init(path: String, method: String = "*") {
		self.path = path
		self.method = method
	}

	init(stringLiteral value: StringLiteralType) {
		self.init(path: value)
	}
}

final class MockHTTPClient: HTTPClient, HTTPInterceptorMixin {

	static let anyRequest = MockRequest(path: "*", method: "*")
	private var stubResponseForRequest: [MockRequest: (Data, HTTPURLResponse)] = [:]
	private var stubErrorForRequest: [MockRequest: Error] = [:]
	private let defaultClient = HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .ephemeral))
	var requestInterceptors: [any HTTPRequestInterceptor]
	var responseInterceptors: [any HTTPResponseInterceptor]

	init(requestInterceptors: [any HTTPRequestInterceptor] = [], responseInterceptors: [any HTTPResponseInterceptor] = []) {
		self.requestInterceptors = requestInterceptors
		self.responseInterceptors = responseInterceptors
	}

	func sendRequestWithoutInterceptors(_ urlRequest: URLRequest) async throws -> (Data, HTTPURLResponse) {
		let path = urlRequest.url?.path(percentEncoded: true) ?? String()
		let method = urlRequest.httpMethod ?? String()
		let request = MockRequest(path: path, method: method)
		let anyMethodForRequest = MockRequest(path: path, method: "*")

		if let (data, response) = stubResponseForRequest[request] ?? stubResponseForRequest[anyMethodForRequest] ?? stubResponseForRequest[Self.anyRequest] {
			return (data, response)
		}
		if let error = stubErrorForRequest[request] ?? stubErrorForRequest[anyMethodForRequest] ?? stubErrorForRequest[Self.anyRequest] {
			throw error
		}
		
		return try await defaultClient.sendRequest(HTTPURLRequest(urlRequest: urlRequest))
	}

	// MARK: Mock response

	func onlyMocking(data: Data = Data(), response: HTTPURLResponse, for request: MockRequest = MockHTTPClient.anyRequest) {
		removeMockData()
		setMock(data: data, response: response, for: request)
	}

	@discardableResult
	func setMock(data: Data = Data(), response: HTTPURLResponse, for request: MockRequest = MockHTTPClient.anyRequest) -> MockHTTPClient{
		stubResponseForRequest[request] = (data, response)
		stubErrorForRequest.removeValue(forKey: request)
		return self
	}

	@discardableResult
	func setMock(error: Error, for request: MockRequest = MockHTTPClient.anyRequest) -> MockHTTPClient {
		stubResponseForRequest.removeValue(forKey: request)
		stubErrorForRequest[request] = error
		return self
	}

	@discardableResult
	func removeMockData() -> MockHTTPClient {
		stubResponseForRequest.removeAll()
		stubErrorForRequest.removeAll()
		return self
	}
}
extension Data {
	init(assetName: String) {
		if let data = NSDataAsset(name: assetName, bundle: .main)?.data {
			self = data
		} else {
			fatalError("Couldn't find \"\(assetName)\" in the assets catalog")
		}
	}
}
#endif
