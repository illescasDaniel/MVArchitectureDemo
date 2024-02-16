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
	private let emptyView: ((T, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?

	private init(
		contentBuilder: @escaping (Binding<T>) -> Content,
		loadDataAction getData: @Sendable @escaping () async throws -> T,
		loadingAnyView: ((Binding<ViewState>, @escaping () async -> Void) -> AnyView)?,
		errorAnyView: ((Error, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?,
		emptyAnyView: ((T, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	) {
		self.getData = getData
		self.contentBuilder = contentBuilder

		self.loadingView = loadingAnyView
		self.errorView = errorAnyView
		self.emptyView = emptyAnyView
	}

	init(
		contentBuilder: @escaping (Binding<T>) -> Content,
		loadDataAction getData: @Sendable @escaping () async throws -> T
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: nil, errorAnyView: nil, emptyAnyView: nil)
	}

	init<LoadingContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: nil, emptyAnyView: nil)
	}
	init<ErrorContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: nil, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: nil)
	}
	init<EmptyContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, emptyView: @escaping ((T, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: nil, errorAnyView: nil, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}
	init<LoadingContent: View, ErrorContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent), errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: nil)
	}
	init<LoadingContent: View, EmptyContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent), emptyView: @escaping ((T, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: nil, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}
	init<ErrorContent: View, EmptyContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent), emptyView: @escaping ((T, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: nil, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}
	init<LoadingContent: View, ErrorContent: View, EmptyContent: View>(contentBuilder: @escaping (Binding<T>) -> Content, loadDataAction getData: @Sendable @escaping () async throws -> T, loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent), errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent), emptyView: @escaping ((T, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
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
					emptyView?(data, $viewState, loadDataAction) ?? AnyView(
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
