

#import "OTRMessageTableViewCell.h"
#import "OTRConstants.h"
#import "OTRSettingsManager.h"
#import "OTRSafariActionSheet.h"
#import "OTRAppDelegate.h"
#import "Methods.h"
#import "OTRvCard.h"
#import "OTRManagedAccount.h"


#define MESSAGE_DELIVERED_LABEL_HEIGHT       (DeliveredFontSize +7)
#define MESSAGE_SENT_DATE_LABEL_HEIGHT       (SentDateFontSize+7)
#define MESSAGE_SENT_DATE_LABEL_TAG          100
#define MESSAGE_BACKGROUND_IMAGE_VIEW_TAG    101
#define MESSAGE_TEXT_LABEL_TAG               102
#define MESSAGE_DELIVERED_LABEL_TAG          103

@implementation OTRMessageTableViewCell
- (void)layoutSubviews {
    [super layoutSubviews];
    self.dateLabel.frame = CGRectMake(70, 0, 180, 20);
    if (self.buddy.currentStatus == [NSNumber numberWithInt:0]) {
        self.PimageView.layer.borderColor = [UIColor greenColor].CGColor;
    }else{
        self.PimageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}


-(id)initWithMessage:(OTRManagedMessage *)newMessage withDate:(BOOL)newShowDate reuseIdentifier:(NSString*)identifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    if (self) {
        
        
        appDelegate=(OTRAppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext * context = [NSManagedObjectContext MR_context];
        OTRvCard *vvvv = [OTRvCard fetchOrCreateWithJidString:appDelegate.userAccount.username inContext:context];
        if (vvvv.photoData) {
            myImg = [UIImage imageWithData:vvvv.photoData];
        }else
            myImg =[UIImage imageNamed:@"person.png"];
        
        self.buddy=newMessage.buddy;
        self.showDate = newShowDate;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor =[UIColor whiteColor];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 20)];
        self.dateLabel.tag = MESSAGE_SENT_DATE_LABEL_TAG;
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.dateLabel];

        self.PimageView=[[UIImageView alloc]initWithFrame:CGRectZero];
        self.PimageView.layer.masksToBounds = YES;
        self.PimageView.layer.cornerRadius = 30;
        self.PimageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.PimageView.layer.borderWidth = 2.0;
        self.PimageView.image=[UIImage imageNamed:@"person.png"];
        self.PimageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.PimageView];

        
        

        self.bubbleView = [[OTRChatBubbleView alloc] initWithFrame:CGRectZero];
        self.bubbleView.isIncoming = newMessage.isIncomingValue;
        self.bubbleView.pSts=newMessage.isIncomingValue;
        
        TTTAttributedLabel * label = [OTRMessageTableViewCell defaultLabel];
        label.backgroundColor=[UIColor clearColor];
        label.text = newMessage.message;
        label.delegate = self;
        self.bubbleView.messageTextLabel = label;
        self.bubbleView.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.bubbleView];
        
        if (self.bubbleView.isIncoming) {
            self.dateLabel.textAlignment=NSTextAlignmentLeft;
            self.PimageView.frame = CGRectMake(5,5,60,60);
        }else{
            self.dateLabel.textAlignment=NSTextAlignmentRight;
            self.PimageView.frame = CGRectMake(255,5,60,60);
        }
        self.dateLabel.frame = CGRectMake(70, 0, 180, 20);
        [self setupConstraints];
        [self setMessage:newMessage];
            }
    return self;
    
}

