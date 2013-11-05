//
//  AttachmentImageView.h
//  bsl
//
//  Created by zhoujun on 13-11-4.
//
//

#import <UIKit/UIKit.h>
#import "CubeWebViewController.h"
@interface AttachmentImageView : UIImageView{
    CubeWebViewController *webView;
}
@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *fileId;
@property(nonatomic,strong)NSString *fileSize;

-(void)openFile:(NSString*)fileId;
@end
