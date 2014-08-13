

#import <UIKit/UIKit.h>
#import "OTRManagedMessage.h"
#import "TTTAttributedLabel.h"
#import "OTRChatBubbleView.h"
#import "OTRAppDelegate.h"


@interface OTRMessageTableViewCell : UITableViewCell <TTTAttributedLabelDelegate>
{
    NSLayoutConstraint * dateHeightConstraint;
    OTRAppDelegate *appDelegate;
    UIImage *myImg;
}
@property (nonatomic, strong) OTRManagedMessage * message;
@property (nonatomic, strong) UILabel * dateLabel;
@property (nonatomic) BOOL showDate;
@property(nonatomic,strong)UIImageView *line_image;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic,weak) OTRManagedBuddy * buddy;
@property (nonatomic, strong) OTRChatBubbleView * bubbleView;
@property (nonatomic,strong)UIImageView *PimageView;
-(id)initWithMessage:(OTRManagedMessage *)message withDate:(BOOL)showDate reuseIdentifier:(NSString*)identifier;
+ (CGSize)messageTextLabelSize:(NSString *)message;
+ (CGFloat)heightForMesssage:(NSString *)message showDate:(BOOL)showDate;
@end
