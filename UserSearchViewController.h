//
//
//  Created by Keyideas Mac mini on 04/06/14.
//

#import <UIKit/UIKit.h>
#import "OTRAppDelegate.h"
#import "MBProgressHUD.h"
#import "SearchUser.h"
#import "GAITrackedViewController.h"

@interface UserSearchViewController : GAITrackedViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,MBProgressHUDDelegate,SearchUserDelegate>{
    IBOutlet UISearchBar *searchBar;
    UITableView *searchTable;
    NSMutableArray *searchArray,*mainArray;
    SearchUser *sObj;
    OTRAppDelegate *appdelegate;
    MBProgressHUD *HUD;
    UIView *padding;
    UIButton *btnBack;
    int calT;
    UIBarButtonItem *rightBarButton;
    NSIndexPath * ClickIndexPath;
}
@property (nonatomic, strong) NSTimer * timeoutTimer;
@property (nonatomic, strong) UITableView *searchTable;
@end
