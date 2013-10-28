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
-(void)updateFriendUserInfo;
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
    isStop=YES;
    [timer invalidate];
    timer=nil;
    
    [items removeAllObjects];
}

-(void)setList:(NSArray*)values{
    isStop=NO;
    [items addObjectsFromArray:values];
    [self timeEvent];
    
    if([items count]>0){
        timer=[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_FRIENDSFINISH object:nil];
        [self updateFriendUserInfo];

    }
}

-(void)timeEvent{
    if([items count]<1){
        [timer invalidate];
        timer=nil;
        
        [items removeAllObjects];
        
        [self updateFriendUserInfo];
    }
    else{
        
        XMPPIMActor* xmpp=[ShareAppDelegate xmpp];
     
        
        @autoreleasepool {
            int count=0;
            while([items count]>0){
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
            
            [xmpp saveContext];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_FRIENDSPROCESS object:nil];

        }
        
        if([items count]<1){
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_FRIENDSFINISH object:nil];

        }
    }
}

-(void)updateFriendUserInfo{
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedPersonArray = [delegate.xmpp.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    
    if([fetchedPersonArray count]>0){
        
        NSMutableArray* ids=[[NSMutableArray alloc] initWithCapacity:2];
        for(UserInfo* userInfo in fetchedPersonArray){
            [ids addObject:userInfo.userJid];
        }
        
        NSMutableArray* userSex=[[NSMutableArray alloc] initWithCapacity:2];
        
        fetchedPersonArray=nil;
        
        
        if (!delegate.xmpp.xmppvCardTempModule) {
            [delegate.xmpp newvCard];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //开异步读取好友VCard
            
            
            
            for (NSString* userJid in ids) {
                if(isStop)break;
                XMPPvCardTemp * xmppvCardTemp =[ delegate.xmpp.xmppvCardTempModule fetchvCardTempForJID:[XMPPJID jidWithString:userJid]];
                NSString*sex =  [[[xmppvCardTemp elementForName:@"N"] elementForName:@"MIDDLE"] stringValue];
                if([sex length]>0){
                    [userSex addObject:sex];
                }
                else{
                    [userSex addObject:@""];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(isStop)return;
                
                NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
                [fetchRequest setPredicate:predicate];
                
                NSArray *fetchedPersonArray = [delegate.xmpp.managedObjectContext executeFetchRequest:fetchRequest error:nil];

                for(UserInfo* userInfo in fetchedPersonArray){
                    
                    [ids enumerateObjectsUsingBlock:^(id userJid,NSUInteger index,BOOL*stop){
                        if([userInfo.userJid isEqualToString:userJid]){
                            userInfo.userSex=[userSex objectAtIndex:index];
                            *stop=YES;
                        }
                    }];
                }

                
                if([delegate.xmpp.managedObjectContext hasChanges])
                    [delegate.xmpp.managedObjectContext save:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_UPDATE_FRIENDS object:nil];

            });
        });
    }
    else{
        fetchedPersonArray=nil;
    }
    
}

@end
