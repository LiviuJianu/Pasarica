//
//  CollisionCategory.swift
//  Pasarica
//
//  Created by Adi on 24.09.2014.
//  Copyright (c) 2014 Liviu Jianu. All rights reserved.
//

import Foundation

//Collision bit masks
enum CollisionCategory : UInt32 {
	case bird  = 1
	case world = 2
	case pipe  = 4
	case score = 8
	
	func isBitmask(_ bitmask : UInt32) -> Bool {
		return self == CollisionCategory(rawValue: bitmask)
	}
}
