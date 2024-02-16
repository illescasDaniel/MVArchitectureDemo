//
//  Initiable.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 16/2/24.
//

import Foundation

protocol Initiable {
	init()
}

extension String: Initiable {}
extension Array: Initiable {}
