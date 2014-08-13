//
//  SearchUser.m
//
//  Created by Keyideas Mac mini on 04/06/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import "SearchUser.h"
#import "MySearchResult.h"

@implementation SearchUser
@synthesize  delegate;


- (id)initwith_userjID :(NSString *)user_jID password:(NSString *)password SearchArray:(NSArray *)strArr
{
    jID=user_jID;
    passWord=password;
    srchArr=strArr;
    if (self) {
        _stream = [[XMPPStream alloc] init];
        _stream.hostName = @"abc.com";
        _stream.hostPort = 5222;
        _stream.myJID = [XMPPJID jidWithString:jID];
        [_stream addDelegate:self  delegateQueue:dispatch_get_main_queue()];
        _searchModule = [[XMPPSearchModule alloc] initWithDispatchQueue:dispatch_get_current_queue()];
        _searchModule.searchHost = @"vjud.abc.com";
        [_searchModule activate:_stream];
        [_searchModule addDelegate:self   delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _stream = [[XMPPStream alloc] init];
        _stream.hostName = @"abc.com";
        _stream.hostPort = 5222;
        _stream.myJID = [XMPPJID jidWithString:@"xyz@abc.com"];
        [_stream addDelegate:self
               delegateQueue:dispatch_get_main_queue()];
        _searchModule = [[XMPPSearchModule alloc] initWithDispatchQueue:dispatch_get_current_queue()];
        _searchModule.searchHost = @"vjud.abc.com";
        [_searchModule activate:_stream];
        [_searchModule addDelegate:self
                     delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)askForFields
{
    [_searchModule askForFields];
}

- (void)askForFields_withSearchString :(NSString *)serchString{
    calval=0;
    listArray=[[NSMutableArray alloc]init];
    srchArr=[serchString  componentsSeparatedByString:@"|"];
    [_searchModule askForFields];
}


- (void)connect
{
    NSError *err = nil;
    [_stream connectWithTimeout:10  error:&err];
    if (err) {
        [self.delegate Return_FailWithError:err];
    }
}

- (void)searchModel:(XMPPSearchModule*)searchModul result:(XMPPSearchReported*)result userData:(id)userData
{
    NSMutableArray *results = [NSMutableArray new];
    for (NSDictionary *resultDic in result.items) {
        MySearchResult *result = [MySearchResult new];
        result.userName = [resultDic objectForKey:@"fn"];
        result.nicName = [resultDic objectForKey:@"nick"];
        result.jId = [resultDic objectForKey:@"jid"];
        result.scholName = [resultDic objectForKey:@"orgname"];
        result.email = [resultDic objectForKey:@"fn"];
        result.phonNo = [resultDic objectForKey:@"middle"];
        [results addObject:result];
    
        int insrtVal=0;
        for (MySearchResult *dict in listArray) {
            if ([dict.jId isEqualToString:[resultDic objectForKey:@"jid"]]) {
                insrtVal=1;
            }
        }
        if (insrtVal==0 && ![ result.jId isEqualToString:jID]) {
            [listArray addObject:result];
        }
    
    }
    if ([listArray count]>0) {
         [self.delegate Searchreturn_value:listArray CallTime:calval];
    }else{
        [self.delegate Return_Failvalue:@"No Records"];
    }
    calval++;
}

- (void)searchModelGetFields:(XMPPSearchModule *)searchModul
{
    NSArray *arr = [searchModul.result copyForTableFields];
    for (XMPPSearchStringSingleNode *node in arr) {
        if ([node.name isEqualToString:@"jid"]) {
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
            
        }else if ([node.name isEqualToString:@"user"]) {
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
     
        }else if ([node.name isEqualToString:@"nick"]){
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
        
        }else if ([node.name isEqualToString:@"fn"]){
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
        
        }else if ([node.name isEqualToString:@"orgname"]){
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
            
        }else if ([node.name isEqualToString:@"middle"]){
            node.value =[NSString stringWithFormat:@"%@*",[srchArr objectAtIndex:0]];
            [_searchModule searchWithFields:@[node] userData:nil];
            
        }
    }
}

- (void)xmppStreamDidConnect:(XMPPStream *)stream
{
    NSError *error = nil;
    if (![stream authenticateWithPassword:passWord error:&error])
    {
        NSLog(@"Error authenticating: %@", error);
        [self.delegate Return_FailWithError:error];
    }
}


    
    

@end
