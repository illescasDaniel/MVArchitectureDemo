//
//  NoteList.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 2/8/25.
//

import HTTIES
import Foundation

@Observable
final class NoteList {

	var notes: [Note] = []

	@ObservationIgnored
	private var previousNotes: [Note] = []

	init() {}

	convenience init(notes: [NoteDTO]) {
		self.init()
		self.notes = notes.map(Note.init)
		self.previousNotes = self.notes
	}

	static func fetchAll() async throws -> [NoteDTO] {
		try await ServerAvailabilityManager.checkAvailability()
		let request = try HTTPURLRequest(url: DI.load(ServerEnvironment.self).baseURL / "notes")
		let noteDTOs = try await DI.load(HTTPClient.self).sendRequest(request, decoding: [NoteDTO].self)
		return noteDTOs
	}

	func update() async throws {
		let currentNotes = notes
		let previousNoteIds = Set(previousNotes.map { $0.id })
		let currentNoteIds = Set(currentNotes.map { $0.id })

		// Find notes that were added (exist in current but not in previous)
		let addedNoteIds = currentNoteIds.subtracting(previousNoteIds)
		let addedNotes = currentNotes.filter { addedNoteIds.contains($0.id) }

		// Find notes that were deleted (exist in previous but not in current)
		let deletedNoteIds = previousNoteIds.subtracting(currentNoteIds)
		let deletedNotes = previousNotes.filter { deletedNoteIds.contains($0.id) }

		// If no changes, return early
		if addedNotes.isEmpty && deletedNotes.isEmpty {
			return
		}

		// Store current state for potential rollback
		let rollbackNotes = previousNotes

		logger.trace("added notes: \(addedNoteIds)")
		logger.trace("deleted notes: \(deletedNoteIds)")

		// We could have endpoints to delete a bunch of notes or to create a bunch of notes at ones; or both
		// This app and code are just some simple examples
		do {
			// Process deletions first
			for note in deletedNotes {
				try await deleteNote(note)
			}

			// Process additions
			for note in addedNotes {
				try await createNote(note)
			}

			// Update the previous state to current after successful sync
			previousNotes = notes

		} catch {
			logger.error(error)
			// Rollback to previous state on error
			notes = rollbackNotes
			throw error

		}
	}

	private func createNote(_ note: Note) async throws {
		try await ServerAvailabilityManager.checkAvailability()

		let request = try HTTPURLRequest(
			url: DI.load(ServerEnvironment.self).baseURL / "notes",
			httpMethod: .post,
			bodyDictionary: note.noteData.dictionary,
			headers: ["Content-Type": "application/json"]
		)

		let createdNoteDTO = try await DI.load(HTTPClient.self).sendRequest(request, decoding: NoteDTO.self)
		let createdNote = Note(createdNoteDTO)

		if let indexOfNoteToReplace = notes.firstIndex(where: { $0.id == String() && $0.hasSameData(as: createdNote) }) {
			notes[indexOfNoteToReplace] = createdNote
		}
	}

	/// Delete a note from the server and remove it from the list
	private func deleteNote(_ note: Note) async throws {
		try await ServerAvailabilityManager.checkAvailability()

		let request = try HTTPURLRequest(
			url: DI.load(ServerEnvironment.self).baseURL / "notes" / note.id,
			httpMethod: .delete
		)

		let (_, response) = try await DI.load(HTTPClient.self).sendRequest(request)
		if response.statusCode != 204 && response.statusCode != 200 {
			throw AppNetworkResponseError.unexpected(statusCode: response.statusCode)
		}
	}
}

extension NoteList: EmptyProtocol {
	var isEmpty: Bool { notes.isEmpty }

	static func empty() -> NoteList {
		return NoteList()
	}
}

extension NoteList: Equatable {
	static func == (lhs: NoteList, rhs: NoteList) -> Bool {
		return lhs.notes == rhs.notes
	}
}
