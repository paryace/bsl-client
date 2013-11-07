//
//  AnnouncementTableViewController.h
//  Cube-iOS
//
//  Created by chen shaomou on 2/5/13.
//
//

#import <UIKit/UIKit.h>
#import "AnnouncementTableViewCell.h"
@interface AnnouncementTableViewController : UIViewController<OpenAttachmentDelegate>{
    NSTimer* delayLoadTimer;
    UITableView* tableView;
}

@property (nonatomic,strong) NSMutableArray *list;

@property (nonatomic,strong) NSString * recordId;

@end
