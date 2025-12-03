//
//  NotesDataModelTests.swift
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import Testing
import HTTIES
import WMUTE
@testable import MVArchitectureDemo

// .serialized because of withStub
// parallelization across other tests suites has been disabled too
// maybe we could do something to improve this and make it completely parallelizable

@Suite(.serialized, .registerDependencies)
struct NoteTests {

	// For people unused to this naming:
	// ----------------------------------
	// In Gherkin, test scenarios are described using the Given-When-Then format.
	// This format is a structured way to write down the conditions (Given),
	// the action (When), and the expected outcome (Then) of a test case.
	// When renaming your test function to adhere to this format, you'll want to clearly describe these three aspects.
	// ---
	// TIP: when unsure, ask your favorite LLM about naming the function

	@Test
	func givenValidNote_WhenUpdateNoteNameAndContent_ThenUpdateIsSuccessful() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		note.name = "planta"
		note.content = "bla bla bla"
		try await withStub("note_update_content_name_success", action: note.update)
		#expect(note.id == "a")
		#expect(note.name == "planta")
		#expect(note.content == "bla bla bla")
	}

	@Test
	func givenValidNote_WhenUpdateNoteNameTwice_ThenUpdatedNoteNameIsLatest() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		note.name = "planta"
		note.name = "bla bla bla"
		try await withStub("note_update_name_success", action: note.update)
		#expect(note.id == "a")
		#expect(note.name == "bla bla bla")
		#expect(note.content == "c")
	}

	@MainActor
	@Test
	func givenValidNote_WhenIsNotChanged_ThenUpdateIsAlwaysSuccessful() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		try await note.update()
		#expect(note.id == "a")
		#expect(note.name == "b")
		#expect(note.content == "c")
	}

//	@Test
//	func givenNonexistentID_WhenUpdate_ThenThrows404Error() async throws {
//		await expectThrowsAsyncErrorEqual({
//			let note = Note(id: "a", name: "b", content: "c")
//			note.name = "planta"
//			note.content = "bla bla bla"
//			try await withStub("note_update_content_name_failure_404", action: note.update)
//		}, error: AppNetworkResponseError.unexpected(statusCode: 404))
//	}

	@Test
	func GivenSomeValidNotes_WhenComparingThem_ThenComparisonMatches() {
		let noteA = Note(id: "a", name: "b", content: "c")
		let noteB = Note(id: "a", name: "b", content: "c")
		#expect(noteA == noteB)

		let noteC = Note(id: "a", name: "b", content: "c")
		let noteD = Note(id: "aa", name: "b", content: "c")
		#expect(noteC != noteD)

		let noteE = Note(id: "a", name: "b", content: "c")
		let noteF = Note(id: "a", name: "bb", content: "c")
		#expect(noteE != noteF)

		let noteG = Note(id: "a", name: "b", content: "c")
		let noteH = Note(id: "a", name: "b", content: "cc")
		#expect(noteG != noteH)
	}
}
