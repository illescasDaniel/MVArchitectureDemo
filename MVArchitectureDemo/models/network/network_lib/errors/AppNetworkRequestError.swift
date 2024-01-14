//
//  AppNetworkRequestError.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/10/23.
//

import Foundation

enum AppNetworkRequestError: Error {
	case invalidScheme(String?)
	case invalidJSONObject([String: Any])
}
