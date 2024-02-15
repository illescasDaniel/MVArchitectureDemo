//
//  DebugConfig.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation

final class Config {

	static var httpClient: DebugHTTPClient = DebugHTTPClient(urlSession: URLSession(configuration: .ephemeral))

	// Debug user could change environment in Settings app
	// then we could get the current environment using UserDefaults
	static var environment: ServerEnvironment = ServerEnvironment.localApp

	static var isNetworkDelayEnabled: Bool {
		let isTest = UserDefaults.standard.bool(forKey: "isTest")
		if isTest {
			return false
		} else {
			// only change this if needed:
			return true
		}
	}
}
#endif
