//
//  HeroKey.swift
//  PhotosAppTransition
//
//  Created by Javier Rodríguez Gómez on 11/5/24.
//

import SwiftUI

struct HeroKey: PreferenceKey {
	static var defaultValue: [String: Anchor<CGRect>] = [:]
	static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
		value.merge(nextValue()) { $1 }
	}
}
