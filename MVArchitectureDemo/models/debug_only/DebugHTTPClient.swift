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
	let urlSession: URLSession

	init(urlSession: URLSession) {
		self.urlSession = urlSession
	}

	func data(for httpRequest: HTTPURLRequest) async throws -> (Data, HTTPURLResponse) {
		if Config.isNetworkDelayEnabled {
			try? await Task.sleep(for: .milliseconds(600))
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

	//

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

	@discardableResult
	func withMock<T>(
		error: Error,
		path: String = DebugHTTPClient.anyPath,
		block: @Sendable () async throws -> T
	) async throws -> T {
		removeMockData()
		setMock(error: error, path: path)
		defer { removeMockData() }
		return try await block()
	}

	//

	func setMock(data: Data = Data(), response: HTTPURLResponse, path: String = DebugHTTPClient.anyPath) {
		stubResponseForPath[path] = (data, response)
		stubErrorForPath.removeValue(forKey: path)
	}

	// this is not for 404 or things like that, this is for when you want to simulate that the request task was cancelled or something like that!
	func setMock(error: Error, path: String = DebugHTTPClient.anyPath) {
		stubResponseForPath.removeValue(forKey: path)
		stubErrorForPath[path] = error
	}

	func removeMockData() {
		stubResponseForPath.removeAll()
		stubErrorForPath.removeAll()
	}
}
#endif
