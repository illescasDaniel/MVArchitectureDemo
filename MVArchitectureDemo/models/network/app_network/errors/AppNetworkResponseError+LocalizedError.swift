//
//  AppNetworkResponseError+LocalizedError.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

extension AppNetworkResponseError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .unexpected(statusCode):
			return "Unexpected status code: \(statusCode)"
		}
	}
}
