//
//  MVArchitectureDemoApp.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

@main
struct MVArchitectureDemoApp: App {

	#if DEBUG
	var body: some Scene {
		WindowGroup {
			// no need to open or render the app if we are testing...
			if !Config.isTest {
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

	var rootView: some View {
		NotesScreenView()
	}
}
