//
//  ViewStateHandler.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import SwiftUI

@MainActor
struct ViewStateHandler<Content: View, T: Equatable & EmptyProtocol & Sendable, U: Equatable & EmptyProtocol>: View {

	@State
	private var data: U = .empty()

	@State
	private var viewState: ViewState = .idle

	private let contentBuilder: (Binding<U>) -> Content
	private let getData: () async throws -> T
	private let converter: ((T) -> U)?

	private let errorView: ((Error, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	private let loadingView: ((Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	private let emptyView: ((U, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?

	private init(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: ((T) -> U)?,
		loadingAnyView: ((Binding<ViewState>, @escaping () async -> Void) -> AnyView)?,
		errorAnyView: ((Error, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?,
		emptyAnyView: ((U, Binding<ViewState>, @escaping () async -> Void) -> AnyView)?
	) {
		self.getData = getData
		self.contentBuilder = contentBuilder
		self.converter = converter

		self.loadingView = loadingAnyView
		self.errorView = errorAnyView
		self.emptyView = emptyAnyView
	}

	// MARK: - Initializers without converter (T == U)
	init(
		contentBuilder: @escaping (Binding<T>) -> Content,
		loadDataAction getData: @escaping () async throws -> T
	) where T == U {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: nil, loadingAnyView: nil, errorAnyView: nil, emptyAnyView: nil)
	}

	init<LoadingContent: View>(
		contentBuilder: @escaping (Binding<T>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent)
	) where T == U {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: nil, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: nil, emptyAnyView: nil)
	}

	// MARK: - Initializers with converter
	init(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: nil, errorAnyView: nil, emptyAnyView: nil)
	}

	init<LoadingContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: nil, emptyAnyView: nil)
	}

	init<ErrorContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: nil, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: nil)
	}

	init<EmptyContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		emptyView: @escaping ((U, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: nil, errorAnyView: nil, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}

	init<LoadingContent: View, ErrorContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent),
		errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: nil)
	}

	init<LoadingContent: View, EmptyContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent),
		emptyView: @escaping ((U, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: nil, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}

	init<ErrorContent: View, EmptyContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent),
		emptyView: @escaping ((U, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: nil, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
	}

	init<LoadingContent: View, ErrorContent: View, EmptyContent: View>(
		contentBuilder: @escaping (Binding<U>) -> Content,
		loadDataAction getData: @escaping () async throws -> T,
		converter: @escaping (T) -> U,
		loadingView: @escaping ((Binding<ViewState>, @escaping () async -> Void) -> LoadingContent),
		errorView: @escaping ((Error, Binding<ViewState>, @escaping () async -> Void) -> ErrorContent),
		emptyView: @escaping ((U, Binding<ViewState>, @escaping () async -> Void) -> EmptyContent)
	) {
		self.init(contentBuilder: contentBuilder, loadDataAction: getData, converter: converter, loadingAnyView: { AnyView(loadingView($0, $1)) }, errorAnyView: { AnyView(errorView($0, $1, $2)) }, emptyAnyView: { AnyView(emptyView($0, $1, $2)) })
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
								withAnimation {
									viewState = .loading
								}
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
								withAnimation {
									viewState = .loading
								}
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
				withAnimation {
					viewState = .loading
				}
				await loadDataAction()
			}
	}

	private func loadDataAction() async {
		do {
			let rawData = try await getData()
			let convertedData = converter?(rawData) ?? (rawData as! U)

			if convertedData.isEmpty {
				data = .empty()
				withAnimation {
					viewState = .empty
				}
			} else {
				data = convertedData
				withAnimation {
					viewState = .success
				}
			}
		} catch {
			withAnimation {
				viewState = .error(error)
			}
		}
	}
}
