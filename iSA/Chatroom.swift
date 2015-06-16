//
//  Chatroom.swift
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

import UIKit



class Chatroom: NSObject, NSStreamDelegate {
    
    let saInit = "08HxO9TdCC62Nwln1P"
    
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
    var host: Server = Server.S_NONE
    
    

 
    func connect(username: String, password: String, server: Server) -> Bool {
        //Connection.connect(server.description, port: saPort)
     //   let connection = Connection(server.description, port: saPort)
        initStreams(server)
        return true
    }
    
    func initStreams(server: Server) -> Bool {
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
    
    func test() {
        self.connect("obama.in.bubble.bath", password: "asdf", server: Server.S_2D_CENTRAL)
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
    
    func parse() -> Void {
        
        func parse0() -> Void {
            if let c = nextChar() {
                switch(c) {
                    case "8": println("check server good!")
                    default: println("wtf")
                }
            }
        }
        
        if let c = nextChar() {
            if(c == "0") {
                parse0()
            }
            else {
                
            }
        }
        
    }
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch(eventCode) {
            case NSStreamEvent.HasBytesAvailable:
                if(aStream == read) {
                    parse()
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
    
}
