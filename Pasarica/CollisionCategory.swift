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
	case Bird  = 1
	case World = 2
	case Pipe  = 4
	case Score = 8
	
	func isBitmask(bitmask : UInt32) -> Bool {
		return self == CollisionCategory(rawValue: bitmask)
	}
}
