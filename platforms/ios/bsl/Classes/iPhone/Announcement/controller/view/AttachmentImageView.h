//
//  AttachmentImageView.h
//  bsl
//
//  Created by zhoujun on 13-11-4.
//
//

#import <UIKit/UIKit.h>

@interface AttachmentImageView : UIImageView{
    NSString *fileName;
    NSString *fileId;
    NSString *fileSize;
    
}
-(AttachmentImageView*)showImageView:(NSString*)fileId;

@end
