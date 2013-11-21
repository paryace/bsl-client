//
//  UserQueue.m
//  bsl
//
//  Created by zhoujun on 13-11-20.
//
//

#import "UserQueue.h"
static UserQueue* queue;
@implementation UserQueue
@synthesize userCache;
+(UserQueue*) instance
{
    if(!queue)
    {
        queue = [[UserQueue alloc]init];
        [queue loadUserInfoAndCache];
    }
    return queue;
}

-(NSMutableDictionary*)userCache
{
    if(!userCache)
    {
        userCache = [[NSMutableDictionary alloc]init];
    }
    return userCache;
}

-(void)loadUserInfoAndCache
{
    userCache = [[NSMutableDictionary alloc]init];
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"UserInfo"];
        [fetchRequest setPredicate:predicate];
        
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:[ShareAppDelegate xmpp].managedObjectContext];
        NSDictionary *properties = [entity propertiesByName];
        fetchRequest.entity=entity;
        fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:[properties objectForKey:@"userJid"],[properties objectForKey:@"userName"],nil];
        fetchRequest.returnsDistinctResults=YES;
        fetchRequest.resultType = NSDictionaryResultType;
        //排序
        NSArray* groups = [[ShareAppDelegate xmpp].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        
        for(NSDictionary * dict in groups){
            //            NSString* group=NSLocalizedString(userInfo.userGroup,nil);
            NSString* userJid=[dict objectForKey:@"userJid"];
            if([userJid length]>0){
                int index=[userJid rangeOfString:@"@"].location;
                userJid =  [userJid substringToIndex:index];
            }
            NSString* userName =  [dict objectForKey:@"userName"];
            [userCache setObject:userName forKey:userJid];
        }
    });
    
}

@end
