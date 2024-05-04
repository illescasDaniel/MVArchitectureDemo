//
//  WMUTE.swift
//  MVArchitectureDemoTests
//
//  Created by Daniel Illescas Romero on 4/5/24.
//

import XCTest

func XCTAssertThrowsAsyncError<T>(
	_ expression: () async throws -> T,
	message: @autoclosure () -> String = "",
	file: StaticString = #filePath,
	line: UInt = #line,
	errorHandler: (_ error: any Error) -> Void = { _ in }
) async {
	do {
		_ = try await expression()
		XCTFail(message(), file: file, line: line)
	} catch {
		errorHandler(error)
	}
}

func XCTAssertThrowsAsyncErrorEqual<T, E: Error & Equatable>(
	_ expression: () async throws -> T,
	error: E,
	message: @autoclosure () -> String = "",
	file: StaticString = #filePath,
	line: UInt = #line,
	errorHandler: (_ error: any Error) -> Void = { _ in }
) async {
	await XCTAssertThrowsAsyncError(
		expression,
		message: message(),
		file: file,
		line: line,
		errorHandler: { e in
			XCTAssertEqual(e as? E, error)
		}
	)
}
