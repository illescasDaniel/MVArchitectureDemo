//
//  EmptyProtocol.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import Foundation

protocol EmptyProtocol {
	var isEmpty: Bool { get }
	static func empty() -> Self
}
extension EmptyProtocol where Self: Initiable {
	static func empty() -> Self {
		Self.init()
	}
}

extension String: EmptyProtocol {}
extension Array: EmptyProtocol {}
extension Optional: EmptyProtocol {
	var isEmpty: Bool {
		switch self {
		case .some:
			return false
		case .none:
			return true
		}
	}
	static func empty() -> Optional<Wrapped> {
		.none
	}
}
