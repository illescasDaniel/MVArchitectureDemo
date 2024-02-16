//
//  Config.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

#if !DEBUG
// DO NOT MODIFY.
// To modify debug config, see DebugConfig.swift
final class Config {
	static let httpClient: HTTPClient = HTTPClientImpl(urlSession: URLSession(configuration: .default))
	static let environment: ServerEnvironment = ServerEnvironment.production
}
#endif
