//
//  AppServerAvailabilityError.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

enum AppServerAvailabilityError: Error, LocalizedError {

	case unavailable(statusCode: Int)
	case failure(Error)

	var errorDescription: String? {
		switch self {
		case let .unavailable(statusCode):
			return "Server is currently unavailable. Status code: \(statusCode)"
		case let .failure(error):
			return "Error checking server availability. Internal error: \(error.localizedDescription)"
		}
	}
}
