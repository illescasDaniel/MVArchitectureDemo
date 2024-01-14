//
//  ViewStateOverlayModifier.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import SwiftUI

fileprivate struct ViewStateOverlayModifier: ViewModifier {

	@Binding var viewState: ViewState
	let loadDataAction: @Sendable () async -> Void

	func body(content: Content) -> some View {
		content
			.overlay {
				switch viewState {
				case .idle, .success:
					EmptyView()
				case let .error(error):
					ContentUnavailableView {
						Label("Error", systemImage: "xmark.octagon.fill")
							.foregroundStyle(Color.red)
					} description: {
						Text(verbatim: error.localizedDescription)
							.monospaced()
					} actions: {
						Button("Retry") {
							Task {
								viewState = .loading
								await loadDataAction()
							}
						}.buttonStyle(.borderedProminent)
					}
				case .loading:
					ProgressView()
						.progressViewStyle(.circular)
				case .empty:
					ContentUnavailableView {
						Label("Empty", systemImage: "tray.fill")
					} actions: {
						Button {
							Task {
								viewState = .loading
								await loadDataAction()
							}
						} label: {
							Text("Reload")
								.font(.footnote)
						}
						.buttonStyle(.borderless)
						.padding(.top, 4)
					}
				}
			}
	}
}

extension View {
	func viewStateOverlay(_ viewState: Binding<ViewState>, loadDataAction: @Sendable @escaping () async -> Void) -> some View {
		let viewStateOverlayModifier = ViewStateOverlayModifier(viewState: viewState, loadDataAction: loadDataAction)
		return self.modifier(viewStateOverlayModifier)
	}
}
