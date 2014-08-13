//
//  SearchCell.h
//  Created by Keyideas Mac mini on 04/06/14.
//add XMPP 0055 files

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell{
    
    UILabel *userName,*nickName;
    UIImageView *userImage;
}
@property(nonatomic,retain)   UILabel *userName;
@property(nonatomic,retain)   UILabel *nickName;
@property(nonatomic,retain)   UIImageView *userImage;
@end
