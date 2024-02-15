//
//  XCTestCase+withMock.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 15/2/24.
//

import Foundation
import XCTest
@testable import MVArchitectureDemo

extension XCTestCase {
	@discardableResult
	func withMock<T>(
		name mockName: String,
		action: () async throws -> T,
		file: StaticString = #filePath,
		line: UInt = #line
	) async throws -> T {
		let mockFile = try XCTUnwrap(Bundle(for: Self.self).url(forResource: mockName, withExtension: "json")?.path(percentEncoded: false))
		let data = FileManager.default.contents(atPath: mockFile)
		let url = try XCTUnwrap(Config.environment.baseURL.appending(path: "__admin/mappings"))

		var createMockRequest = URLRequest(url: url)
		createMockRequest.httpMethod = "POST"
		createMockRequest.httpBody = data
		let (_, createMockResponse) = try await URLSession(configuration: .default).data(for: createMockRequest)
		let createMockHTTPResponse = try XCTUnwrap(createMockResponse as? HTTPURLResponse)
		XCTAssertEqual(createMockHTTPResponse.statusCode, 201, file: file, line: line)

		let result = try await action()

//		var deleteMockRequest = URLRequest(url: url)
//		deleteMockRequest.httpMethod = "DELETE"
//		let (_, deleteMockResponse) = try await URLSession(configuration: .default).data(for: deleteMockRequest)
//		let deleteMockHTTPResponse = try XCTUnwrap(deleteMockResponse as? HTTPURLResponse)
//		XCTAssertEqual(deleteMockHTTPResponse.statusCode, 200, file: file, line: line)

		return result
	}
}
