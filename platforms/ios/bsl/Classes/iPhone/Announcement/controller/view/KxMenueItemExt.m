//
//  KxMenueItemExt.m
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import "KxMenueItemExt.h"

@implementation KxMenueItemExt
@synthesize fileId;
@synthesize fileName;
@synthesize fileSize;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action
                 attachName:name
                   attachId:ids
                 attachSize:size
{
    return [[KxMenueItemExt alloc] init:title
                                     image:image
                                    target:target
                                    action:action
                             attachName:name attachId:ids attachSize:size];

}

- (id) init:(NSString *) title
      image:(UIImage *) image
     target:(id)target
     action:(SEL) action
 attachName:name
   attachId:ids
 attachSize:size
{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        
        self.title = title;
        self.image = image;
        self.target = target;
        self.action = action;
        fileName = name;
        fileSize = size;
        fileId = ids;
    }
    return self;
}


@end
