//
//  NotesListView.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

struct NotesListView: View {

	@Binding var noteList: NoteList

	@State
	private var editingNote: Note?
	@State
	private var isPresentingEditingNoteAlert = false
	@State
	private var isPresentingAddNoteAlert = false
	@State
	private var newName: String = ""
	@State
	private var newContent: String = ""

	var body: some View {
		List($noteList.notes, editActions: .delete) { note in
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
		.navigationTitle("Notes")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {
					newName = ""
					newContent = ""
					isPresentingAddNoteAlert = true
				} label: {
					Image(systemName: "plus")
				}
			}
		}
		.alert("Add Note", isPresented: $isPresentingAddNoteAlert) {
			TextField("Note name", text: $newName)
			TextField("Note content", text: $newContent)

			Button(role: .cancel, action: {}, label: {
				Text("Cancel")
			})

			Button("Add") {
				let newNote = Note(name: newName, content: newContent)
				noteList.notes.append(newNote)
			}
			.disabled(newName.isEmpty)
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
		.onChange(of: noteList.notes) { [noteList] _, _ in
			Task { try? await noteList.update() }
		}
	}
}

#if DEBUG
#Preview {
	@Previewable @State var noteList: NoteList = NoteList(notes: [
		.init(id: "1", name: "Demo 1", content: "Content 1"),
		.init(id: "2", name: "Demo 2", content: "Content 2"),
	])
	NavigationView {
		NotesListView(noteList: $noteList)
	}
}
#endif
