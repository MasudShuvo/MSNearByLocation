//
//  MSLocationTableViewCell.h
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/7/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *locationTitle;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutlet UIImageView *locationImage;

@end
