//
//  MySearchResult.h
//  iPhoneXMPP
//
//  Created by Keyideas Mac mini on 03/06/14.
//
//add XMPP 0055 files

#import <Foundation/Foundation.h>

@interface MySearchResult : NSObject{
    
    NSString *userName,*nicName,*jId,*email,*scholName,*phonNo;
}

@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *nicName;
@property(nonatomic, strong) NSString *jId;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *scholName;
@property(nonatomic, strong) NSString *phonNo;


@end
