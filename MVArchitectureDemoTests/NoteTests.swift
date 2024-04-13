//
//  NotesDataModelTests.swift
//  NotesDataModelTests
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import XCTest
import HTTIES
@testable import MVArchitectureDemo

final class NoteTests: XCTestCase {

	// For people unused to this naming:
	// ----------------------------------
	// In Gherkin, test scenarios are described using the Given-When-Then format.
	// This format is a structured way to write down the conditions (Given),
	// the action (When), and the expected outcome (Then) of a test case.
	// When renaming your test function to adhere to this format, you'll want to clearly describe these three aspects.
	// ---
	// TIP: when unsure, ask your favorite LLM about naming the function

	func test_GivenServerHasData_WhenFetchNotes_ThenCorrectNotesMatch() async throws {
		let notes = try await withMock("notes_success", action: Note.all)
		XCTAssertEqual(
			notes,
			[.init(id: "1", name: "Note1", content: "some content here"),
			 .init(id: "2", name: "Note 2", content: "some other here")]
		)
	}

	func test_GivenServerFailure_WhenFetchNotes_ThenThrowsError() async throws {
		do {
			try await withMock("notes_failure_500", action: Note.all)
		} catch {
			XCTAssertEqual(
				error as? AppNetworkResponseError,
				AppNetworkResponseError.unexpected(statusCode: 500)
			)
		}
	}

	func test_GivenValidNote_WhenUpdateNoteNameAndContent_ThenUpdateIsSuccessful() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		note.name = "planta"
		note.content = "bla bla bla"
		try await withMock("note_update_content_name_success", action: note.update)
	}

	func test_GivenValidNote_WhenUpdateNoteNameTwice_ThenUpdatedNoteNameIsLatest() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		note.name = "planta"
		note.name = "bla bla bla"
		try await withMock("note_update_name_success", action: note.update)
	}

	func test_GivenValidNote_WhenIsNotChanged_ThenUpdateIsAlwaysSuccessful() async throws {
		let note = Note(id: "a", name: "b", content: "c")
		try await note.update()
	}

	func test_GivenNonexistentID_WhenUpdate_ThenThrows404Error() async throws {
		do {
			let note = Note(id: "a", name: "b", content: "c")
			note.name = "planta"
			note.content = "bla bla bla"
			try await withMock("note_update_content_name_failure_404", action: note.update)
		} catch {
			XCTAssertEqual(
				error as? AppNetworkResponseError,
				AppNetworkResponseError.unexpected(statusCode: 404)
			)
		}
	}

	func test_GivenSomeValidNotes_WhenComparingThem_ThenComparisonMatches() {
		let noteA = Note(id: "a", name: "b", content: "c")
		let noteB = Note(id: "a", name: "b", content: "c")
		XCTAssertEqual(noteA, noteB)

		let noteC = Note(id: "a", name: "b", content: "c")
		let noteD = Note(id: "aa", name: "b", content: "c")
		XCTAssertNotEqual(noteC, noteD)

		let noteE = Note(id: "a", name: "b", content: "c")
		let noteF = Note(id: "a", name: "bb", content: "c")
		XCTAssertNotEqual(noteE, noteF)

		let noteG = Note(id: "a", name: "b", content: "c")
		let noteH = Note(id: "a", name: "b", content: "cc")
		XCTAssertNotEqual(noteG, noteH)
	}
}
