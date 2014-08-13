

#import "OTRChatViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Strings.h"
#import "OTRDoubleSetting.h"
#import "OTRConstants.h"
#import "OTRAppDelegate.h"
#import "OTRMessageTableViewCell.h"
#import "DAKeyboardControl.h"
#import "OTRManagedStatus.h"
#import "OTRManagedEncryptionStatusMessage.h"
#import "OTRStatusMessageCell.h"
#import "OTRUtilities.h"
#import "UIAlertView+Blocks.h"


@interface OTRChatViewController(Private)

- (void) refreshView;



@end

@implementation OTRChatViewController
@synthesize buddyListController;
@synthesize lockButton, unlockedButton,lockVerifiedButton;
@synthesize lastActionLink;
@synthesize buddy;
@synthesize instructionsLabel;
@synthesize chatHistoryTableView;
@synthesize swipeGestureRecognizer;
@synthesize isComposingVisible;
@synthesize grpChatSts;
@synthesize appdelegate;
//Table refresh
//@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;



- (void) dealloc {
    self.lastActionLink = nil;
    self.buddyListController = nil;
    self.buddy = nil;
    self.chatHistoryTableView = nil;
    self.lockButton = nil;
    self.unlockedButton = nil;
    self.instructionsLabel = nil;
    self.chatHistoryTableView = nil;
    _messagesFetchedResultsController = nil;
    _buddyFetchedResultsController = nil;
    
}

- (id)init {
    if (self = [super init]) {
        //set notification for when keyboard shows/hides
        NSLog(@"CHAT_STRING %@",CHAT_STRING);
        
        self.title =[Methods remove_substring:CHAT_STRING :@"@abc.com"];
        titleView = [[OTRTitleSubtitleView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.navigationItem.titleView = titleView;

        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"back.png"]];
        [btn addTarget:self action:@selector(go_Back:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(18.0f, 0.0f, 52.0f, 30.0f);
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem  = addButton;
        if (grpChatSts==1) {
            addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddUser:)];
            self.navigationItem.rightBarButtonItem = addBarButton;
        }

    }
    return self;
}

- (CGFloat) chatBoxViewHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 50.0;
    } else {
        return 44.0;
    }
}

