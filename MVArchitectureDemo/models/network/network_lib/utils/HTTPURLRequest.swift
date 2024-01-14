//
//  URLRequest+http.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 9/10/23.
//

import Foundation

struct HTTPURLRequest {
	let urlRequest: URLRequest

	init(
		url: URL,
		httpMethod: HTTPMethod = .get,
		body: Data? = nil,
		queryItems: [URLQueryItem] = [],
		headers: [String: String] = [:]
	) throws {
		guard (url.scheme?.lowercased()).flatMap({ HTTPURLScheme.init(rawValue: $0) }) != nil else {
			throw AppNetworkRequestError.invalidScheme(url.scheme)
		}
		var request: URLRequest
		if queryItems.isEmpty {
			request = URLRequest(url: url)
		} else {
			var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
			urlComponents?.queryItems = queryItems
			request = URLRequest(url: urlComponents?.url ?? url)
		}
		request.httpMethod = httpMethod.rawValue
		request.httpBody = body
		request.allHTTPHeaderFields = headers
		self.urlRequest = request
	}

	init(
		url: URL,
		httpMethod: HTTPMethod = .get,
		bodyDictionary body: [String: Any],
		queryItems: [URLQueryItem] = [],
		headers: [String: String] = [:]
	) throws {
		guard JSONSerialization.isValidJSONObject(body) else {
			throw AppNetworkRequestError.invalidJSONObject(body)
		}
		try self.init(
			url: url,
			httpMethod: httpMethod,
			body: try JSONSerialization.data(withJSONObject: body),
			queryItems: queryItems,
			headers: headers
		)
	}

	init<T: Encodable>(
		url: URL,
		httpMethod: HTTPMethod = .get,
		bodyEncodable body: T,
		jsonEncoder: JSONEncoder = JSONEncoder(),
		queryItems: [URLQueryItem] = [],
		headers: [String: String] = [:]
	) throws {
		try self.init(
			url: url,
			httpMethod: httpMethod,
			body: try jsonEncoder.encode(body),
			queryItems: queryItems,
			headers: headers
		)
	}
}
