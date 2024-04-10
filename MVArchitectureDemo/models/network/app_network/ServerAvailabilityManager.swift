//
//  ServerAvailability.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation

class ServerAvailabilityManager {
	static func checkAvailability() async throws {
		var statusCode: Int = -1
		do {
			let request = try HTTPURLRequest(url: DI.get(ServerEnvironment.self).baseURL.appending(path: "isAvailable"))
			let (_, response) = try await DI.get(HTTPClient.self).data(for: request)
			statusCode = response.statusCode
		} catch {
			throw AppServerAvailabilityError.failure(error)
		}
		let isOK = statusCode == 200
		if !isOK {
			throw AppServerAvailabilityError.unavailable(statusCode: statusCode)
		}
	}
}
