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
				NotesListView(notes: notes.wrappedValue)
					.navigationTitle("Something")
			}
		} loadDataAction: {
			try await Note.all()
		}
	}
}

#if DEBUG
#Preview {
	Config.mockInterceptor.removeMockData()
	return NotesScreenView()
}

#Preview("error") {
	Config.mockInterceptor.setMock(response: .statusCode(404), path: "/notes")
	return NotesScreenView()
}

#Preview("error-json") {
	Config.mockInterceptor.setMock(data: Data(), response: .statusCode(200))
	return NotesScreenView()
}

#Preview("empty") {
	Config.mockInterceptor.setMock(
		data: NSDataAsset(name: "empty_content", bundle: .main)!.data,
		response: .statusCode(200)
	)
	return NotesScreenView()
}
#endif