-(void)setupLockButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImage = [UIImage imageNamed:@"Lock_Locked.png"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    CGRect buttonFrame = [button frame];
    buttonFrame.size.width = buttonImage.size.width;
    buttonFrame.size.height = buttonImage.size.height;
    [button setFrame:buttonFrame];
    [button addTarget:self action:@selector(lockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.lockButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonImage = [UIImage imageNamed:@"Lock_Unlocked.png"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    buttonFrame = [button frame];
    buttonFrame.size.width = buttonImage.size.width;
    buttonFrame.size.height = buttonImage.size.height;
    [button setFrame:buttonFrame];
    [button addTarget:self action:@selector(lockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.unlockedButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonImage = [UIImage imageNamed:@"Lock_Locked_Verified.png"];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    buttonFrame = [button frame];
    buttonFrame.size.width = buttonImage.size.width;
    buttonFrame.size.height = buttonImage.size.height;
    [button setFrame:buttonFrame];
    [button addTarget:self action:@selector(lockButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.lockVerifiedButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
//    [self refreshLockButton];
}

-(void)refreshLockButton
{
    [OTRCodec isGeneratingKeyForBuddy:self.buddy completion:^(BOOL isGeneratingKey) {
        if (isGeneratingKey) {
            [self addLockSpinner];
        }
    }];
    UIBarButtonItem * rightBarItem = self.navigationItem.rightBarButtonItem;
    if ([rightBarItem isEqual:lockButton] || [rightBarItem isEqual:lockVerifiedButton] || [rightBarItem isEqual:unlockedButton] || !rightBarItem) {
        BOOL trusted = [[OTRKit sharedInstance] fingerprintIsVerifiedForUsername:buddy.accountName accountName:buddy.account.username protocol:buddy.account.protocol];
        
        OTRKitMessageState currentEncryptionStatus = [self.buddy currentEncryptionStatus];
        
        if(currentEncryptionStatus == kOTRKitMessageStateEncrypted && trusted)
        {
            self.navigationItem.rightBarButtonItem = self.lockVerifiedButton;
        }
        else if(currentEncryptionStatus == kOTRKitMessageStateEncrypted)
        {
            self.navigationItem.rightBarButtonItem = self.lockButton;
        }
        else
        {
            self.navigationItem.rightBarButtonItem = self.unlockedButton;
        }
        self.navigationItem.rightBarButtonItem.accessibilityLabel = @"lock";
    }
    
}

-(void)lockButtonPressed
{
    NSString *encryptionString = INITIATE_ENCRYPTED_CHAT_STRING;
    NSString * verifiedString = VERIFY_STRING;
    
    if ([self.buddy currentEncryptionStatus] == kOTRKitMessageStateEncrypted) {
        encryptionString = CANCEL_ENCRYPTED_CHAT_STRING;
    }
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CANCEL_STRING destructiveButtonTitle:nil otherButtonTitles:encryptionString, verifiedString, CLEAR_CHAT_HISTORY_STRING, nil];
    popupQuery.accessibilityLabel = @"secure";
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    popupQuery.tag = ACTIONSHEET_ENCRYPTION_OPTIONS_TAG;
    [OTR_APP_DELEGATE presentActionSheet:popupQuery inView:self.view];
}

#pragma mark - View lifecycle
-(void)go_Back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cameraViewSts=0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    showDateForRowArray = [NSMutableArray array];
    _messageBubbleComposing = [UIImage imageNamed:@"MessageBubble2"];
    
    self.chatHistoryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    
    UIEdgeInsets insets = self.chatHistoryTableView.contentInset;
    insets.bottom = kChatBarHeight1;

    self.chatHistoryTableView.contentInset = self.chatHistoryTableView.scrollIndicatorInsets = insets;
    self.chatHistoryTableView.dataSource = self;
    self.chatHistoryTableView.delegate = self;
    self.chatHistoryTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.chatHistoryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatHistoryTableView.separatorInset = UIEdgeInsetsZero;
    self.chatHistoryTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.chatHistoryTableView];
    [self.chatHistoryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    _previousTextViewContentHeight = MessageFontSize+20;
    CGRect barRect = CGRectMake(0, self.view.frame.size.height-kChatBarHeight1, self.view.frame.size.width, kChatBarHeight1);
    chatInputBar = [[OTRChatInputBar alloc] initWithFrame:barRect withDelegate:self];
    [self.view addSubview:chatInputBar];
    
    self.view.keyboardTriggerOffset = chatInputBar.frame.size.height;
    chatInputBar.textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeYes;
    
    
    emoViewNew = [[RoxiEmoticonView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-kChatBarHeight1-kChatBarHeight1, 320, 40) withDelegate:self];
    emoViewNew.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:emoViewNew];
    [dbSingleton() createEditableCopyOfDatabaseIfNeeded];
    NSDictionary *tempDic= [dbSingleton() select_AllEmoticon_Key];
    NSSet *settt = [NSSet setWithArray:[tempDic objectForKey:@"data"]];
    matches = [settt allObjects];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    if (IS_IPHONE_5)
    {
        backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 568)];
        imgLogo=[[UIImageView alloc]initWithFrame:CGRectMake(47, 67, 226, 129)];
    }else{
        backView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 290, 480)];
        imgLogo=[[UIImageView alloc]initWithFrame:CGRectMake(47, 67, 226, 129)];
    }
    imgLogo.image=[UIImage imageNamed:@"roxieTableBack.png"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    backView.backgroundColor=[UIColor whiteColor];
    [backView addSubview:imgLogo];
    [self.chatHistoryTableView setBackgroundView:backView];
    backView.hidden = YES;
    
    [self addFooter];
}

- (void) addFooter
{
    v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    v.backgroundColor = [UIColor whiteColor];
    [self.chatHistoryTableView setTableFooterView:v];
}


-(void)changeFotterSize:(NSInteger )noCount{
       if ( noCount>4){
        v.frame=CGRectMake(0, 0, 320, 25);
    } else if (self.buddy.currentStatus!=[NSNumber numberWithInt:0] && noCount>=2) {
        v.frame=CGRectMake(0, 0, 320, 200);
    }else{
        v.frame=CGRectMake(0, 0, 320, 250);
    }
    
}



-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    backView.hidden = YES;
}


- (void) showDisconnectionAlert:(NSNotification*)notification {
    NSMutableString *message = [NSMutableString stringWithFormat:DISCONNECTED_MESSAGE_STRING, buddy.account.username];
    if ([OTRSettingsManager boolForOTRSettingKey:kOTRSettingKeyDeleteOnDisconnect]) {
        [message appendFormat:@" %@", DISCONNECTION_WARNING_STRING];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:DISCONNECTED_TITLE_STRING message:message delegate:nil cancelButtonTitle:OK_STRING otherButtonTitles: nil];
    [alert show];
}

