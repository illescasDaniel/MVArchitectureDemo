//
//  HTTPInterceptor.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

import Foundation

protocol HTTPInterceptor {
	func data(for httpRequest: HTTPURLRequest, httpHandler: HTTPHandler) async throws -> (Data, HTTPURLResponse)
}
