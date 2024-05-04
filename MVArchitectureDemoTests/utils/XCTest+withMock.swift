//
//  MVXCTestCase.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import Foundation
import XCTest
import HTTIES
@testable import MVArchitectureDemo

extension XCTestCase {

	@discardableResult
	func withMock<T>(
		_ mockName: String,
		action: () async throws -> T
	) async throws -> T {
		do {
			let mockURL = try self.mockURL()
			do {
				let mockFile = try XCTUnwrap(Bundle(for: Self.self).url(forResource: mockName, withExtension: "json")?.path(percentEncoded: false))
				let data = try XCTUnwrap(FileManager.default.contents(atPath: mockFile))

				try await createMockStubsRequest(mockURL: mockURL, data: data)

				let result = try await action()

				try? await deleteMockStubsRequest(mockURL: mockURL)

				return result
			} catch {
				try? await deleteMockStubsRequest(mockURL: mockURL)
				throw error
			}
		} catch {
			throw error
		}
	}

	// MARK: Private

	private func mockURL() throws -> URL {
		let url = try XCTUnwrap(DI.get(ServerEnvironment.self).baseURL) / "__admin/mappings"
		return url
	}

	private func createMockStubsRequest(mockURL: URL, data: Data) async throws {
		var request = URLRequest(url: mockURL)
		request.httpMethod = "POST"
		request.httpBody = data

		let (_, response) = try await URLSession(configuration: .default).data(for: request)
		let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
		XCTAssertEqual(httpResponse.statusCode, 201)
	}

	private func deleteMockStubsRequest(mockURL: URL) async throws {
		var request = URLRequest(url: mockURL / "reset")
		request.httpMethod = "POST"

		let (_, response) = try await URLSession(configuration: .default).data(for: request)
		let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
		XCTAssertEqual(httpResponse.statusCode, 200)
	}
}
