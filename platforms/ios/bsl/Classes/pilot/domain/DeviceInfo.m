//
//  DeviceInfo.m
//  pilot
//
//  Created by chen shaomou on 8/30/12.
//  Copyright (c) 2012 chen shaomou. All rights reserved.
//

#import "DeviceInfo.h"
#import "sys/utsname.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

extern NSString* CTSettingCopyMyPhoneNumber();

@interface DeviceInfo (private)

- (uint64_t)getFreeDiskspace;
- (uint64_t)getTotalDiskspace;
- (NSString *)getIccidFromPlist;

@end

@implementation DeviceInfo

@synthesize device_ID;
@synthesize deviceId;
@synthesize deviceSpec;
@synthesize deviceType;
@synthesize appVersion;
@synthesize appUpdateTime;
@synthesize osVersion;
@synthesize diskSizeAvailable;
@synthesize diskSize;
@synthesize iccid;
@synthesize deviceSource;
@synthesize simSerialNumber;
@synthesize simPhone;
@synthesize simOperatorMame;
@synthesize workNo;
@synthesize email;
@synthesize userDeptment;
@synthesize userName;
@synthesize userPhone;
@synthesize verifCode;
@synthesize regitflag;
@synthesize subject;

- (void)dealloc{
    [deviceId release];
    [deviceSpec release];
    [deviceType release];
    [appVersion release];
    [appUpdateTime release];
    [osVersion release];
    [diskSizeAvailable release];
    [diskSize release];
    [iccid release];
    [deviceSource release];
    [simSerialNumber release];
    [simPhone release];
    [simOperatorMame release];
    [workNo release];
    [email release];
    [userDeptment release];
    [userName release];
    [userPhone release];
    [verifCode release];
    [regitflag release];
    [subject release];
    [super dealloc];
}

-(NSString *)deviceType{
    return [[UIDevice currentDevice] model];
}

-(NSString *)deviceId{
    return [[UIDevice currentDevice] uniqueIdentifier];
}

- (NSString *)osVersion{
    return [[UIDevice currentDevice] systemVersion];
}

-(NSString *)appVersion{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (NSString *)subject{
    return appType;
}

- (NSString *)simPhone{
    NSString *simPhoneStr = [@"" stringByAppendingFormat:@"%@", CTSettingCopyMyPhoneNumber()];
    if (simPhoneStr == nil) {
        simPhoneStr = @"";
    }
    return simPhoneStr;
}

- (NSString *)deviceSpec{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceSpecStr = [@"" stringByAppendingFormat:@"%@", [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]];
    if (deviceSpecStr == nil) {
        deviceSpecStr = @"";
    }
    return deviceSpecStr;
}

- (NSString *)diskSizeAvailable{
    return [@"" stringByAppendingFormat:@"%lluG", [self getFreeDiskspace]/(1024ll*1024ll*1024ll)];
}

- (NSString *)diskSize{
    return [@"" stringByAppendingFormat:@"%lluG", [self getTotalDiskspace]/(1024ll*1024ll*1024ll)];
}

- (NSString *)simSerialNumber{
    return [self getIccidFromPlist];
}

- (NSString *)iccid{
    return [self getIccidFromPlist];
}

//获取可用容量
-(uint64_t)getFreeDiskspace{
    uint64_t totalFreeSpace = 0.0f;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {  
        
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        
        totalFreeSpace = [freeFileSystemSizeInBytes floatValue];
        NSLog(@" %llu MiB Free memory available.", ((totalFreeSpace/1024ll)/1024ll));
    } else {  
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);  
    }  
    
    return totalFreeSpace;
}

- (NSString *)simOperatorMame{
    CTTelephonyNetworkInfo *info = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier *carrier = info.subscriberCellularProvider;
    
    NSString *simOperatorNameStr = [@"" stringByAppendingFormat:@"%@", [carrier carrierName]];
    if (simOperatorNameStr == nil) {
        simOperatorNameStr = @"";
    }
    return simOperatorNameStr;
}

//获取总容量
-(uint64_t)getTotalDiskspace{
    uint64_t totalSpace = 0.0f;
    NSError *error = nil;  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];  
        totalSpace = [fileSystemSizeInBytes floatValue];
        NSLog(@"totalSpace %llu MiB", ((totalSpace/1024ll)/1024ll));
    } else {  
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %@", [error domain], [error code]);  
    }
    
    return totalSpace;
}

- (NSString *)getIccidFromPlist{
    NSString *commcenter = @"/private/var/wireless/Library/Preferences/com.apple.commcenter.plist";
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:commcenter];
    NSString *iccidStr = [@"" stringByAppendingFormat:@"%@", [dic valueForKey:@"ICCID"]];//work on device
    if (iccidStr == nil) {
        iccidStr = @"";
    }
    return iccidStr;
}

@end
