//
//  NSData+Hex.m
//  Mcs
//
//  Created by shaomou chen on 5/23/12.
//  Copyright (c) 2012 RYTong. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData (Hex)

- (NSString*) stringWithHexBytes {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	int i;
	for (i = 0; i < [self length]; ++i) {
		[stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
	}
	return [stringBuffer copy];
}

@end
