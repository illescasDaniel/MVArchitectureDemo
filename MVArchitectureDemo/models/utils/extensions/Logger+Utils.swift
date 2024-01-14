//
//  View+Logger.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/10/23.
//

import SwiftUI
import OSLog

// to do: if it is a preview, use print instead

extension View {
	var logger: Logger {
		Logger(
			subsystem: Bundle.main.bundleIdentifier ?? "App",
			category: String(describing: Self.self)
		)
	}
}

extension Logger {
	func error(_ error: Error) {
		var description: String = ""
		dump(error, to: &description)
		self.error("\(error.localizedDescription)\nError details:\n\(description)")
	}
}

extension Observable {
	var logger: Logger {
		Logger(
			subsystem: Bundle.main.bundleIdentifier ?? "App",
			category: String(describing: Self.self)
		)
	}
}
