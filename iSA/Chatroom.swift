//
//  Chatroom.swift
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

import UIKit

class User {
    let chatRoom: Chatroom
    let maxUserNameSize = 20
    let id: String
    var name: String = ""

    init(userSelf: Chatroom) {
        self.chatRoom = userSelf
        id = chatRoom.parseId()
        parseUsername()
        chatRoom.finish()
    }
    
    init(userRemote: Chatroom) {
        self.chatRoom = userRemote
        id = chatRoom.parseId()
        parseUsername()
        chatRoom.finish()
    }
    
    func parseUsername() -> Void {
        var count = 0
        var c = chatRoom.nextChar()!
        
        while(c == "#") {
            c = chatRoom.nextChar()!
            count++
        }
        
        let usernameLength = maxUserNameSize - count
        name.append(c)
        for _ in 2 ... usernameLength {
            name.append(chatRoom.nextChar()!)
        }
        
        println("username: " + name)
    }
    
}

class Chatroom: NSObject, NSStreamDelegate {
    
    let saInit = "08HxO9TdCC62Nwln1P"
    let finishLogin = "03_"
    
    let ui: FirstViewController
    
    let maxRoomName = 20
    
    var usernameMap = Dictionary<String, User>()
    var uidMap = Dictionary<String, User>()
    
    enum Server: String {
        case S_2D_CENTRAL = "74.86.43.9"
        case S_PAPER_THIN = "74.86.43.8"
        case S_FLAT_WORLD = "74.86.3.220"
        case S_PLANAR_OUTPOST = "67.19.138.235"
        case S_MOBIUS_METROPOLIS = "74.86.3.221"
        case S_AMSTERDAM = "94.75.214.10"
        case S_COMPATABILITY = "74.86.3.222"
        case S_SS_LINEAGE = "74.86.43.10"
        case S_NONE = "0.0.0.0"
        
        var description: String {
            println("raw value: " + self.rawValue)
            return self.rawValue
        }
    }
    

    let saPort = 1138
    var read: NSInputStream! = nil
    var write: NSOutputStream! = nil
    var isWriteable = false
    var user: User? = nil
    
    let username: String
    let password: String
    let server: Server
    
    
    init(ui: FirstViewController, username: String, password: String, server: Server) {
        self.ui = ui
        self.username = username
        self.password = password
        self.server = server
        
        super.init()

        connect()
    }
    
    func connect() -> Bool {
        var pInput: NSInputStream? = nil
        var pOutput: NSOutputStream? = nil
        
        NSStream.getStreamsToHostWithName(server.description, port: saPort, inputStream: &pInput, outputStream: &pOutput)
        
        self.read = pInput
        self.write = pOutput
        
        if let input = pInput {
            if let output = pOutput {
                let sockQueue = dispatch_queue_create("readQueue", DISPATCH_QUEUE_SERIAL)
                
                dispatch_async(sockQueue) {
                    let loop = NSRunLoop.currentRunLoop()
                    input.delegate = self
                    input.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
                    input.open()
                    
                    output.delegate = self
                    output.scheduleInRunLoop(loop, forMode: NSDefaultRunLoopMode)
                    output.open()
                    loop.run()
                }
            }
            else {
                perror("Failed to initialize output stream")
            }
        }
        else {
            perror("Failed to initialize input stream")
            if pOutput == nil {
                perror("Failed to initialize output stream")
            }
        }
        
        return false
    }
        
    func writeString(str: String) {
        let cstr = str.cStringUsingEncoding(NSUTF8StringEncoding)!
    
        var data: UnsafePointer<CChar> = cstr.withUnsafeBufferPointer{pointer in return pointer.baseAddress}
        write.write(UnsafePointer<UInt8>(data), maxLength: cstr.count)
    }
    

    func nextChar() -> Character? {
        var byte: UInt8 = 0
        read.read(&byte, maxLength: 1)
        return (byte == 0) ? nil : Character(UnicodeScalar(byte))
    }
    
    func sendAuth() -> Void {
        let msg = "09\(username);\(password)"
        writeString(msg)
    }
    
    func parseRoomsList() -> Void {
        finish()
    }

    func parse() -> Void {
        
        func parse0() -> Void {
            if let c = nextChar() {
                switch(c) {
                    case "1": parseRoomsList()
                    case "8": sendAuth()
                    case "9": println("server error")
                    default: break
                }
            }
        }
        
        func parseA() -> Void {
            writeString(finishLogin)
            user = User(userSelf: self)
            usernameMap[user!.name] = user!
            uidMap[user!.name] = user!
        }
        
        func parseD() -> Void {
            let id = parseId()
            if let u = uidMap.removeValueForKey(id) {
                println("\(u.name) left lobby")
            }
        }
        
        func parseM() -> Void {
            let id = parseId()
            let sender = uidMap[id]
            let type = nextChar()!
            let body = getRemainder()
            
            if(type == "9") {
                if let s = sender {
                    println("\(s.name): \(body)")
                }
                else {
                    perror("error")
                }
            }
            else if(type == "P") {
                if let s = sender {
                    println("\(s.name) <private>: \(body)")
                }
                else {
                    perror("error")
                }
            }
            else {
                println("weird message")
            }
            
        }
        
        func parseU() -> Void {
            let user = User(userRemote: self)
            usernameMap[user.name] = user
            uidMap[user.id] = user
            
            ui.usernameList.beginUpdates()
            
            ui.usernameList.endUpdates()
            
            //ui.usernameList.inser
        }
        
        if let c = nextChar() {
            
            switch(c) {
                case "0": parse0()
                case "A": parseA()
                case "D": parseD()
                case "M": parseM()
                case "U": parseU()
                default: break
            }
        }
        
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch(eventCode) {
            case NSStreamEvent.HasBytesAvailable:
                if(aStream == read) {
                    while(read.hasBytesAvailable) {
                        parse()
                    }
                }
                else {
                    
                }
            case NSStreamEvent.ErrorOccurred: {
                perror("error")
            }()
            case NSStreamEvent.OpenCompleted:
                if(aStream == write) {
                    println("Write Stream Opened")
                }
                else {
                    println("Read Stream Opened")
                }
            case NSStreamEvent.HasSpaceAvailable:
                if(aStream == write) {
                    if(!isWriteable) {
                        writeString("08HxO9TdCC62Nwln1P")
                        isWriteable = true
                    }
                }
                else {
                    println("derrrp")
                }
            default: println("haha")
        }
    }
    
    func parseId() -> String {
        var str = ""
        for _ in 1 ... 3 { str.append(nextChar()!) }
        return str
    }
    
    func getRemainder() -> String {
        var str = ""
        var res = nextChar()
        
        while(res != nil) {
            str.append(res!)
            res = nextChar()
        }
        return str
    }
    
    func finish() -> Void {
        var c = nextChar()
        
        while(c != nil) {
            c = nextChar()
        }
    }

}
