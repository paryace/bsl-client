//
//  CodeModuleDownDictionary.h
//  cube-ios
//
//  Created by dong on 13-9-15.
//
//

#import <Foundation/Foundation.h>

@interface CudeModuleDownDictionary : NSObject

+(id)shareModuleDownDictionary;

-(void)addCubeModuleIdentity:(NSString*)identity;

-(void)removeCubeModuleIdentity:(NSString*)identity;

    
@end
