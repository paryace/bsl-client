//
//  UserQuery.m
//  pilot
//
//  Created by chen shaomou on 8/24/12.
//  Copyright (c) 2012 chen shaomou. All rights reserved.
//

#import "UserQuery.h"
#import "User.h"

@implementation UserQuery

-(void) loginWithWorkNo:(NSString *)workNo password:(NSString *)password completionBlock:(void (^)(NSString *))completionBlock failedBlock:(void (^)(NSString *))failedBlock{
    
    User *user = [User getByPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"workNo='%@'",workNo]]];
                  
    if(!user){
        
        user = [User insert];
        
        user.workNo = workNo;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:workNo,password,nil] forKeys:[NSArray arrayWithObjects:@"workNo",@"password",nil]];
    
    [self queryDataWithURL:[NSString stringWithFormat:@"%@%@",BASEURL,LOGIN_URL] parameters:parameters completion:^(NSData* responseData) {
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if([responseString isEqualToString:LOGIN_SUCESS]){
            
            //用户逻辑写在这里
            
            user.password = password;
            
            [user save];
            
            [User setCurrentUser:user];            
            
            completionBlock(LOGIN_SUCESS);
        
        }else if([responseString isEqualToString:LOGIN_FAILED]){
        
            failedBlock(LOGIN_FAILED);
            
        }else if([responseString isEqualToString:LOGIN_OA]){
        
            failedBlock(LOGIN_OA);
        
        }else{
        
            failedBlock(responseString);
            
        }
        
        [responseString release];
        
    } failed:^(NSData* responseData) {
        
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        //网络连接失败,尝试本地登陆
        
        if([user verifyPassword:password]){
            
            [User setCurrentUser:user];
        
            completionBlock(LOGIN_SUCESS);
        
        }else{
            
            if([user password]){
            
                failedBlock(LOGIN_FAILED);
            
            }else{
            
                failedBlock(NETWORK_EXCEPTION);
            
            }
        }
        
        [responseString release];
    }];
}

-(void) newLoginWithWorkNo:(NSString *)workNo password:(NSString *)password completionBlock:(void (^)(NSString *))completionBlock failedBlock:(void (^)(NSString *))failedBlock{
    
    User *user = [User getByPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"workNo='%@'",workNo]]];
    
    if(!user){
        
        user = [User insert];
        
        user.workNo = workNo;
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:workNo,password,nil] forKeys:[NSArray arrayWithObjects:@"workNo",@"password",nil]];
    
    [self queryObjectWithURL:[NSString stringWithFormat:@"%@%@",BASEURL,NEWLOGIN_URL] parameters:parameters completion:^(NSObject* responseData) {
        
        if (responseData) {
            User *reUser = (User *)responseData;
            user.result = reUser.result;
            if([[user result] isEqualToString:LOGIN_SUCESS]){
                
                //用户逻辑写在这里
                user.baseCode = reUser.baseCode;
                user.pilotFlag = reUser.pilotFlag;
                user.workNo = workNo;
                user.workNo = workNo;
                user.password = password;
                
                [user save];
                
                
                [User setCurrentUser:user];
                
                completionBlock(LOGIN_SUCESS);
                
            }else if([[user result] isEqualToString:LOGIN_FAILED]){
                
                failedBlock(LOGIN_FAILED);
                
            }else if([[user result] isEqualToString:LOGIN_OA]){
                
                failedBlock(LOGIN_OA);
                
            }else{
                
                failedBlock([user result]);
                
            }
        
        }
        
    } failed:^(NSObject* responseData) {
        //网络连接失败,尝试本地登陆
        
        if([user respondsToSelector:@selector(verifyPassword:)])
        {
            if([user verifyPassword:password]){
                
                [User setCurrentUser:user];
                
                completionBlock(LOGIN_SUCESS);
                
            }else{
                
                if([user password]){
                    
                    failedBlock(LOGIN_FAILED);
                    
                }else{
                    
                    failedBlock(NETWORK_EXCEPTION);
                    
                }
            }
        }
        
        
    }];
}

-(void)updateUser:(User *)user{

    [self updateObjectWithURL:[NSString stringWithFormat:@"%@%@",BASEURL,USER_UPDATE_URL] object:user completion:^(NSData* responseData){
        //
        NSLog(@"update %@",[[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]autorelease]);
    } failed:^(NSData* responseData){
        //
        NSLog(@"update fail %@",[[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]autorelease]);
    }];
}

- (void)queryAllUserscompletionBlock:(void (^)(NSArray *))completionBlock failedBlock:(void (^)(NSString *))failedBlock{
    [self queryArrayWithURL:[NSString stringWithFormat:@"%@%@",BASEURL,USER_QUERYALL_URL] parameters:nil completion:^(NSArray * responseArr) {
        completionBlock(responseArr);
    } failed:^(NSData *responseData) {
        //
    }];
}

@end
