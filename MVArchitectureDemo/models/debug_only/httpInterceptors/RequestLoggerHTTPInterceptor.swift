//
//  RequestLoggerHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation
import OSLog

final class RequestLoggerHTTPInterceptor: HTTPInterceptor {

	func data(for httpRequest: HTTPURLRequest, httpHandler: HTTPHandler) async throws -> (Data, HTTPURLResponse) {
		let logger = Logger.current(for: Self.self)
		let request = httpRequest.urlRequest
		let (data, response) = try await httpHandler.proceed(httpRequest)

		if Config.isSwiftUIPreviewRunning {
			print("""
			----
			- Request: \(request.url?.path(percentEncoded: false) ?? "nil")
			  - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			- Response: \(response.statusCode)
			  - Body content: \(String(decoding: data, as: UTF8.self))
			----
			""")
		} else {
			logger.info("""
			- Request: \(request.url?.path(percentEncoded: false) ?? "nil")
			  - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			- Response: \(response.statusCode)
			  - Body content: \(String(decoding: data, as: UTF8.self))
			""")
		}
		return (data, response)
	}
}
#endif
