//
//  ViewState.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation
import SwiftUI

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

	static func update<T: Equatable>(_ data: Binding<[T]>, _ viewState: Binding<ViewState>, getData: @Sendable () async throws -> [T]) async {
		do {
			let newData = try await getData()
			if newData.isEmpty {
				data.wrappedValue = []
				viewState.wrappedValue = .empty
			} else {
				data.wrappedValue = newData
				viewState.wrappedValue = .success
			}
		} catch {
			viewState.wrappedValue = .error(error)
		}
	}

	// TODO: needs to be tested (maybe on a Note Detail screen)

//	static func create<T: Equatable>(previous oldData: T?, new newData: @Sendable () async throws -> T) async -> (ViewState, T?) {
//		do {
//			let newData = try await newData()
//			// TO DO: maybe we could create a Empty protocol in which some data could specify if it is considered to be empty
//			// for example a Note type with empty name and empty content could be considered 'empty'...
//			// protocol IsEmpty {
//			// var isEmpty: Bool { get }
//			//}
//			// extension String: IsEmpty {}
//			// extension Array: IsEmpty {}
//			return (.success, newData)
//		} catch {
//			return (.error(error), oldData)
//		}
//	}
//
//	static func update<T: Equatable>(_ data: Binding<T>, _ viewState: Binding<ViewState>, getData: @Sendable () async throws -> T) async {
//		do {
//			let newData = try await getData()
//			viewState.wrappedValue = .success
//			data.wrappedValue = newData
//		} catch {
//			viewState.wrappedValue = .error(error)
//		}
//	}
}
