//
//  AppNetworkRequestError_LocalizedError.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

extension AppNetworkRequestError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case let .invalidScheme(scheme):
			return "Invalid scheme: \(String(describing: scheme))"
		case let .invalidJSONObject(object):
			return "Invalid JSON object: \(object)"
		}
	}
}
