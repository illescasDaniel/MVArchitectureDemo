//
//  DictionaryRepresentable.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 5/1/24.
//

import Foundation

protocol DictionaryRepresentable: Codable {
	var dictionary: [String: AnyHashable] { get }
	func value(_ dictionary: [String: AnyHashable]) -> Self?
}
extension DictionaryRepresentable {
	var dictionary: [String: AnyHashable] {
		do {
			let data = try JSONEncoder().encode(self)
			return try JSONSerialization.jsonObject(with: data) as? [String: AnyHashable] ?? [:]
		} catch {
			return [:]
		}
	}

	func value(_ dictionary: [String: AnyHashable]) -> Self? {
		do {
			let data = try JSONSerialization.data(withJSONObject: dictionary)
			let object = try JSONDecoder().decode(Self.self, from: data)
			return object
		} catch {
			return nil
		}
	}
}
