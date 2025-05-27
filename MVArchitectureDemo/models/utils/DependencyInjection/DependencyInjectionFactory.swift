//
//  DependencyInjectionFactory.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 10/4/24.
//

import Foundation

struct DependencyInjectionFactory {
	static func get() -> DependencyInjection {
		#if DEBUG
		if Config.isRunningUnitTests {
			return DebugUnitTestsDependencyInjection()
		} else if Config.isSwiftUIPreviewRunning {
			return DebugSwiftUIPreviewsDependencyInjection()
		} else {
			return DebugDependencyInjection()
		}
		#else
		return ProductionDependencyInjection()
		#endif
	}
}
