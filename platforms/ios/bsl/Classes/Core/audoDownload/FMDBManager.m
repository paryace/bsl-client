//
//  FMDBManager.m
//  cube-ios
//
//  Created by zhoujun on 13-9-3.
//
//

#import "FMDBManager.h"
#import "NSFileManager+Extra.h"
#import <objc/runtime.h>

@implementation FMDBManager
@synthesize database;

+(FMDBManager*)getInstance
{
    static FMDBManager* instance;
    if(!instance || instance == nil)
    {
        @synchronized(instance)
        {
            instance = [[FMDBManager alloc]init];
        }
    }
    return instance;
}

-(id)init{
    self =[super init];
    if (self) {
        NSString *path = [[NSFileManager applicationDocumentsDirectory]path];
        self.database = [[FMDatabase alloc]initWithPath:[path stringByAppendingPathComponent:@"cube_new.sqlite"]];
        [self.database open];
    }
    return self;
}
-(BOOL)createTable:(NSString*)tableName withObject:(NSObject*)entity
{
    if(!database.open)
    {
        [database open];
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSArray *array = [self getPropertyList:entity.class];
    [sql appendFormat:@"create table %@ (",tableName] ;
    NSInteger i = 0;
    for (NSString *key in array) {
        if (i>0) {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%@ text",key];
        i++;
    }
    [sql appendString:@")"];
    return [database executeUpdate:sql];
}
-(void)insertToTable:(NSObject*)object withTableName:(NSString*)tableName andOtherDB:(FMDatabase*)db
{

        NSMutableString *sql = [[NSMutableString alloc] init];
        NSArray *array = [self getPropertyList:object.class];
        [sql appendFormat:@"insert into %@ (",tableName] ;
        NSInteger i = 0;
        for (NSString *key in array) {
            if (i>0) {
                [sql appendString:@","];
            }
            [sql appendFormat:@"%@",key];
            i++;
        }
        [sql appendString:@") values ("];
        NSMutableArray *arrayValue = [NSMutableArray array];
        i=0;
        for (NSString *key in array) {
            SEL selector = NSSelectorFromString(key);
            

            id value = [object performSelector:selector];
            if (value==nil) {
                value = @"";
            }
            [arrayValue addObject:value];
            if (i>0) {
                [sql appendString:@","];
            }
            [sql appendString:@"?"];
            i++;
        }
        [sql appendString:@")"];

    if (!db) {
        if(!database.open)
        {
            [database open];
        }
        [database executeUpdate:sql withArgumentsInArray:arrayValue];
    }
    else
    {
        [db executeUpdate:sql withArgumentsInArray:arrayValue];
    }
}
-(void)batchInsertToTable:(NSArray*)objs withtableName:(NSString*)tableName
{

    if(!database.open)
    {
        [database open];
    }
    [database beginTransaction];
    for (NSObject *obj in objs) {
        [self insertToTable:obj withTableName:tableName andOtherDB:nil];
    }
    [database commit];
    
}
-(void)deleteObj:(NSObject*)obj withTableName:(NSString*)tableName
{
    
}



- (NSArray *)getPropertyList: (Class)clazz{
    u_int count;
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties); 
    return propertyArray;
}

-(BOOL)recordIsExist:(NSString*)identifier withtableName:(NSString*)tableName withConditios:(NSString*)condition
{
    if(!database.open)
    {
        [database open];
    }
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where userName='%@' and identifier='%@'",tableName,condition,identifier];
    FMResultSet *set = [database executeQuery:sql];
    while([set next])
    {
        int count =[set intForColumnIndex:0];
        if(count > 0)
        {
            return YES;
        }
    }
    return NO;

}
@end
