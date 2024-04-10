//
//  Config.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation
import DIC

#if !DEBUG
// DO NOT MODIFY.
// To modify debug config, see DebugConfig.swift
final class Config {
	static let environment: ServerEnvironment = ServerEnvironment.production
}
#endif