- (void) setBuddy:(OTRManagedBuddy *)newBuddy {
   
    [self saveCurrentMessageText];
    buddy = newBuddy;
    
    [self refreshView];
    if (buddy) {
        if ([newBuddy.displayName length]) {
         
            titleView.titleLabel.text =[RoxieMethods remove_substring:newBuddy.displayName :@"@abc.com"];
            titlStr=titleView.titleLabel.text;
       
        }
        else {
    
            titleView.titleLabel.text = [RoxieMethods remove_substring:newBuddy.accountName :@"@abc.com"];
            titlStr=titleView.titleLabel.text;
        }
        [self updateChatState:NO];
    }
    
    
}

-(NSIndexPath *)lastIndexPath
{
    return [NSIndexPath indexPathForRow:([self.chatHistoryTableView numberOfRowsInSection:0] - 1) inSection:0];
}


-(void)removeComposing
{
    self.isComposingVisible = NO;
    [self.chatHistoryTableView beginUpdates];
    [self.chatHistoryTableView deleteRowsAtIndexPaths:@[[self lastIndexPath]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.chatHistoryTableView endUpdates];
    [self scrollToBottomAnimated:YES];
    
}
-(void)addComposing
{
    self.isComposingVisible = YES;
    NSIndexPath * lastIndexPath = [self lastIndexPath];
    NSInteger newLast = [lastIndexPath indexAtPosition:lastIndexPath.length-1]+1;
    lastIndexPath = [[lastIndexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:newLast];
    [self.chatHistoryTableView beginUpdates];
    [self.chatHistoryTableView insertRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.chatHistoryTableView endUpdates];
    [self scrollToBottomAnimated:YES];
}

- (void)updateChatState:(BOOL)animated
{
    switch (self.buddy.chatStateValue) {
        case kOTRChatStateComposing:
            {
                if (!self.isComposingVisible) {
                    [self addComposing];
                }
            }
        break;
        case kOTRChatStatePaused:
            {
                if (!self.isComposingVisible) {
                [self addComposing];
                }
            }
            break;
        case kOTRChatStateActive:
            if (self.isComposingVisible) {
                [self removeComposing];
            }
            break;
        default:
            if (self.isComposingVisible) {
                [self removeComposing];
            }
            break;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
}



- (void) refreshView {
  
    
     if (cameraViewSts==0) {
    _messagesFetchedResultsController = nil;
    _buddyFetchedResultsController = nil;
    if (!self.buddy) {
        if (!instructionsLabel) {
            int labelWidth = 500;
            int labelHeight = 100;
            self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-labelWidth/2, self.view.frame.size.height/2-labelHeight/2, labelWidth, labelHeight)];
            instructionsLabel.text = CHAT_INSTRUCTIONS_LABEL_STRING;
            instructionsLabel.numberOfLines = 2;
            instructionsLabel.backgroundColor = self.chatHistoryTableView.backgroundColor;
            [self.view addSubview:instructionsLabel];
            self.navigationItem.rightBarButtonItem = nil;
        }
    } else {
        if (self.instructionsLabel) {
            [self.instructionsLabel removeFromSuperview];
            self.instructionsLabel = nil;
        }
        [self buddyFetchedResultsController];
        [self messagesFetchedResultsController];
        showDateForRowArray = [NSMutableArray array];
        _previousShownSentDate = nil;
        [self.buddy allMessagesRead];
        
        [self.chatHistoryTableView reloadData];
               
        
        
        if(![self.buddy.composingMessageString length])
        {
            [self.buddy sendActiveChatState];
            chatInputBar.textView.text = nil;
        } else{
            chatInputBar.textView.text = self.buddy.composingMessageString;
            
        }
        [self scrollToBottomAnimated:NO];
    }
    
}
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.buddy allMessagesRead];
    [super viewWillDisappear:animated];
    chatInputBar.textView.text = @"";
    [chatInputBar.textView resignFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view removeKeyboardControl];
    [self setBuddy:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//Google analytics
    self.screenName = @"Chat Screen";
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:((float) 183.0 / 255.0f)green:((float) 27.0 / 255.0f)blue:((float) 57.0 / 255.0f)alpha:1.0f]];
    
    appdelegate= (OTRAppDelegate *)[[UIApplication sharedApplication]delegate];
    appdelegate.pageNo=0;
    
    
   if (cameraViewSts==0) {
       __weak OTRChatViewController * chatViewController = self;
       __weak OTRChatInputBar * weakChatInputbar = chatInputBar;
       __weak RoxiEmoticonView *weakEmoView = emoViewNew;
       [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
           CGRect messageInputBarFrame = weakChatInputbar.frame;
           messageInputBarFrame.origin.y = keyboardFrameInView.origin.y - messageInputBarFrame.size.height;
           weakChatInputbar.frame = messageInputBarFrame;
           
           UIEdgeInsets tableViewContentInset = chatViewController.chatHistoryTableView.contentInset;
           tableViewContentInset.bottom = chatViewController.view.frame.size.height-weakChatInputbar.frame.origin.y;
           chatViewController.chatHistoryTableView.contentInset = chatViewController.chatHistoryTableView.scrollIndicatorInsets = tableViewContentInset;
           [chatViewController scrollToBottomAnimated:NO];
           CGRect emoviewFrame = weakEmoView.frame;
           emoviewFrame.origin.y = messageInputBarFrame.origin.y - emoviewFrame.size.height;
           weakEmoView.frame = emoviewFrame;
           
       }];
  
 
    [self refreshView];
    [self updateChatState:NO];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    [chatInputBar.textView becomeFirstResponder];
    
   if (self.view.keyboardFrameInView.size.height == 0 && chatInputBar.frame.origin.y < self.view.frame.size.height - chatInputBar.frame.size.height) {
        [chatInputBar.textView becomeFirstResponder];
    }
    
    if (chatInputBar.frame.origin.y > self.view.frame.size.height - chatInputBar.frame.size.height) {
        CGRect newFrame = chatInputBar.frame;
        newFrame.origin.y = self.view.frame.size.height - chatInputBar.frame.size.height;
        chatInputBar.frame = newFrame;
        
    }
    [chatInputBar.textView resignFirstResponder];
    [chatInputBar.textView becomeFirstResponder];
}

}

