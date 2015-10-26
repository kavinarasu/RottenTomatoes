//
//  MovieDetailsViewController.m
//  RottenTomatoes
//
//  Created by Kavin Arasu on 10/24/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "MovieDetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *moviePhotoView;
@property (weak, nonatomic) IBOutlet UIScrollView *synopsisView;

@end

@implementation MovieDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSRange range = [self.moviePhotoUrl rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    NSString *newUrlString = [self.moviePhotoUrl stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    NSURL *url = [NSURL URLWithString:newUrlString];
    [self.moviePhotoView setImageWithURL:url];
    CGSize size = self.synopsisView.bounds.size;
    CGFloat subviewHeight = size.height;
    CGFloat currentViewOffset = 0;

    UILabel *label = [[UILabel alloc] init];
    
    [label setText:self.movieSynopsis];
    [label setNumberOfLines:0];
    [label setFont:[UIFont systemFontOfSize:16]];
    label.textColor = [UIColor whiteColor];
    label.alpha = 0.8;
    CGSize maximumLabelSize = CGSizeMake(296,9999);
    CGRect rect = [self.movieSynopsis boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:label.font} context:nil];

    CGSize expectedSize = rect.size;
    label.frame = CGRectMake(
                             10, 10,
                             size.width, expectedSize.height);
    
        self.synopsisView.contentSize = CGSizeMake(size.width, label.frame.size.height);
        [self.synopsisView addSubview:label];
        currentViewOffset += subviewHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
