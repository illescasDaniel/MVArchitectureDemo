//
//  MVXCTestCase.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import Testing
import WMUTE
import Foundation
@testable import MVArchitectureDemo

private class FakeClass {}

enum StubError: Error {
	case noStubFile
	case noStubFileContent
}

@discardableResult
func withStub<T>(
	_ stubFileName: String,
	action: () async throws -> T
) async throws -> T {
	let baseURL = DI.load(ServerEnvironment.self).baseURL
	guard let stubFile = Bundle(for: FakeClass.self).url(forResource: stubFileName, withExtension: "json")?.path(percentEncoded: false) else {
		throw StubError.noStubFile
	}
	guard let data = FileManager.default.contents(atPath: stubFile) else {
		throw StubError.noStubFileContent
	}
	return try await WMStubManager(
		baseURL: baseURL,
		urlSession: URLSession(configuration: .ephemeral)
	)
	.runWithStub(data, block: action)
}