-(void)saveCurrentMessageText
{
    self.buddy.composingMessageString = chatInputBar.textView.text;
    if(![self.buddy.composingMessageString length])
    {
        [self.buddy sendInactiveChatState];
    }
    chatInputBar.textView.text = nil;
}


- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = [self.chatHistoryTableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.chatHistoryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (BOOL)showDateForMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [showDateForRowArray count]) {
        return [showDateForRowArray[indexPath.row] boolValue];
    }
    else if (indexPath.row - [showDateForRowArray count] > 0)
    {
        [self showDateForMessageAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row-1 inSection:indexPath.section]];
    }
    
    __block BOOL showDate = NO;
    if (indexPath.row < [[self.messagesFetchedResultsController sections][indexPath.section] numberOfObjects]) {
        id messageOrStatus = [self.messagesFetchedResultsController objectAtIndexPath:indexPath];
        if([messageOrStatus isKindOfClass:[OTRManagedMessage class]]) {
         
            OTRManagedMessage * currentMessage = (OTRManagedMessage *)messageOrStatus;
            
            if (!_previousShownSentDate || [currentMessage.date timeIntervalSinceDate:_previousShownSentDate] > MESSAGE_SENT_DATE_SHOW_TIME_INTERVAL) {
                _previousShownSentDate =currentMessage.date;
                showDate = YES;
            }
        }
    }
    
    [showDateForRowArray addObject:[NSNumber numberWithBool:showDate]];
    
    return showDate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    if (indexPath.row < [[self.messagesFetchedResultsController sections][indexPath.section] numberOfObjects])
    {
        BOOL showDate = YES;
        id messageOrStatus = [self.messagesFetchedResultsController objectAtIndexPath:indexPath];
        if([messageOrStatus isKindOfClass:[OTRManagedMessage class]]) {

            OTRManagedMessage * message = (OTRManagedMessage *)messageOrStatus;
            height = [OTRMessageTableViewCell heightForMesssage:message.message showDate:showDate]-20;
        }
        else {
            height = 0;
        }
    } else
    {
        CGSize messageTextLabelSize =[OTRMessageTableViewCell messageTextLabelSize:@"T"];
        height = messageTextLabelSize.height+MESSAGE_MARGIN_TOP+MESSAGE_MARGIN_BOTTOM;
       
    }
    return height;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numMessages = [[self.messagesFetchedResultsController sections][section] numberOfObjects];
  
    [self changeFotterSize:numMessages];
    if (self.isComposingVisible) {
        numMessages +=1;
    }
    return numMessages;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger lastIndex = ([[self.messagesFetchedResultsController sections][indexPath.section] numberOfObjects]-1);
    BOOL isLastRow = indexPath.row > lastIndex;
    BOOL isComposing = buddy.chatStateValue == kOTRChatStateComposing;
    BOOL isPaused = buddy.chatStateValue == kOTRChatStatePaused;
    BOOL isComposingRow = ((isComposing || isPaused) && isLastRow);
    if (isComposingRow){
        
        
        UITableViewCell * cell;
        static NSString *ComposingCellIdentifier = @"composingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:ComposingCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ComposingCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *messageBackgroundImageView;
            messageBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
            messageBackgroundImageView.tag = MESSAGE_BACKGROUND_IMAGE_VIEW_TAG;
            [cell.contentView addSubview:messageBackgroundImageView];
            messageBackgroundImageView.frame = CGRectMake(0, 0, _messageBubbleComposing.size.width, _messageBubbleComposing.size.height);
            messageBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            messageBackgroundImageView.image = _messageBubbleComposing;
            cell.backgroundColor = [UIColor whiteColor];
        }
        return cell;
    } else
        if( [[self.messagesFetchedResultsController sections][indexPath.section] numberOfObjects] > indexPath.row) {
        
        id messageOrStatus = [self.messagesFetchedResultsController objectAtIndexPath:indexPath];
            BOOL showDate = YES;
        
        if ([messageOrStatus isKindOfClass:[OTRManagedMessage class]]) {
            OTRManagedMessage * message = (OTRManagedMessage *)messageOrStatus;
            static NSString *messageCellIdentifier = @"messageCell";
            OTRMessageTableViewCell * cell;
            cell = [tableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
            
            if (message.isIncomingValue) {
                cell.dateLabel.textAlignment = NSTextAlignmentLeft;//Roxie
            }else{
                cell.dateLabel.textAlignment = NSTextAlignmentRight;//Roxie
            }
            
            if (!cell) {

                cell = [[OTRMessageTableViewCell alloc] initWithMessage:message withDate:showDate reuseIdentifier:messageCellIdentifier];
            } else {
                cell.showDate = YES;
                cell.message = message;
            }
            
            return cell;
        }
        else if ([messageOrStatus isKindOfClass:[OTRManagedStatus class]] || [messageOrStatus isKindOfClass:[OTRManagedEncryptionStatusMessage class]])
        {
            static NSString *statusCellIdentifier = @"statusCell";
            UITableViewCell * cell;
            cell = [tableView dequeueReusableCellWithIdentifier:statusCellIdentifier];
            if (!cell) {
                cell = [[OTRStatusMessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:statusCellIdentifier];
            }
            
            
            NSString * cellText = nil;
            OTRManagedMessageAndStatus * managedStatus = (OTRManagedMessageAndStatus *)messageOrStatus;
            
            if ([messageOrStatus isKindOfClass:[OTRManagedStatus class]]) {
                if (managedStatus.isIncomingValue) {
                    cellText = @"Incomming";                }
                else{
                    cellText =@"Outgoing";                }
            }
            else
            {
                cellText = managedStatus.message;
            }
       
            cell.userInteractionEnabled = NO;
            return cell;
        }
    }
    
}

#pragma mark - NSFetchedResultsControllerDelegate

-(NSFetchedResultsController *)buddyFetchedResultsController{
    if (_buddyFetchedResultsController)
        return _buddyFetchedResultsController;
    
    NSPredicate * buddyFilter = [NSPredicate predicateWithFormat:@"self == %@",self.buddy];
   
      _buddyFetchedResultsController = [OTRManagedBuddy MR_fetchAllGroupedBy:nil withPredicate:buddyFilter sortedBy:nil ascending:YES delegate:self];
    
    return _buddyFetchedResultsController;
}

- (NSFetchedResultsController *)messagesFetchedResultsController {
    if (_messagesFetchedResultsController)
    {
        return _messagesFetchedResultsController;
    }
    
    NSPredicate * buddyFilter = [NSPredicate predicateWithFormat:@"self.buddy == %@",self.buddy];
    NSPredicate * encryptionFilter = [ NSPredicate predicateWithFormat:@"isEncrypted == NO"];
    NSPredicate * messagePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[buddyFilter,encryptionFilter]];

    _messagesFetchedResultsController = [OTRManagedMessageAndStatus MR_fetchAllGroupedBy:nil withPredicate:messagePredicate sortedBy:@"date" ascending:YES delegate:self];

    return _messagesFetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self updateChatState:YES];
    if ([controller isEqual:self.messagesFetchedResultsController])
    {
        [self.chatHistoryTableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = nil;
    
    if ([controller isEqual:_messagesFetchedResultsController])
    {
        tableView = self.chatHistoryTableView;
        
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
            {
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
                
                
                id possibleMessage = [controller objectAtIndexPath:newIndexPath];
                if ([possibleMessage isKindOfClass:[OTRManagedMessage class]]) {
                    ((OTRManagedMessage *)possibleMessage).isReadValue = YES;
                }
                
            }
                break;
            case NSFetchedResultsChangeUpdate:
            {
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
                break;
            case NSFetchedResultsChangeDelete:
            {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([controller isEqual:self.messagesFetchedResultsController])
    {
        [self.chatHistoryTableView endUpdates];
        [self scrollToBottomAnimated:YES];
    }
}
#pragma mark emoticonClickedDelegate

-(void)refreshTextview:(NSString *)emoticonStr{

    if ([chatInputBar.textView isFirstResponder]) {
       [chatInputBar.textView resignFirstResponder];
        [chatInputBar.textView becomeFirstResponder];
    }
    
    if (chatInputBar.textView.internalTextView.selectedRange.location == [chatInputBar.textView.text length]) {
        if([chatInputBar.textView.text hasSuffix:@" "]){
         [chatInputBar.textView.internalTextView.textStorage replaceCharactersInRange:chatInputBar.textView.internalTextView.selectedRange withString:[NSString stringWithFormat:@"%@ ",emoticonStr]];
        }
        else{
            [chatInputBar.textView.internalTextView.textStorage replaceCharactersInRange:chatInputBar.textView.internalTextView.selectedRange withString:[NSString stringWithFormat:@" %@ ",emoticonStr]];
        }
    }
    
    else{
        [chatInputBar.textView.internalTextView.textStorage replaceCharactersInRange:chatInputBar.textView.internalTextView.selectedRange withString:[NSString stringWithFormat:@"%@",emoticonStr]];
    }
    chatInputBar.textView.internalTextView.selectedRange = NSMakeRange([chatInputBar.textView.text length], 0);
    [chatInputBar.textView textViewDidChange:chatInputBar.textView.internalTextView];
    
}

-(void)hideKeboard:(UITapGestureRecognizer *)tap{
    [chatInputBar.textView resignFirstResponder];
    
    CGRect frame2 = emoViewNew.frame;
    frame2.origin.y = chatInputBar.frame.origin.y - (emoViewNew.frame.size.height);
    CATransition *animation = [CATransition animation];
    emoViewNew.frame = frame2;
    animation.duration = 0.0;
    [emoViewNew.layer addAnimation:animation forKey:nil];
}



-(void) keyboardWillShow:(NSNotification *)note{
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	CGRect containerFrame = chatInputBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	chatInputBar.frame = containerFrame;
  
    CGRect frame2 = emoViewNew.frame;
    frame2.origin.y = chatInputBar.frame.origin.y - (emoViewNew.frame.size.height);
    CATransition *animation = [CATransition animation];
    emoViewNew.frame = frame2;
    animation.duration = 0.0;
    [emoViewNew.layer addAnimation:animation forKey:nil];
	[UIView commitAnimations];

    if (grpChatSts==1)
    {
    [self Add_newMessage];
    }
}





-(void) keyboardWillHide:(NSNotification *)note{
    
   
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
	CGRect containerFrame = chatInputBar.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (chatInputBar.textView.frame.size.height+6);
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	[UIView commitAnimations];
    
    if (grpChatSts==1)
    {
    [self remove_newMessage];
    }
}


#pragma mark OTRChatInputBarDelegate

- (void)sendButtonPressedForInputBar:(OTRChatInputBar *)inputBar
{
    
    
    if ([inputBar.textView isFirstResponder]) {
        [inputBar.textView resignFirstResponder];
        [inputBar.textView becomeFirstResponder];
    }
    NSString * text = inputBar.textView.text;
    
    if ([text length]) {
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        OTRManagedMessage * message = [OTRManagedMessage newMessageToBuddy:self.buddy message:text encrypted:NO inContext:context];
        
        [context MR_saveToPersistentStoreAndWait];
        
        BOOL secure = [self.buddy currentEncryptionStatus] == kOTRKitMessageStateEncrypted || [OTRSettingsManager boolForOTRSettingKey:kOTRSettingKeyOpportunisticOtr];
        if(secure)
        {
        [OTRCodec hasGeneratedKeyForAccount:self.buddy.account completionBlock:^(BOOL hasGeneratedKey) {
                if (!hasGeneratedKey) {
                    [self addLockSpinner];
                    [OTRCodec generatePrivateKeyFor:self.buddy.account completionBlock:^(BOOL generatedKey) {
                        [self removeLockSpinner];
                        [OTRCodec encodeMessage:message completionBlock:^(OTRManagedMessage *message) {
                            [OTRProtocolManager sendMessage:message];
                        }];
                    }];
                }
                else {
                    [OTRCodec encodeMessage:message completionBlock:^(OTRManagedMessage *message) {
                        [OTRProtocolManager sendMessage:message];
                    }];
                }
            }];
        }
        else {
            [OTRProtocolManager sendMessage:message];
        }
        chatInputBar.textView.text = nil;
      }
}

-(BOOL)inputBar:(OTRChatInputBar *)inputBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
     NSRange textFieldRange = NSMakeRange(0, [inputBar.textView.text length]);
     
     [buddy sendComposingChatState];
     
     if (NSEqualRanges(range, textFieldRange) && [text length] == 0)
     {
          [buddy sendActiveChatState];
     }
     
     return YES;
}


-(void)formatTextInTextView:(UITextView *)textView
{
    
    NSRange selectedRange = textView.selectedRange;
    NSString *text = textView.text;
    NSString *sss = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    sss = [[sss componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@" "];
    NSArray *mmmArr = [sss componentsSeparatedByString:@" "];
    
    NSMutableAttributedString *attributedString = [self attributedStringFromString:text];
    for(int i=0;i<mmmArr.count;i++){
        
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"\\b%@\\b",[mmmArr objectAtIndex:i]] options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches22 = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        
        for (NSTextCheckingResult *match2 in matches22 ) {
            NSRange wordRange = [match2 rangeAtIndex:0];
            lastRange = wordRange.location+wordRange.length;
            if ( [matches containsObject:[[mmmArr objectAtIndex:i] lowercaseString]])
            {
                
                [attributedString addAttribute:NSUnderlineStyleAttributeName
                                         value:@(NSUnderlineStyleSingle)
                                         range:wordRange];
                
               }
            else{
                [attributedString addAttribute:NSUnderlineStyleAttributeName
                                         value:@(NSUnderlineStyleNone)
                                         range:wordRange];
            }
        }
    }
    textView.attributedText = attributedString;
    textView.selectedRange = selectedRange;
}

-(NSMutableAttributedString *)attributedStringFromString:(NSString *)ssss{
    NSMutableAttributedString *mstr = [[NSMutableAttributedString alloc] initWithString:ssss];
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    [mstr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, ssss.length)];
    return mstr;
}

-(void)didChangeFrameForInputBur:(OTRChatInputBar *)inputBar
{
    
    UIEdgeInsets tableViewInsets = self.chatHistoryTableView.contentInset;
    tableViewInsets.bottom = self.view.frame.size.height - inputBar.frame.origin.y;
    self.chatHistoryTableView.contentInset = self.chatHistoryTableView.scrollIndicatorInsets = tableViewInsets;
    self.view.keyboardTriggerOffset = inputBar.frame.size.height;
    
    calVal=0;
   
    
   if([inputBar.textView.text length]>0 && [[inputBar.textView.text substringFromIndex: [inputBar.textView.text length] - 1] isEqualToString:@" "] )
    {
        [emoViewNew getWordsFronTextView:[inputBar.textView.text lowercaseString]];
    
    }else   if (calTimer && [inputBar.textView.text length]>0){
        [calTimer invalidate];
        calTimer = nil;
        
        InputBarlocVar=inputBar;
        calTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLeftTime:) userInfo:nil repeats:NO];
  
    }else 
        calTimer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateLeftTime:) userInfo:nil repeats:NO];
    
   
    if (calVal==1) {
        
        [emoViewNew getWordsFronTextView:[inputBar.textView.text lowercaseString]];
    }
   
    
    
    if(inputBar.textView.text.length>0)
     [self formatTextInTextView:inputBar.textView.internalTextView];
    
    
    CGRect frame2 = emoViewNew.frame;
    frame2.origin.y = inputBar.frame.origin.y - (emoViewNew.frame.size.height);
    CATransition *animation = [CATransition animation];
    emoViewNew.frame = frame2;
    animation.duration = 0.0;
    [emoViewNew.layer addAnimation:animation forKey:nil];
   }

