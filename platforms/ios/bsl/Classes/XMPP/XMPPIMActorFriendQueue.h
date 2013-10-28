//
//  XMPPIMActorFriendQueue.h
//  bsl
//
//  Created by zhoujun on 13-10-25.
//
//

#import <Foundation/Foundation.h>

@interface XMPPIMActorFriendQueue : NSObject{
    NSMutableArray*  items;
    
    NSTimer* timer;
    
    BOOL isStop;
}

+(XMPPIMActorFriendQueue*)sharedInstance;

-(void)clear;

-(void)setList:(NSArray*)values;

@end
