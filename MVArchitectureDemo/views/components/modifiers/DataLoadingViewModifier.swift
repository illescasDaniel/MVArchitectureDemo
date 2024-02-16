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

fileprivate struct ArrayDataLoadingViewModifier<T: Equatable>: ViewModifier {

	@Binding var data: [T]
	@State var viewState: ViewState = .idle
	let getData: @Sendable () async throws -> [T]

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

	private func loadDataAction() async {
		await ViewState.update($data, $viewState, getData: getData)
	}
}

//fileprivate struct DataLoadingViewModifier2<T: Equatable>: ViewModifier {
//
//	@Binding var data: T
//	@Binding var viewState: ViewState
//	let getData: @Sendable () async throws -> T
//
//	func body(content: Content) -> some View {
//		content
//			.opacity(viewState.isSuccess ? 1 : 0)
//			.refreshable {
//				await loadDataAction()
//			}
//			.viewStateOverlay($viewState) {
//				await loadDataAction()
//			}
//			.task {
//				viewState = .loading
//				await loadDataAction()
//			}
//	}
//
//	private func loadDataAction() async {
//		await ViewState.update($data, $viewState, getData: getData)
//	}
//}

extension View {
	func dataLoading(
		_ viewState: Binding<ViewState>,
		_ loadDataAction: @escaping @Sendable () async -> Void
	) -> some View {
		let modifier = DataLoadingViewModifier(viewState: viewState, loadDataAction: loadDataAction)
		return self.modifier(modifier)
	}

	func dataLoadingHandler<T: Equatable>(
		for data: Binding<[T]>,
		getData: @Sendable @escaping () async throws -> [T]
	) -> some View {
		let modifier = ArrayDataLoadingViewModifier(data: data, getData: getData)
		return self.modifier(modifier)
	}

//	func dataLoading<T: Equatable>(
//		data: Binding<T>,
//		state viewState: Binding<ViewState>,
//		getData: @Sendable @escaping () async throws -> T
//	) -> some View {
//		let modifier = DataLoadingViewModifier2(data: data, viewState: viewState, getData: getData)
//		return self.modifier(modifier)
//	}
}
