//
//  AppNetworkError.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/10/23.
//

import Foundation

enum AppNetworkResponseError: Error {
	case unexpected(statusCode: Int)
}
