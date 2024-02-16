//
//  ViewState.swift
//  MVArchitectureDemo
//
//  Created by Daniel Illescas Romero on 14/1/24.
//

import Foundation
import SwiftUI

enum ViewState {
	case idle
	case loading
	case error(_ error: Error)
	case empty
	case success

	var isSuccess: Bool {
		if case .success = self {
			return true
		}
		return false
	}
}
