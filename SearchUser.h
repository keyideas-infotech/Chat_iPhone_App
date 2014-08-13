//
//  SearchUser.h
//
//  Created by Keyideas Mac mini on 04/06/14.
//  Copyright (c) 2014 Chris Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPSearchModule.h"



@protocol SearchUserDelegate ;

@interface SearchUser : NSObject{
    XMPPStream  *_stream;
    XMPPSearchModule    *_searchModule;
    NSString *jID,*passWord;
    NSArray *srchArr;
    NSMutableArray *listArray;
    NSInteger calval;
    id <SearchUserDelegate> delegate;
}

- (void)connect;
- (void)askForFields;
- (void)search;

- (void)askForFields_withSearchString :(NSString *)serchString;

- (id)initwith_userjID :(NSString *)user_jID password:(NSString *)password SearchArray:(NSArray *)strArr;

-(void)Search_user:(NSString *)serchString;


@property (nonatomic,strong)  id <SearchUserDelegate> delegate;
@end


@protocol SearchUserDelegate<NSObject>
@optional
-(void)Searchreturn_value:(NSArray *)SerchArry CallTime:(NSInteger )calTime;
-(void)Return_Failvalue:(NSString *)str;
-(void)Return_FailWithError:(NSError *)err;
@end