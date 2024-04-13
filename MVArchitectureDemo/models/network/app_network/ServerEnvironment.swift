//
//  ServerEnvironment.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import Foundation

enum ServerEnvironment {

	case production
	case localApp
	case localTests

	var baseURL: URL {
		switch self {
		case .production:
			// TO DO: change url
			return URL(string: "http://myProductionURLThatDoesntExistYet")!
		case .localApp:
			return URL(string: "http://127.0.0.1:8082")!
		case .localTests:
			return URL(string: "http://127.0.0.1:8081")!
		}
	}
}
