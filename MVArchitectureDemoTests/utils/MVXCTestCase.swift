//
//  MVXCTestCase.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import Foundation
import XCTest
@testable import MVArchitectureDemo

class MVXCTestCase: XCTestCase {
	override class func setUp() {
		super.setUp()
		Config.environment = .localTests
	}

	@discardableResult
	func withMock<T>(
		_ mockName: String,
		action: () async throws -> T
	) async throws -> T {
		do {
			let mockFile = try XCTUnwrap(Bundle(for: Self.self).url(forResource: mockName, withExtension: "json")?.path(percentEncoded: false))
			let data = try XCTUnwrap(FileManager.default.contents(atPath: mockFile))

			try await createMockStubsRequest(data: data)

			let result = try await action()

			try? await deleteMockStubsRequest()

			return result
		} catch {
			try? await deleteMockStubsRequest()
			throw error
		}
	}

	// MARK: Private

	private func mockURL() throws -> URL {
		let url = try XCTUnwrap(Config.environment.baseURL.appending(path: "__admin/mappings"))
		return url
	}

	private func createMockStubsRequest(data: Data) async throws {
		var request = URLRequest(url: try mockURL())
		request.httpMethod = "POST"
		request.httpBody = data

		let (_, response) = try await URLSession(configuration: .default).data(for: request)
		let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
		XCTAssertEqual(httpResponse.statusCode, 201)
	}

	private func deleteMockStubsRequest() async throws {
		var request = URLRequest(url: try mockURL().appending(path: "reset"))
		request.httpMethod = "POST"

		let (_, response) = try await URLSession(configuration: .default).data(for: request)
		let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
		XCTAssertEqual(httpResponse.statusCode, 200)
	}
}
