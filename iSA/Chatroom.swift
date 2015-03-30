//
//  Chatroom.swift
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

import UIKit

class Chatroom: NSObject {
    enum Server: String {
        case S_2D_CENTRAL = "74.86.43.9"
        case S_PAPER_THIN = "74.86.43.8"
        case S_FLAT_WORLD = "74.86.3.220"
        case S_PLANAR_OUTPOST = "67.19.138.235"
        case S_MOBIUS_METROPOLIS = "74.86.3.221"
        case S_AMSTERDAM = "94.75.214.10"
        case S_COMPATABILITY = "74.86.3.222"
        case S_SS_LINEAGE = "74.86.43.10"
    }
 
    func connect(username: String, password: String, server: Server) -> Bool {
        return true
    }
}
