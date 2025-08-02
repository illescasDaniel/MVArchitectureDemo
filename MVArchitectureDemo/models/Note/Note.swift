//
//  NoteModel.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import Foundation
import Observation
import HTTIES

@Observable
final class Note: Identifiable {

	let id: String
	var name: String
	var content: String

	var noteData: NoteDTO {
		.init(id: id, name: name, content: content)
	}

	@ObservationIgnored
	private var previousNoteDictionary: [String: AnyHashable] = [:]

	convenience init(_ noteData: NoteDTO) {
		self.init(id: noteData.id, name: noteData.name, content: noteData.content)
	}

	init(id: String = String(), name: String, content: String) {
		self.id = id
		self.name = name
		self.content = content
		self.previousNoteDictionary = noteData.dictionary
	}

	func update() async throws {
		do {
			let currentNoteDictionary = noteData.dictionary
			let newChanges = currentNoteDictionary.filter { previousNoteDictionary[$0] != $1 }
			if newChanges.isEmpty {
				return
			}

			logger.trace("New changes: \(newChanges)")

			try await ServerAvailabilityManager.checkAvailability()

			let request = try HTTPURLRequest(
				url: DI.load(ServerEnvironment.self).baseURL / "notes" / self.id,
				httpMethod: .patch,
				bodyDictionary: newChanges,
				headers: ["Content-Type": "application/json"]
			)
			let (_, response) = try await DI.load(HTTPClient.self).sendRequest(request)
			if response.statusCode != 204 {
				throw AppNetworkResponseError.unexpected(statusCode: response.statusCode)
			}

			previousNoteDictionary = currentNoteDictionary
		} catch {
			logger.error(error)
			// revert it back
			if let previousNote = noteData.value(previousNoteDictionary) {
				name = previousNote.name
				content = previousNote.content
			}
			
			throw error
		}
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
