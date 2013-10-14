//
//  CodeModuleDownDictionary.m
//  cube-ios
//
//  Created by dong on 13-9-15.
//
//

#import "CudeModuleDownDictionary.h"

@implementation CudeModuleDownDictionary

static NSMutableDictionary* moduleDownDictionary;

+(id)shareModuleDownDictionary{
    @synchronized(self) {
        if (nil == moduleDownDictionary) {
            moduleDownDictionary = [[NSMutableDictionary alloc] init];
            
        }
    }
    return moduleDownDictionary;
}

-(void)addCubeModuleIdentity:(NSString*)identity{
    [moduleDownDictionary setValue: [NSNumber numberWithBool:YES] forKey:identity];
}

-(void)removeCubeModuleIdentity:(NSString*)identity{
    [moduleDownDictionary setValue: [NSNumber numberWithBool:NO] forKey:identity];
}
    

@end
