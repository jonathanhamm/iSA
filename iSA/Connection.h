//
//  Connection.h
//  iSA
//
//  Created by Pope Pius VII on 3/30/15.
//  Copyright (c) 2015 Pope Pius VII. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Connection : NSObject

@property (readwrite) CFReadStreamRef readStream;
@property (readwrite) CFWriteStreamRef writeStream;
@property (readwrite) dispatch_source_t dsource;

- (void) connect: (NSString *)hostName Port:(UInt16)port;

-(id)init:(NSString *)hostName Port:(UInt16)port;

@end
