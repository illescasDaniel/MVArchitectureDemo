//
//  NoteDTO.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 2/8/25.
//

/// A data transfer object, just useful for transfering its data across. You should convert it to Note to use it.
struct NoteDTO: DictionaryRepresentable, Equatable, Sendable, Identifiable {
	let id: String
	let name: String
	let content: String
}

extension NoteDTO: Decodable {}

extension NoteDTO: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
//		try container.encode(self.id, forKey: .id) // not needed for now
		try container.encode(self.name, forKey: .name)
		try container.encode(self.content, forKey: .content)
	}
}
