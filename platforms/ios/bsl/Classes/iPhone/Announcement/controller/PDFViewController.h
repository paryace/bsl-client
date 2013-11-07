//
//  PDFViewController.h
//  bsl
//
//  Created by zhoujun on 13-11-6.
//
//

#import <UIKit/UIKit.h>
#import "AttachMents.h"
@interface PDFViewController : UIViewController
{
    UIWebView *webView;
}
@property(nonatomic,strong)AttachMents* attachment;
@end
