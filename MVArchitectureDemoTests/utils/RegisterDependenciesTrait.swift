//
//  BaseTest.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 1/8/25.
//

import Testing
import DIC
import HTTIES
import Foundation
@testable import MVArchitectureDemo

struct RegisterDependenciesTrait: SuiteTrait, TestScoping {
	
	func provideScope(for test: Test, testCase: Test.Case?, performing function: @Sendable () async throws -> Void) async throws {
		if test.isSuite {
			registerDependencies()
		}
		try await function()
	}

	private func registerDependencies() {
		DI = DICBuilder()
			.registerSingleton(ServerEnvironment.localTests)
			.registerSingleton(
				HTTPClientImpl(httpDataRequestHandler: URLSession(configuration: .ephemeral)),
				as: HTTPClient.self
			)
			.build()
	}
}

extension Trait where Self == RegisterDependenciesTrait {
	static var registerDependencies: Self { Self() }
}
