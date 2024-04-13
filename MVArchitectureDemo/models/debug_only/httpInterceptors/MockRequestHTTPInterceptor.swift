//
//  DebugHTTPClient.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation

final class MockRequestHTTPInterceptor: HTTPInterceptor {

	static let anyPath: String = "*"
	private var stubResponseForPath: [String: (Data, HTTPURLResponse)] = [:]
	private var stubErrorForPath: [String: Error] = [:]

	func data(for httpRequest: HTTPURLRequest, httpHandler: HTTPHandler) async throws -> (Data, HTTPURLResponse) {
		let path = httpRequest.urlRequest.url?.path(percentEncoded: true) ?? String()

		if let (data, response) = stubResponseForPath[path] ?? stubResponseForPath[Self.anyPath] {
			return (data, response)
		}
		if let error = stubErrorForPath[path] ?? stubErrorForPath[Self.anyPath] {
			throw error
		}

		return try await httpHandler.proceed(httpRequest)
	}

	// MARK: Mock response

	@discardableResult
	func withMock<T>(
		data: Data = Data(),
		response: HTTPURLResponse,
		path: String = MockRequestHTTPInterceptor.anyPath,
		block: @Sendable () async throws -> T
	) async throws -> T {
		removeMockData()
		setMock(data: data, response: response, path: path)
		defer { removeMockData() }
		return try await block()
	}

	func setMock(data: Data = Data(), response: HTTPURLResponse, path: String = MockRequestHTTPInterceptor.anyPath) {
		stubResponseForPath[path] = (data, response)
		stubErrorForPath.removeValue(forKey: path)
	}

	func removeMockData() {
		stubResponseForPath.removeAll()
		stubErrorForPath.removeAll()
	}
}

#endif
