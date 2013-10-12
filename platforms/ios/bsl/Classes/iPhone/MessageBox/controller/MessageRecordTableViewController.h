//
//  MessageRecordTableViewController.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/1/13.
//
//

#import <UIKit/UIKit.h>

@class CubeWebViewController;

@interface MessageRecordTableViewController : UIViewController{
    UITableView* tableView;
    CubeWebViewController *cubeWebViewController;
    NSTimer* delayLoadTimer;
}

@end
