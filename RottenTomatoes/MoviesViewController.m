//
//  ViewController.m
//  RottenTomatoes
//
//  Created by Kavin Arasu on 10/20/15.
//  Copyright © 2015 codepath. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailsViewController.h"
#import "JTProgressHUD.h"
#import "AFNetworkReachabilityManager.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *networkIssueView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *filteredMovies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign, getter=isNetworkReachable) BOOL networkReachable;
@property (nonatomic, assign, getter=isKeyboardVisible) BOOL keyboardVisible;
@end

@implementation MoviesViewController

- (IBAction)searchFieldChanged:(UITextField *)sender {
    NSString *text = [self.searchField text];
    if([text length] == 0) {
        self.filteredMovies = self.movies;
    } else {
    self.filteredMovies = [self.movies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(title contains[cd] %@)", text]];
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.title = @"Movies";
    self.networkIssueView.hidden = true;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self setNetworkReachable:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [self fetchMovies];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (void)onRefresh {
    [self fetchMovies];
}

- (void)keyboardDidShow: (NSNotification *) notif{
    self.keyboardVisible = true;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    self.keyboardVisible = false;
}

- (void) fetchMovies {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [self setNetworkReachable:YES];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [self setNetworkReachable:NO];
                break;
        }
        
    }];
    if([self isNetworkReachable]) {
        self.networkIssueView.hidden = true;
        NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
        NSURLSession *session =
        [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
        [JTProgressHUD show];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                    self.movies = responseDictionary[@"movies"];
                                                    self.filteredMovies = self.movies;
                                                    [self.tableView reloadData];
                                                    [self.refreshControl endRefreshing];
                                                    [JTProgressHUD hide];
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    [self.refreshControl endRefreshing];
                                                    [JTProgressHUD hide];
                                                }
                                            }];
            [task resume];
        } else {
            self.networkIssueView.hidden = false;
            [self.refreshControl endRefreshing];
        }

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MoviesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];

    cell.titleLabel.text = self.filteredMovies[indexPath.row][@"title"];
    cell.synopsisLabel.text = self.filteredMovies[indexPath.row][@"synopsis"];
    NSURL *url = [NSURL URLWithString:self.filteredMovies[indexPath.row][@"posters"][@"thumbnail"]];
    UIImage *placeImage = [UIImage imageNamed:@"placeholder.png"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [cell.posterImage setImageWithURLRequest:request placeholderImage:placeImage success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
        [cell.posterImage setImage:image];
    } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
        
    }];

    return cell;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if([self isNetworkReachable]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self isKeyboardVisible]) {
        [self.searchField endEditing:YES];
        return NO;
    } else {
        return YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MovieDetailsViewController *movieDetailsViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    movieDetailsViewController.moviePhotoUrl = self.filteredMovies[indexPath.row][@"posters"][@"thumbnail"];
    movieDetailsViewController.movieSynopsis = self.filteredMovies[indexPath.row][@"synopsis"];
    MoviesTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    movieDetailsViewController.placeHolderImage = [cell.posterImage image];
}


@end
