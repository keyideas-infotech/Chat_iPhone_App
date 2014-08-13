

#import <UIKit/UIKit.h>
#import "OTRBuddyListViewController.h"
#import "OTRProtocolManager.h"
#import "OTRManagedBuddy.h"
#import "OTRChatInputBar.h"
#import "OTRTitleSubtitleView.h"
#import "EmoticaView.h"
#import "dbClassRef.h"
#import "GAITrackedViewController.h"

@class OTRAppDelegate;
@interface OTRChatViewController : GAITrackedViewController <UIActionSheetDelegate, UISplitViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,OTRChatInputBarDelegate,HPGrowingTextViewDelegate,emoticonClickedDelegate  ,UIImagePickerControllerDelegate,UINavigationBarDelegate,UINavigationControllerDelegate,>
{
    NSMutableArray * showDateForRowArray;
    NSDate *_previousShownSentDate;
    UIImage *_messageBubbleComposing;
    CGFloat _previousTextViewContentHeight;
    OTRChatInputBar * chatInputBar;
    OTRTitleSubtitleView * titleView;
    NSUInteger lastRange;
    NSArray *matches;
    UITapGestureRecognizer *tapGes2;
    UIBarButtonItem *addBarButton;
    UIImagePickerController *Imagepicker;
    UIImage *imagetoupload;
    UIButton  *btn ;
    NSString *titlStr;
    NSInteger cameraViewSts;
    UIView *backView;
    UIImageView *imgLogo;
    UIView *v;
    OTRAppDelegate *appdelegate;
    NSTimer *calTimer;
    int calVal;
    OTRChatInputBar *InputBarlocVar;
    UIEdgeInsets StartingRefresh;
    EmoticonView *emoViewNew;
    
}

@property (nonatomic, retain) UIBarButtonItem *lockButton, *unlockedButton, *lockVerifiedButton;
@property (nonatomic, retain) UILabel *instructionsLabel;
@property (nonatomic, strong) UITableView * chatHistoryTableView;
@property (nonatomic, strong) NSFetchedResultsController *messagesFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *buddyFetchedResultsController;
@property (nonatomic, retain) OTRManagedBuddy *buddy;
@property (nonatomic, retain) OTRBuddyListViewController *buddyListController;
@property (nonatomic, retain) NSURL *lastActionLink;
@property (nonatomic) BOOL isComposingVisible;
@property (nonatomic, retain) UISwipeGestureRecognizer * swipeGestureRecognizer;
- (void)setupLockButton;
- (void)refreshLockButton;
- (void)lockButtonPressed;
@property (nonatomic, retain) OTRAppDelegate *appdelegate;
@property (readwrite) NSInteger grpChatSts;


@end
