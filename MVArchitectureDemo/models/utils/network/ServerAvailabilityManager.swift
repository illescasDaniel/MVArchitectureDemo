//
//  ServerAvailability.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation
import HTTIES

final class ServerAvailabilityManager {
	static func checkAvailability() async throws {
		var statusCode: Int = -1
		do {
			let request = try HTTPURLRequest(url: DI.load(ServerEnvironment.self).baseURL / "isAvailable")
			let httpClient = HTTPClientImpl(httpDataRequestHandler: URLSession.shared)//DI.load(HTTPClient.self)
			let (_, response) = try await httpClient.sendRequest(request)
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
