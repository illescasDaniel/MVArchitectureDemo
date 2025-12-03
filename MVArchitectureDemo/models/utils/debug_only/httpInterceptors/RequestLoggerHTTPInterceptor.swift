//
//  RequestLoggerHTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

#if DEBUG
import Foundation
import HTTIES
import OSLog

actor HTTPLoggerInterceptor: HTTPResponseInterceptor {

	func intercept(data: Data, response: HTTPURLResponse, error: Error?, for request: URLRequest) -> (Data, HTTPURLResponse, Error?) {
		let logger = Logger.current(for: Self.self)
		if Config.isSwiftUIPreviewRunning {
			print("""
			+--------------------------------------------------------------------------------+
			| - Request: \(request.url?.path(percentEncoded: false) ?? "nil")
			|   - HTTP method: \(request.httpMethod ?? "")
			|   - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			| - Response: \(response.statusCode)
			|   - Body content: \(String(decoding: data, as: UTF8.self))
			+--------------------------------------------------------------------------------+
			""")

		} else {
			logger.info("""
			- Request: \(request.url?.path(percentEncoded: false) ?? "nil")
			  - Body parameters: \(request.httpBody.map { String(decoding: $0, as: UTF8.self) } ?? "nil")
			- Response: \(response.statusCode)
			  - Body content: \(String(decoding: data, as: UTF8.self))
			""")
		}
		return (data, response, error)
	}
}
#endif
