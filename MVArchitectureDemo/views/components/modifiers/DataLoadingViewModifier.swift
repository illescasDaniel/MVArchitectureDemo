//
//  DataLoadingViewModifier.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import SwiftUI

fileprivate struct DataLoadingViewModifier: ViewModifier {

	@Binding var viewState: ViewState
	let loadDataAction: @Sendable () async -> Void

	func body(content: Content) -> some View {
		content
			.opacity(viewState.isSuccess ? 1 : 0)
			.refreshable {
				await loadDataAction()
			}
			.viewStateOverlay($viewState) {
				await loadDataAction()
			}
			.task {
				viewState = .loading
				await loadDataAction()
			}
	}
}
extension View {
	func dataLoading(_ viewState: Binding<ViewState>, _ loadDataAction: @escaping @Sendable () async -> Void) -> some View {
		let modifier = DataLoadingViewModifier(viewState: viewState, loadDataAction: loadDataAction)
		return self.modifier(modifier)
	}
}
