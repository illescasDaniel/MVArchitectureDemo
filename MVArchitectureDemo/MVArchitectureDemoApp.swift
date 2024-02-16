//
//  MVArchitectureDemoApp.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import SwiftUI

@main
struct MVArchitectureDemoApp: App {
	var body: some Scene {
		WindowGroup {
			#if DEBUG
			// no need to open or render the app if we are testing...
			if Config.isTest {
				EmptyView()
			} else {
				NotesScreenView()
			}
			#else
			NotesScreenView()
			#endif
		}
	}
}
