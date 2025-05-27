//
//  MVArchitectureDemoApp.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

let DI = DependencyInjectionFactory.get()

@main
struct MVArchitectureDemoApp: App {

	init() {
		DI.registerDependencies()
	}

	var rootView: some View {
		NotesScreenView()
	}

	#if DEBUG
	var body: some Scene {
		WindowGroup {
			// no need to render the app if we are running unit tests...
			if !Config.isRunningUnitTests {
				rootView
			}
		}
	}
	#else
	var body: some Scene {
		WindowGroup {
			rootView
		}
	}
	#endif
}
