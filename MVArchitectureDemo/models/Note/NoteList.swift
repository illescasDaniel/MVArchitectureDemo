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

	convenience init(notes: [_NoteDTO]) {
		self.init()
		self.notes = notes.map(Note.init)
		self.previousNotes = self.notes
	}

	static func all() async throws -> [_NoteDTO] {
		try await ServerAvailabilityManager.checkAvailability()
		let request = try HTTPURLRequest(url: DI.load(ServerEnvironment.self).baseURL / "notes")
		let noteDTOs = try await DI.load(HTTPClient.self).sendRequest(request, decoding: [_NoteDTO].self)
		return noteDTOs
	}

	func fetch() async throws {
		let noteDTOs = try await NoteList.all()
		let loadedNotes = noteDTOs.map { Note($0) }

		self.notes = loadedNotes
		self.previousNotes = loadedNotes
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

		print("added notes:", addedNoteIds)
		print("deleted notes:", deletedNoteIds)

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
			bodyDictionary: note.dictionary
		)

		let createdNoteDTO = try await DI.load(HTTPClient.self).sendRequest(request, decoding: _NoteDTO.self)
		let createdNote = Note(createdNoteDTO)

		notes.append(createdNote)
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

		notes.removeAll { $0.id == note.id }
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
