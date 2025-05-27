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

	init(id: String, name: String, content: String) {
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

			try await ServerAvailabilityManager.checkAvailability()

			let request = try HTTPURLRequest(
				url: DI.get(ServerEnvironment.self).baseURL / "notes" / self.id,
				httpMethod: .patch,
				bodyDictionary: newChanges
			)
			let (_, response) = try await DI.get(HTTPClient.self).sendRequest(request)
			if response.statusCode != 204 {
				throw AppNetworkResponseError.unexpected(statusCode: response.statusCode)
			}

			previousNoteDictionary = currentNoteDictionary
		} catch {
			// revert it back
			if let previousNote = value(previousNoteDictionary) {
				name = previousNote.name
				content = previousNote.content
			}
			
			throw error
		}
	}

	@Sendable
	static func all() async throws -> [Note] {
		try await ServerAvailabilityManager.checkAvailability()
		let request = try HTTPURLRequest(url: DI.get(ServerEnvironment.self).baseURL / "notes")
		let notes = try await DI.get(HTTPClient.self).sendRequest(request, decoding: [Note].self)
		return notes
	}
}
