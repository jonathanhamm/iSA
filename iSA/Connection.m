//
//  Connection.m
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

#import "Connection.h"

@implementation Connection

@synthesize readStream;
@synthesize writeStream;

@synthesize dsource;

-  (void)connect:(NSString *)hostName Port:(UInt16)port
{
    CFReadStreamRef lreadStream = nil;
    CFWriteStreamRef lwriteStream = nil;
    
    CFHostRef cfHost = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostName);
    
    CFStreamCreatePairWithSocketToCFHost(kCFAllocatorDefault, cfHost, port, &lreadStream, &lwriteStream);
    
    assert(lreadStream);
    
    assert(lwriteStream);
    
    self.readStream = lreadStream;
    self.writeStream = lwriteStream;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    self.dsource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, (uintptr_t)lreadStream, 0, queue);
    
}

-(id)init:(NSString *)hostName Port:(UInt16)port {
    if(self = [super init]) {
        [self connect:hostName Port: port];
    }
    return self;
}


@end
