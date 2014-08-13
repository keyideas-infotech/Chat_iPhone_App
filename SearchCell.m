//
//  SearchCell.m
//
//add XMPP 0055 files

#import "SearchCell.h"

@implementation SearchCell
@synthesize userName,nickName,userImage;

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(15,10,60,60);
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 30;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2.0;
 
    
    CGRect frame = self.textLabel.frame;
    frame.origin.x = self.imageView.frame.origin.x+self.imageView.frame.size.width+10;
    frame.size.width = self.frame.size.width-115;
    frame.size.height= self.frame.size.height-5;
    frame.origin.y=2;
    self.textLabel.frame = frame;
    self.textLabel.numberOfLines=5.0;
    self.textLabel.font=[UIFont systemFontOfSize:14.0];
    self.textLabel.textColor = [UIColor lightGrayColor];
    
    CGRect frame2 = self.detailTextLabel.frame;
    frame2.origin.x = self.imageView.frame.origin.x+self.imageView.frame.size.width+10;
    self.detailTextLabel.frame = frame2;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
   
        if ([self.reuseIdentifier isEqualToString:@"SearchCell"])
        {

        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



@end
