//
//  NoteListTests.swift
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import Testing
import HTTIES
import WMUTE
@testable import MVArchitectureDemo

@Suite(.serialized, .registerDependencies)
nonisolated struct NoteListTests {

	@Test
	func givenServerHasData_WhenFetchNotes_ThenCorrectNotesMatch() async throws {
		let notes = try await withStub("notes_success", action: NoteList.fetchAll)
		#expect(
			notes == [
				.init(id: "1", name: "Note1", content: "some content here!"),
				.init(id: "2", name: "Note 2", content: "some other here")
			]
		)
	}

	@Test
	func givenServerFailure_WhenFetchNotes_ThenThrowsError() async throws {
		await expectThrowsAsyncErrorEqual({
			try await withStub("notes_failure_500", action: NoteList.fetchAll)
		}, error: AppNetworkResponseError.unexpected(statusCode: 500))
	}

	@MainActor
	@Test
	func givenNoNoteListChanges_WhenUpdateNotes_ThenNoChangesInNotesMatch() async throws {
		let noteList = NoteList(notes: [.init(id: "a", name: "b", content: "c")])
		try await noteList.update()
		#expect(noteList.notes == [Note(id: "a", name: "b", content: "c")])
	}

	@Test
	@MainActor func givenServerNewNoteCreated_WhenUpdateNotes_ThenCorrectNotesMatch() async throws {
		let noteList = NoteList(notes: [.init(id: "a", name: "b", content: "c")])
		noteList.notes.append(Note(name: "aaaa", content: "bbb"))
		try await withStub("notes_create_success", action: noteList.update)
		#expect(noteList.notes.last == Note(id: "123", name: "aaaa", content: "bbb"))
	}

//	@Test
//	@MainActor func givenNewNoteCreatedAndServerFailure_WhenUpdateNotes_ThenThrowsError() async throws {
//		let noteList = NoteList(notes: [.init(id: "a", name: "b", content: "c")])
//		noteList.notes.append(Note(name: "aaaa", content: "bbb"))
//		await expectThrowsAsyncErrorEqual({
//			try await withStub("notes_create_failure_500", action: noteList.update)
//		}, error: AppNetworkResponseError.unexpected(statusCode: 500))
//	}

	@Test
	@MainActor func givenServerNoteDeleted_WhenUpdateNotes_ThenCorrectNotesMatch() async throws {
		let noteList = NoteList(notes: [.init(id: "a", name: "b", content: "c")])
		noteList.notes.remove(at: 0)
		try await withStub("notes_delete_success", action: noteList.update)
		#expect(noteList.isEmpty)
	}

//	@Test
//	@MainActor func givenNoteDeletedAndServerFailure_WhenUpdateNotes_ThenThrowsError() async throws {
//		let noteList = NoteList(notes: [.init(id: "a", name: "b", content: "c")])
//		noteList.notes.remove(at: 0)
//		await expectThrowsAsyncErrorEqual({
//			try await withStub("notes_delete_failure_500", action: noteList.update)
//		}, error: AppNetworkResponseError.unexpected(statusCode: 500))
//		#expect(!noteList.isEmpty)
//	}
}