-(void)setMessage:(OTRManagedMessage *)newMessage
{
    
    [self willChangeValueForKey:NSStringFromSelector(@selector(message))];
    _message = newMessage;
    [self didChangeValueForKey:NSStringFromSelector(@selector(message))];
    
    self.bubbleView.messageTextLabel.text = self.message.message;
    self.bubbleView.isIncoming = self.message.isIncomingValue;
    self.bubbleView.pSts=self.message.isIncomingValue;
    [self.bubbleView setIsDelivered:self.message.isDeliveredValue animated:NO];
    
    CGFloat messageSentDateLabelHeight = 0;
    
    if (self.showDate) {
        if (self.bubbleView.isIncoming) {
            self.dateLabel.textAlignment=NSTextAlignmentLeft;
            self.PimageView.frame = CGRectMake(5,5,60,60);
            self.PimageView.image=[UIImage imageNamed:@"person.png"];

            NSManagedObjectContext * context = [NSManagedObjectContext MR_context];
            OTRvCard *vvvvP = [OTRvCard fetchOrCreateWithJidString:newMessage.buddy.accountName inContext:context];
            if(vvvvP.photoData == nil){
                 self.PimageView.image = [UIImage imageNamed:@"person.png"];
            }
            else{
                 self.PimageView.image = [UIImage imageWithData:vvvvP.photoData];
            }

            if ([newMessage.buddy.currentStatus intValue]==0) {
                self.PimageView.layer.borderColor = [UIColor greenColor].CGColor;
                
            }else{
                self.PimageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            }
            
    }else{
            self.dateLabel.textAlignment=NSTextAlignmentRight;
            self.PimageView.frame = CGRectMake(255,5,60,60);
            self.PimageView.layer.borderColor = [UIColor greenColor].CGColor;
            self.PimageView.image=myImg;
    }
        self.dateLabel.text =[RoxieMethods  Dateformatting_date: newMessage.date];
        messageSentDateLabelHeight = MESSAGE_SENT_DATE_LABEL_HEIGHT;
    } else {
        self.dateLabel.text = nil;
    }
    
    
    
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

-(void)setupConstraints
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.dateLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
    self.line_image.frame=CGRectMake(10, self.contentView.frame.size.height-1, 300, 1);
   self.dateLabel.frame = CGRectMake(70, 0, 180, 20);
}

-(void)setupConstraints_Commimg
{
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.dateLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:+70.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1.0
                                               constant:+70.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                              attribute:NSLayoutAttributeWidth
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.contentView
                                              attribute:NSLayoutAttributeWidth
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
    
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self removeConstraint:dateHeightConstraint];
    CGFloat dateheight = 0.0;
    if (self.showDate) {
        dateheight = SentDateFontSize+5;
    }
    
    dateHeightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                             multiplier:1.0
                                               constant:dateheight];
    [self addConstraint:dateHeightConstraint];
    
    self.line_image.frame=CGRectMake(10, self.contentView.frame.size.height-1, 300, 1);
    
}

+(CGSize)messageTextLabelSize:(NSString *)message
{
    TTTAttributedLabel * label = [OTRMessageTableViewCell defaultLabel];
    label.text = message;
    return  [label sizeThatFits:CGSizeMake(MESSAGE_TEXT_WIDTH_MAX, CGFLOAT_MAX)];
}


+(TTTAttributedLabel *)defaultLabel
{
    TTTAttributedLabel * messageTextLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    messageTextLabel.tag = MESSAGE_TEXT_LABEL_TAG;
    messageTextLabel.backgroundColor = [UIColor clearColor];
    messageTextLabel.numberOfLines = 0;
    messageTextLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    messageTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        messageTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    } else {
        CGFloat messageTextSize = [OTRSettingsManager floatForOTRSettingKey:kOTRSettingKeyFontSize];
        messageTextLabel.font = [UIFont systemFontOfSize:messageTextSize];
    }
    return messageTextLabel;
}


- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    OTRSafariActionSheet * action = [[OTRSafariActionSheet alloc] initWithUrl:url];
    [action showInView:self.superview.superview];
}

-(void)attributedLabelDidSelectDelete:(TTTAttributedLabel *)label
{
    [self.message MR_deleteEntity];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
}

+ (CGFloat)heightForMesssage:(NSString *)message showDate:(BOOL)showDate
{
    CGFloat dateHeight = 0;
    if (showDate) {
        dateHeight = SentDateFontSize+5;
    }
    TTTAttributedLabel * label = [self defaultLabel];
    label.text = message;
    CGSize labelSize = [label sizeThatFits:CGSizeMake(180, CGFLOAT_MAX)];
    return labelSize.height + 12.0 + dateHeight+40;
}

+ (NSDateFormatter *)defaultDateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, YYYY h:mm a"];
    });
    return dateFormatter;
}



@end
