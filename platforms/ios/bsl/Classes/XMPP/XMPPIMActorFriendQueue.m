//
//  XMPPIMActorFriendQueue.m
//  bsl
//
//  Created by zhoujun on 13-10-25.
//
//

#import "XMPPIMActorFriendQueue.h"
#import "XMPPIMActor.h"

static XMPPIMActorFriendQueue* instance=nil;

@interface XMPPIMActorFriendQueue()
-(void)timeEvent;
@end

@implementation XMPPIMActorFriendQueue


+(XMPPIMActorFriendQueue*)sharedInstance{
    if(instance==nil)
        instance=[[XMPPIMActorFriendQueue alloc] init];
    return instance;
}

-(id)init{
    self=[super init];
    
    if(self){
        items=[[NSMutableArray alloc] initWithCapacity:3];
    }
    
    return self;
}

-(void)dealloc{
    [self clear];
}

-(void)clear{
    [timer invalidate];
    timer=nil;
    
    [items removeAllObjects];
}

-(void)setList:(NSArray*)values{
    [self clear];
    [items addObjectsFromArray:values];
    
    [self timeEvent];
    
    if([items count]>0){
        timer=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
    }
}

-(void)timeEvent{
    if([items count]<1){
        [self clear];
    }
    else{
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
     
        int count=0;
        while([items count]>0){
            @autoreleasepool {
                NSXMLElement *item=(NSXMLElement *)[items objectAtIndex:0];
                NSString *group=[[item elementForName:@"group"] stringValue];
                if (group == nil || [group isEqualToString:@""]) {
                    group = @"好友列表";
                }
                NSString * jidStr = [[item attributeForName:@"jid"] stringValue];
                UserInfo *entity = [xmpp fetchUserFromJid:jidStr];
                if (entity != nil) {
                    entity.userGroup = group;
                    entity.userSubscription = [[item attributeForName:@"subscription"] stringValue];
                    entity.userName = [[item attributeForName:@"name"] stringValue];

                }else{
                    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo"inManagedObjectContext:xmpp.managedObjectContext];
                    [newManagedObject setValue:group forKey:@"userGroup"];
                    [newManagedObject setValue:[[item attributeForName:@"name"] stringValue] forKey:@"userName"];
                    [newManagedObject setValue:[[item attributeForName:@"jid"] stringValue] forKey:@"userJid"];
                    [newManagedObject setValue:[[item attributeForName:@"subscription"] stringValue] forKey:@"userSubscription"];
                    
                }
                [items removeObjectAtIndex:0];
                count++;
                if(count>=50)break;
            }
        }
        
        [xmpp saveContext];
        
        if([items count]<1){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STARTRREFRESHTABLEVIEW" object:nil];

        }
    }
}

@end
