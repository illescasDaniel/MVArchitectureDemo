//
//  ViewState.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

enum ViewState {
	case idle
	case loading
	case error(_ error: Error)
	case empty
	case success

	var isSuccess: Bool {
		if case .success = self {
			return true
		}
		return false
	}

	static func create<T: Equatable>(previous oldArrayData: [T], new newArrayData: @Sendable () async throws -> [T]) async -> (ViewState, [T]) {
		do {
			let newData = try await newArrayData()
			if newData.isEmpty {
				return (.empty, [])
			} else {
				return (.success, newData)
			}
		} catch {
			return (.error(error), oldArrayData)
		}
	}

	static func create<T: Equatable>(previous oldData: T?, new newData: @Sendable () async throws -> T) async -> (ViewState, T?) {
		do {
			let newData = try await newData()
			// TO DO: maybe we could create a Empty protocol in which some data could specify if it is considered to be empty
			// for example an Note type with empty name and empty content could be considered 'empty'...
			return (.success, newData)
		} catch {
			return (.error(error), oldData)
		}
	}
}