- (void)updateLeftTime:(NSTimer *)theTimer {
  
    [emoViewNew getWordsFronTextView:[InputBarlocVar.textView.text lowercaseString]];
    calVal=1;
    if(InputBarlocVar.textView.text.length>0)
        [self formatTextInTextView:InputBarlocVar.textView.internalTextView];
    
    
    
    CGRect frame2 = emoViewNew.frame;
    frame2.origin.y = InputBarlocVar.frame.origin.y - (emoViewNew.frame.size.height);
    CATransition *animation = [CATransition animation];
    emoViewNew.frame = frame2;
    animation.duration = 0.0;
    [emoViewNew.layer addAnimation:animation forKey:nil];
 
}


-(void)textTapped:(NSString *)tappedStr value:(int)val{
    
    if (val == 1) {
        [emoViewNew getemoji:tappedStr forValue:1];
      
    }
    else if(val ==0){
        
         [emoViewNew getWordsFronTextView:tappedStr];
       
    }
    
    
    CGRect frame2 = emoViewNew.frame;
    frame2.origin.y = chatInputBar.frame.origin.y - (emoViewNew.frame.size.height);
    CATransition *animation = [CATransition animation];
    emoViewNew.frame = frame2;
    animation.duration = 0.0;
    [emoViewNew.layer addAnimation:animation forKey:nil];
  
}




