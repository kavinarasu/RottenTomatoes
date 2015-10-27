//
//  MovieDetailsViewController.h
//  RottenTomatoes
//
//  Created by Kavin Arasu on 10/24/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieDetailsViewController : UIViewController
@property (strong, nonatomic) NSString *moviePhotoUrl;
@property (strong, nonatomic) NSString *movieSynopsis;
@property (strong, nonatomic) UIImage *placeHolderImage;
@end
