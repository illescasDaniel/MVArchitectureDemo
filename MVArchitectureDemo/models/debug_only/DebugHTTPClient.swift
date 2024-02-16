//
//  DebugHTTPClient.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation

final class DebugHTTPClient: HTTPClient {

	static let anyPath: String = "*"
	private var stubResponseForPath: [String: (Data, HTTPURLResponse)] = [:]
	private var stubErrorForPath: [String: Error] = [:]
	private var networkDelayIsSetUp = false
	let urlSession: URLSession

	init(urlSession: URLSession) {
		self.urlSession = urlSession
	}

	func data(for httpRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		if !Config.isTest && !networkDelayIsSetUp {
			try await setUpNetworkDelay()
			networkDelayIsSetUp = true
		}
		let path = httpRequest.urlRequest.url?.path(percentEncoded: true) ?? String()

		if let (data, response) = stubResponseForPath[path] ?? stubResponseForPath[Self.anyPath] {
			return (data, response)
		}
		if let error = stubErrorForPath[path] ?? stubErrorForPath[Self.anyPath] {
			throw error
		}

		let (data, response) = try await urlSession.data(for: httpRequest.urlRequest)
		return (data, response as! HTTPURLResponse)
	}

	// MARK: Mock response

	@discardableResult
	func withMock<T>(
		data: Data = Data(),
		response: HTTPURLResponse,
		path: String = DebugHTTPClient.anyPath,
		block: @Sendable () async throws -> T
	) async throws -> T {
		removeMockData()
		setMock(data: data, response: response, path: path)
		defer { removeMockData() }
		return try await block()
	}

	func setMock(data: Data = Data(), response: HTTPURLResponse, path: String = DebugHTTPClient.anyPath) {
		stubResponseForPath[path] = (data, response)
		stubErrorForPath.removeValue(forKey: path)
	}

	func removeMockData() {
		stubResponseForPath.removeAll()
		stubErrorForPath.removeAll()
	}

	// MARK: Private

	private func setUpNetworkDelay() async throws {
		let body = #"{ "fixedDelay": 200 }"#
		var request = URLRequest(url: Config.environment.baseURL.appending(path: "__admin/settings"))
		request.httpMethod = "POST"
		request.httpBody = Data(body.utf8)
		_ = try await URLSession(configuration: .default).data(for: request)
	}
}
#endif
