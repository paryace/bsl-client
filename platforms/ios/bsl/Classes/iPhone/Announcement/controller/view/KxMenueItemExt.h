//
//  KxMenueItemExt.h
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import "KxMenu.h"

@interface KxMenueItemExt : KxMenuItem
@property(readwrite, nonatomic, strong)NSString *fileName;
@property(readwrite, nonatomic, strong)NSString *fileId;
@property(readwrite, nonatomic, strong)NSString *fileSize;
+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action
               attachName:name
                 attachId:ids
               attachSize:size;
@end
