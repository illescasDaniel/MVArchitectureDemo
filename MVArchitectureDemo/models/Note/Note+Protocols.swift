//
//  Note+Protocols.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

extension Note: Identifiable, DictionaryRepresentable {}

extension Note: Decodable {
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case content
	}

	convenience init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let id = try container.decode(String.self, forKey: .id)
		let name = try container.decode(String.self, forKey: .name)
		let content = try container.decode(String.self, forKey: .content)
		self.init(id: id, name: name, content: content)
	}
}

extension Note: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.content, forKey: .content)
	}
}

extension Note: Equatable {
	static func == (lhs: Note, rhs: Note) -> Bool {
		guard lhs.id == rhs.id else { return false }
		guard lhs.name == rhs.name else { return false }
		guard lhs.content == rhs.content else { return false }
		return true
	}

	func hasSameData(as other: Note) -> Bool {
		guard name == other.name else { return false }
		guard content == other.content else { return false }
		return true
	}
}
