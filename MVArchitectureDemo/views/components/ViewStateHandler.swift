//
//  ViewStateHandler.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import SwiftUI

struct ViewStateHandler<Content: View, T: Equatable & EmptyProtocol>: View {

	@State
	private var data: T = .empty()

	@State
	private var viewState: ViewState = .idle

	private let contentBuilder: (Binding<T>) -> Content
	private let getData: @Sendable () async throws -> T
	
	private let errorView: ((Error, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	private let loadingView: ((Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	private let emptyContent: ((T, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?

	init(
		contentBuilder: @escaping (Binding<T>) -> Content,
		loadDataAction getData: @Sendable @escaping () async throws -> T,
		errorView: ((Error, Binding<ViewState>, @escaping () async -> Void)  -> AnyView)? = nil,
		loadingView: ((Binding<ViewState>, @escaping () async -> Void)  -> AnyView)? = nil,
		emptyContent: ((T, Binding<ViewState>, @escaping () async -> Void)  -> AnyView)? = nil
	) {
		self.getData = getData
		self.contentBuilder = contentBuilder

		self.errorView = errorView
		self.loadingView = loadingView
		self.emptyContent = emptyContent
	}

	var body: some View {
		contentBuilder($data)
			.opacity(viewState.isSuccess ? 1 : 0)
			.refreshable {
				await loadDataAction()
			}
			.overlay {
				switch viewState {
				case .idle, .success:
					EmptyView()
				case let .error(error):
					errorView?(error, $viewState, loadDataAction) ?? AnyView(
						ContentUnavailableView {
							Label("Error", systemImage: "xmark.octagon.fill")
								.foregroundStyle(Color.red)
						} description: {
							Text(verbatim: error.localizedDescription)
								.monospaced()
						} actions: {
							Button("Retry") {
								viewState = .loading
								Task {
									await loadDataAction()
								}
							}.buttonStyle(.borderedProminent)
						}
					)
				case .loading:
					loadingView?($viewState, loadDataAction) ?? AnyView(
						ProgressView()
							.progressViewStyle(.circular)
					)
				case .empty:
					emptyContent?(data, $viewState, loadDataAction) ?? AnyView(
						ContentUnavailableView {
							Label("Empty", systemImage: "tray.fill")
						} actions: {
							Button {
								viewState = .loading
								Task {
									await loadDataAction()
								}
							} label: {
								Text("Reload")
									.font(.footnote)
							}
							.buttonStyle(.borderless)
							.padding(.top, 4)
						}
					)
				}
			}
			.task {
				viewState = .loading
				await loadDataAction()
			}
	}

	private func loadDataAction() async {
		do {
			let newData = try await getData()
			if newData.isEmpty {
				data = .empty()
				viewState = .empty
			} else {
				data = newData
				viewState = .success
			}
		} catch {
			viewState = .error(error)
		}
	}
}
