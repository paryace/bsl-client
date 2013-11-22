//
//  UserQueue.h
//  bsl
//
//  Created by zhoujun on 13-11-20.
//
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"
@interface UserQueue : NSObject
@property(nonatomic,strong)NSMutableDictionary *userCache;

+(UserQueue*) instance;
-(void)loadUserInfoAndCache;

@end
