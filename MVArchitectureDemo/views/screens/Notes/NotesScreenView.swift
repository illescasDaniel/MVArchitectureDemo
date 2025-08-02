//
//  ContentView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesScreenView: View {
	var body: some View {
		ViewStateHandler { notes in
			NavigationStack {
				NotesListView(notes: notes.wrappedValue.map(Note.init))
					.navigationTitle("Something")
			}
		} loadDataAction: {
			try await Note.all()
		}
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
