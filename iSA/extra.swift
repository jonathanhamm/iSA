//
//  extra.swift
//  iSA
//
//  Created by Jonathan Hamm on 4/9/15.
//  Copyright (c) 2015 Jonathan Hamm. All rights reserved.
//

import Foundation

extension String {
    func getBytes() -> UnsafePointer<UInt8>  {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        return UnsafePointer<UInt8>(data.bytes)
    }
    
    func map<T>(f: Character -> T) -> Array<T> {
        var a = Array<T>()
        for c in self {
            a.append(f(c))
        }
        return a
    }
}

