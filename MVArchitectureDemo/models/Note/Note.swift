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
final class Note {

	let id: String
	var name: String
	var content: String

	@ObservationIgnored
	private var previousNoteDictionary: [String: AnyHashable] = [:]

	convenience init(_ noteData: _NoteDTO) {
		self.init(id: noteData.id, name: noteData.name, content: noteData.content)
	}

	init(id: String = String(), name: String, content: String) {
		self.id = id
		self.name = name
		self.content = content
		self.previousNoteDictionary = dictionary
	}

	func update() async throws {
		do {
			let currentNoteDictionary = dictionary
			let newChanges = currentNoteDictionary.filter { previousNoteDictionary[$0] != $1 }
			if newChanges.isEmpty {
				return
			}

			logger.trace("New changes: \(newChanges)")

			try await ServerAvailabilityManager.checkAvailability()

			let request = try HTTPURLRequest(
				url: DI.load(ServerEnvironment.self).baseURL / "notes" / self.id,
				httpMethod: .patch,
				bodyDictionary: newChanges
			)
			let (_, response) = try await DI.load(HTTPClient.self).sendRequest(request)
			if response.statusCode != 204 {
				throw AppNetworkResponseError.unexpected(statusCode: response.statusCode)
			}

			previousNoteDictionary = currentNoteDictionary
		} catch {
			logger.error(error)
			// revert it back
			if let previousNote = value(previousNoteDictionary) {
				name = previousNote.name
				content = previousNote.content
			}
			
			throw error
		}
	}
}

/// A data transfer object, just useful for transfering its data across. You should convert it to Note to use it.
struct _NoteDTO: Codable, Equatable, Sendable, Identifiable {
	let id: String
	let name: String
	let content: String
}
