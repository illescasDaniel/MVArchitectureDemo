//
//  HTTPURLResponse+Extension.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 18/10/23.
//

#if DEBUG
import Foundation

extension HTTPURLResponse {
	convenience init?(url: URL, statusCode: Int) {
		self.init(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
	}
	static func statusCode(_ statusCode: Int) -> HTTPURLResponse {
		return HTTPURLResponse(url: Config.environment.baseURL, statusCode: statusCode)!
	}
}
#endif
