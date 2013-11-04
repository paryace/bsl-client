//
//  AttachmentImageView.m
//  bsl
//
//  Created by zhoujun on 13-11-4.
//
//

#import "AttachmentImageView.h"

@implementation AttachmentImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
-(AttachmentImageView*)showImageView:(NSString*)filesId
{
    if(!fileId || filesId.length==0)
    {
        return nil;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
