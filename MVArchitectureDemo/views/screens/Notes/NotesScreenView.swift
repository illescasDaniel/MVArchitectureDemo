//
//  ContentView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesScreenView: View {
	var body: some View {
		ViewStateHandler { noteList in
			NavigationStack {
				NotesListView(noteList: noteList)
					.navigationTitle("Something")
			}
		} loadDataAction: {
			try await NoteList.all()
		} converter: { NoteList(notes: $0) }
	}
}

#if DEBUG
#Preview {
	DI.load(MockHTTPClient.self).removeMockData()
	return NotesScreenView()
}

#Preview("error") {
	DI.load(MockHTTPClient.self).onlyMocking(response: .statusCode(404), for: "/notes")
	return NotesScreenView()
}

#Preview("error2") {
	DI.load(MockHTTPClient.self)
		.removeMockData()
		.setMock(error: NSError(domain: "a", code: 1), for: "/notes")
	return NotesScreenView()
}

#Preview("error-json") {
	DI.load(MockHTTPClient.self)
		.removeMockData()
		.setMock(data: Data(), response: .statusCode(200), for: MockRequest(path: "/notes", method: "GET"))
	return NotesScreenView()
}

#Preview("empty") {
	DI.load(MockHTTPClient.self)
		.removeMockData()
		.setMock(
			data: Data(assetName: "empty_content"),
			response: .statusCode(200)
		)
	return NotesScreenView()
}
#endif
