//
//  MVXCTestCase.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import XCTest
import WMUTE
@testable import MVArchitectureDemo

extension XCTestCase {
	@discardableResult
	func withStub<T>(
		_ stubFileName: String,
		action: () async throws -> T
	) async throws -> T {
		let baseURL = DI.get(ServerEnvironment.self).baseURL
		let stubFile = try XCTUnwrap(Bundle(for: Self.self).url(forResource: stubFileName, withExtension: "json")?.path(percentEncoded: false))
		let data = try XCTUnwrap(FileManager.default.contents(atPath: stubFile))
		return try await WMStubManager(
			baseURL: baseURL,
			urlSession: URLSession(configuration: .ephemeral)
		)
		.runWithStub(data, block: action)
	}
}
