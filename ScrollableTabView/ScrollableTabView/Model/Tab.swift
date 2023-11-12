//
//  Tab.swift
//  ScrollableTabView
//
//  Created by Javier Rodríguez Gómez on 11/11/23.
//

import SwiftUI

// Tab's
enum Tab: String, CaseIterable {
	case chats = "Chats"
	case calls = "Calls"
	case settings = "Settings"
	
	var systemImage: String {
		switch self {
			case .calls: "phone"
			case .chats: "bubble.left.and.bubble.right"
			case .settings: "gear"
		}
	}
}
