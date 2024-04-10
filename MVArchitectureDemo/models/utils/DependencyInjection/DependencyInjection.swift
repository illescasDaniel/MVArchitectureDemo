//
//  DependencyInjection.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

import Foundation
import DIC

protocol DependencyInjection {
	var diContainer: MiniDependencyInjectionContainer { get }
	func registerDependencies()
}
extension DependencyInjection {
	func get<T>(_ type: T.Type) -> T {
		diContainer.load(type)
	}
}
