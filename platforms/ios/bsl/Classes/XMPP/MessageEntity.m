//
//  MessageEntity.m
//  iPhoneXMPP
//
//  Created by 俞 億 on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageEntity.h"
#import "UserQueue.h"
@implementation MessageEntity

@dynamic uqID;
@dynamic content;
@dynamic messageId;
@dynamic receiveUser;
@dynamic flag_sended;
@dynamic sendDate;
@dynamic flag_readed;
@dynamic sendUser;
@dynamic statue;
@dynamic type;
@dynamic fileId;

@dynamic receiveDate;

-(void)dealloc{
}

-(NSString*)name{
    if([self.sendUser length]>0){
        int index=[self.sendUser rangeOfString:@"@"].location;
        return [self.sendUser substringToIndex:index];
    }
    return @"";
}
-(NSString*)zhName
{
    if([self.name length]>0){
        return [[UserQueue instance].userCache valueForKey:self.name]?[[UserQueue instance].userCache valueForKey:self.name]:self.name;
    }
    return self.name;
}
@end
