//
//  View+Logger.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/10/23.
//

import SwiftUI
import os

nonisolated extension Logger {
	static func current<T>(for classType: T.Type) -> Logger {
		Logger(
			subsystem: Bundle.main.bundleIdentifier ?? "App",
			category: String(describing: classType)
		)
	}
	func error(_ error: Error) {
		var description: String = ""
		dump(error, to: &description)
		self.error("\(error.localizedDescription)\nError details:\n\(description)")
	}
}

extension View {
	var logger: Logger {
		Logger(
			subsystem: Bundle.main.bundleIdentifier ?? "App",
			category: String(describing: Self.self)
		)
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
