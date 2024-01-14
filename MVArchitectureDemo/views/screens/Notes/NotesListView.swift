//
//  NotesListView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesListView: View {

	let notes: [Note]
	@State var editingNote: Note?
	@State var isPresentingEditingNoteAlert = false
	@State var newName: String = ""
	@State var newContent: String = ""

	var body: some View {
		List(notes) { note in
			Button {
				editingNote = note
				newName = note.name
				newContent = note.content
				withAnimation {
					isPresentingEditingNoteAlert = true
				}
			} label: {
				VStack(alignment: .leading) {
					Text(note.name)
					Text(note.content)
						.font(.footnote)
				}
			}
		}.alert("Modify note", isPresented: $isPresentingEditingNoteAlert, presenting: editingNote) { note in
			TextField("New name", text: $newName)
			TextField("New content", text: $newContent)
			
			Button(role: .cancel, action: {}, label: {
				Text("Cancel")
			})

			Button("Update") {
				note.name = newName
				note.content = newContent
				Task { try? await note.update() }
			}
		}
	}
}

#if DEBUG
#Preview {
	NotesListView(notes: [
		.init(id: "1", name: "Demo 1", content: "Content 1"),
		.init(id: "2", name: "Demo 2", content: "Content 2"),
	])
}
#endif
