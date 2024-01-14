//
//  ContentView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesScreenView: View {
	
	@State var notes: [Note] = []
	@State var viewState: ViewState = .idle

	var body: some View {
		NavigationStack {
			NotesListView(notes: notes)
				.dataLoading($viewState) {
					(viewState, notes) = await ViewState.create(previous: notes, new: Note.all)
				}
				.navigationTitle("Something")
		}
	}
}

#if DEBUG
#Preview {
	NotesScreenView()
}

#Preview("error") {
	Config.httpClient.setMock(response: .statusCode(404), path: "/notes")
	return NotesScreenView()
}

#Preview("error-json") {
	Config.httpClient.setMock(data: Data(), response: .statusCode(200))
	return NotesScreenView()
}

#Preview("empty") {
	Config.httpClient.setMock(
		data: NSDataAsset(name: "empty_content", bundle: .main)!.data,
		response: .statusCode(200)
	)
	return NotesScreenView()
}
#endif
