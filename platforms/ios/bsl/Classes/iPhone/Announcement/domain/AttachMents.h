//
//  AttachMents.h
//  bsl
//
//  Created by zhoujun on 13-11-5.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Repository.h"

@interface AttachMents : NSManagedObject

@property (nonatomic, strong) NSString * announceId;
@property (nonatomic, strong) NSString * fileId;
@property (nonatomic, strong) NSString * fileName;
@property (nonatomic, strong) NSNumber * fileSize;
@property (nonatomic, strong) NSString * filePath;

-(void)downloadFile:(NSString*)attachId;

@end
