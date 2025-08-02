//
//  NotesListView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesListView: View {

	@Binding var notes: [Note]

	@State
	private var editingNote: Note?
	@State
	private var isPresentingEditingNoteAlert = false
	@State
	private var newName: String = ""
	@State
	private var newContent: String = ""

	var body: some View {
		List($notes, editActions: .delete) { note in
			Button {
				editingNote = note.wrappedValue
				newName = note.wrappedValue.name
				newContent = note.wrappedValue.content
				withAnimation {
					isPresentingEditingNoteAlert = true
				}
			} label: {
				VStack(alignment: .leading) {
					Text(note.wrappedValue.name)
					Text(note.wrappedValue.content)
						.font(.footnote)
				}
			}
		}
		.alert("Modify note", isPresented: $isPresentingEditingNoteAlert, presenting: editingNote) { note in
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
		.onChange(of: notes) { oldValue, newValue in
			print(oldValue, newValue)
		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var notes: [Note] = [
		.init(id: "1", name: "Demo 1", content: "Content 1"),
		.init(id: "2", name: "Demo 2", content: "Content 2"),
	]
	NotesListView(notes: $notes)
}
#endif