- (void)cameraButtonPressedForInputBar{
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Camera",@"Gallery", nil];
    [alert show];
    alert.tag=3;
    alert.delegate=self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    cameraViewSts=1;
    
    if (alertView.tag==3)
    {
        
        Imagepicker = [[UIImagePickerController alloc] init];
        Imagepicker.delegate = self;
        
        
        if (buttonIndex==0)
        {
           cameraViewSts=0;
        }
        else if(buttonIndex==2)
        {
            Imagepicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:Imagepicker animated:YES completion:nil];
            
        }  else if(buttonIndex==1)
        {
            
            @try
            {
                Imagepicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:Imagepicker animated:YES completion:nil];
            }
            @catch (NSException *exception)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera is not available  " delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
        }
    }
    
}


-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    
    UIImage *image=  [info objectForKey: UIImagePickerControllerOriginalImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (image.size.width>400) {
        imagetoupload=[RoxieMethods imageResizeWithBorderFromImage:image];
    } else
    {
        imagetoupload=image;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    cameraViewSts=0;
    
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
}



-(void)Add_newMessage{
    
    if (IS_IPHONE_5) {
        newMsg=[[RoxieNewMessage alloc]initWithFrame:CGRectMake(0, 0, 320, 308)];
    }else
        newMsg=[[RoxieNewMessage alloc]initWithFrame:CGRectMake(0, 0, 320, 182)];
    
    newMsg.backgroundColor=[UIColor whiteColor ];
    [newMsg setDelegate:self];
    
  
    NSArray *arr=[[NSArray alloc]initWithObjects:@"ABC",@"XYZ",@"EEE",@"RRR", nil];
    [newMsg show_member:arr];
    
    
    [self.view addSubview:newMsg ];
    
    [btn setHidden:YES];
    titleView.titleLabel.text=@"New Message";
    
    
    UIButton *newCross = [UIButton buttonWithType:UIButtonTypeCustom];
    newCross.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"cross_Msg.png"]];
    [newCross addTarget:self action:@selector(remove_newMessage) forControlEvents:UIControlEventTouchUpInside];
    newCross.frame = CGRectMake(18.0f, 0.0f, 52.0f, 30.0f);
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithCustomView:newCross];
    self.navigationItem.rightBarButtonItem  = newButton;

}


-(void)remove_newMessage{
    titleView.titleLabel.text=nil;
    [newMsg removeFromSuperview];
    [btn setHidden:NO];
    titleView.titleLabel.text=titlStr;
   
    if (grpChatSts==1) {
        self.navigationItem.rightBarButtonItem = addBarButton;
    }else
        self.navigationItem.rightBarButtonItem=nil;
    
     [self.view endEditing:YES];
    }

- (void)inputBarDidBeginEditing:(OTRChatInputBar *)inputBar
{
    [self scrollToBottomAnimated:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
         backView.hidden = NO;
}

@end
