
//
//  Created by Keyideas Mac mini on 04/06/14.
//

#import "UserSearchViewController.h"
#import "SearchCell.h"
#import "MySearchResult.h"
#import "Methods.h"
#import "InviteFriendViewController.h"


@interface UserSearchViewController ()

@end

@implementation UserSearchViewController
@synthesize searchTable;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)go_Back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
//Google Analytics
    self.screenName = @"Find Friends";
    UIColor *navblue=[UIColor colorWithRed:118.0/255.0 green:183.0/255.0 blue:217.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:navblue];
    [self.navigationController.navigationBar setTranslucent:YES];
    rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(invite_friends:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}


-(void)invite_friends:(id)sender{
    InviteFriendViewController *contactView = [[InviteFriendViewController alloc] init];
    UINavigationController *localNavigation=[[UINavigationController alloc]initWithRootViewController:contactView];
    [self presentViewController:localNavigation animated:YES completion:NULL];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Find Friends";
    appdelegate= (OTRAppDelegate *)[[UIApplication sharedApplication]delegate];
    btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"back.png"]];
    [btnBack addTarget:self action:@selector(go_Back:) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(18.0f, 0.0f, 52.0f, 30.0f);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem  = backButton;
    searchArray=[[NSMutableArray alloc]init ];
    NSArray *aa=@[@""];
    sObj = [[SearchUser alloc] initwith_userjID:appdelegate.userAccount.username password:[[NSUserDefaults standardUserDefaults] objectForKey:@"Password"] SearchArray:aa];
    [sObj setDelegate:self];
    [sObj connect];
    
    if (IS_IPHONE_5) {
       searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0,108,320,self.view.frame.size.height-108) style: UITableViewStylePlain];
    }else{
        searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0,108,320,self.view.frame.size.height-188) style: UITableViewStylePlain];
    }
    
   
    [searchTable setDataSource:self];
    [searchTable setDelegate:self];
    searchTable.rowHeight=80;
    [searchTable setUserInteractionEnabled:YES];
    [searchTable setSeparatorInset:UIEdgeInsetsMake(0, 85, 0, 10)];
    [searchTable setSeparatorColor:[UIColor lightGrayColor]];
    
    [self.view addSubview:searchTable];
    [self.view setUserInteractionEnabled:YES];
    searchTable.backgroundColor=[UIColor whiteColor];
    searchBar.backgroundImage=[UIImage imageNamed:@"findFriendbg.png"];
  
    }


- (void)gotoHideKeyboard{
    [self.view endEditing:YES];
}


-(void)Searchreturn_value:(NSArray *)SerchArry CallTime:(NSInteger )calTime{
 
    calT=calTime;
    if (HUD) {
        [HUD hide:YES];
    }
    searchArray=[[NSMutableArray alloc]initWithArray:SerchArry];
    [searchTable reloadData];
}

-(void)Return_Failvalue:(NSString *)str{
    if (HUD) {
        [HUD hide:YES];
    }
    
}

-(void)Return_FailWithError:(NSError *)err{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"There is some Error Try again!"  delegate:self  cancelButtonTitle:@"OK"  otherButtonTitles:nil];
    
    [alert show];
    
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [searchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchCell";
    SearchCell *cell = (SearchCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[SearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
       
    }
    
        cell.imageView.image=[UIImage imageNamed:@"person.png"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        MySearchResult *serchObj=[searchArray objectAtIndex:indexPath.row];
        cell.textLabel.text=[self Create_cellString:serchObj];
        return cell;
}



-(NSString *)Create_cellString:(MySearchResult *)resStr
{
    NSMutableString *str=[[NSMutableString alloc]initWithString:[Methods remove_substring: resStr.jId :@"@abc.com"]];
    if ([resStr.nicName length]>0) {
        [str appendString:[NSString stringWithFormat:@" | %@",resStr.nicName]];
    }
    if ([resStr.scholName length]>2) {
        [str appendString:[NSString stringWithFormat:@" | %@",resStr.scholName]];
    }
    if ([resStr.email length]>2) {
        [str appendString:[NSString stringWithFormat:@" | %@",resStr.email]];
    }
    if ([resStr.phonNo length]>1) {
        [str appendString:[NSString stringWithFormat:@" | %@",resStr.phonNo]];
    }
    return (NSString *)str;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ClickIndexPath=indexPath;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""    message:@"Send a friend request"  delegate:self  cancelButtonTitle:@"No"  otherButtonTitles:@"Yes",nil];
    [alert setTag:3];
    [alert show];
   
}



- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    
    if ([alertView tag]==3 && buttonIndex==1) {
            MySearchResult *serchObj=[searchArray objectAtIndex:ClickIndexPath.row];
        
            NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
            OTRManagedBuddy * newBuddy = [OTRManagedBuddy fetchOrCreateWithName:serchObj.jId account:appdelegate.userAccount inContext:context];
    
          [context MR_saveToPersistentStoreAndWait];
        
            id<OTRProtocol> protocol = [[OTRProtocolManager sharedInstance] protocolForAccount:appdelegate.userAccount];
            [protocol addBuddy:newBuddy];
        
        }

}


#pragma mark -
#pragma mark Search Bar

- (void) doneSearching_Clicked:(id)sender {
    [searchBar resignFirstResponder];
    
    if ([searchArray count]==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:@"No record found" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        [searchBar resignFirstResponder];
    }
	
    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {

}


- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText
{
    
    if ([theSearchBar.text  length]==0)
    {
        [searchBar resignFirstResponder];
        [searchArray removeAllObjects];
        [ searchTable reloadData];
        
    }
  
}



- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [self showLoginProgress:@"Searching"];
    [self performSelector:@selector(getSearchItem:) withObject:theSearchBar.text afterDelay:0.1];
    [searchBar resignFirstResponder];
}

-(void)getSearchItem:(id)sender{
    calT=0;
    [searchArray removeAllObjects];
    [searchTable reloadData];
    [sObj askForFields_withSearchString:searchBar.text];
    
}

-(void)showLoginProgress :(NSString *)str
{
    [self.view endEditing:YES];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = str;
    [HUD show:YES];
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:45.0 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
}

-(void) timeout:(NSTimer *) timer
{
    if (HUD) {
        [HUD hide:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
