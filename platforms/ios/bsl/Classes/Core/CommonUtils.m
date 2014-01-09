//
//  CommonUtils.m
//  bsl
//
//  Created by zhoujun on 13-11-29.
//
//

#import "CommonUtils.h"
@implementation CommonUtils
+(BOOL)isOffLineLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"isOffLogin"];
}
+(NSString *)currentUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return  [defaults valueForKey:@"username"];
}

+(NSString *)documentsPath
{
	NSArray *documentsPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [documentsPaths objectAtIndex:0]; // Path to the application's "~/Documents" directory
}

+(void)scanFileAndDeleteAtPath:(int)days
{
    NSString *path = [[self documentsPath] stringByAppendingPathComponent:@"attachmens"];
    NSArray *fileArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    NSFileManager *manager = [NSFileManager defaultManager];
    for(NSString *file in fileArray)
    {
        NSString *realPath = [path stringByAppendingPathComponent:file];
        NSDate *createdate = [[manager enumeratorAtPath:realPath]fileAttributes].fileModificationDate;
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitFlag = NSDayCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlag fromDate:createdate toDate:currentDate options:0];
        int newdays = [components day] + 1;
        if(newdays>=days)
        {
            NSError *error;
            [manager removeItemAtPath:realPath error:&error];
            if(error)
            {
                NSLog(@"%@",[error userInfo]);
            }
        }
        
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
//        NSInteger interval = [zone secondsFromGMTForDate: date];
//        NSDate *localDate = [date  dateByAddingTimeInterval: interval];
        
    }
    
}
@end
