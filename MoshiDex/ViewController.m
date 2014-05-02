//
//  ViewController.m
//  MoshiDex
//
//  Created by Jeremy Herrero on 12/26/13.
//  Copyright (c) 2013 Grants International Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "ViewController.h"
#import "MoshiDetailsViewController.h"

@interface ViewController () {
    
    NSArray *moshiRetrievalArray;
    
    UIView *loadingView;
    UIActivityIndicatorView *activityIndicator;
    NSMutableArray *moshiNameArray;
    NSMutableArray *moshiNumberArray;
    NSMutableArray *moshiSeries;
    NSMutableArray *moshiSpecies;
    NSMutableArray *moshiType;
    NSMutableArray *moshiLocation;
    NSMutableArray *moshiRarity;
    NSMutableArray *moshiDescription;
    NSMutableArray *moshiPicArray;
    
    NSMutableArray *moshiArray;
    NSMutableArray *imageArray;
    __weak IBOutlet UISegmentedControl *segmentController;
    __weak IBOutlet UITableView *moshiTableView;
}
- (IBAction)sortSelection:(id)sender;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMoshi)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    
    _moshiReady = NO;
    
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(85, 150, 150, 150)];
    loadingView.backgroundColor = [UIColor blackColor];
    [loadingView setAlpha:0.8];
    loadingView.layer.cornerRadius = 25;
    [loadingView.layer setMasksToBounds:YES];
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 50, 100, 100)];
    loadingLabel.text = @"Loading";
    loadingLabel.font = [UIFont systemFontOfSize:18];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(75, 60, 0, 0);
    
    [loadingView addSubview:loadingLabel];
    [loadingView addSubview:activityIndicator];
    [self.view addSubview:loadingView];
    [self.view bringSubviewToFront:loadingView];
    
    [self startLoading];
    
    [self getParse];
    
//    [moshiTableView reloadData];
}
//use viewWillAppear to refresh on return to view. Did not implement as only needed for admin auto-return from Approval, and data not updated fast enough from Parse before transition (usually takes another couple seconds). 
-(void)viewWillAppear:(BOOL)animated{
//    [self getParse];
}
-(void)getParse{
    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
    [query setLimit:1000];
    if (segmentController.selectedSegmentIndex == 1) {
        [query orderByAscending:@"MoshiNumber"];
    }else{
        [query orderByAscending:@"MoshiName"];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            moshiArray = [[NSMutableArray alloc] initWithArray:objects];
                                     NSLog(@"arraycount %lu",(unsigned long)moshiArray.count );
        }
        [self reloadData];
    }];
    
}

- (void)reloadData {
    if (/*imageArray.count == */ moshiArray.count) {
        [moshiTableView reloadData];
        _moshiReady = YES;
        [self stopLoading];
    }
    else {
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    }
}

- (void)addMoshi {
    [self performSegueWithIdentifier:@"addMoshi" sender:self];
}

- (void)startLoading {
    [self.view setUserInteractionEnabled:NO];
    [loadingView setHidden:NO];
    [activityIndicator startAnimating];
}

- (void)stopLoading {
    [loadingView setHidden:YES];
    [activityIndicator stopAnimating];
    [self.view setUserInteractionEnabled:YES];
}
- (IBAction)sortSelection:(id)sender {
    [self getParse];
    
    switch (((UISegmentedControl *) sender).selectedSegmentIndex){
        case 0:
            NSLog(@"yes");
            break;
        case 1:
            NSLog(@"no");
            break;
        default:
            break;
            
    }
    
}

#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return moshiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifer"];
    }
    if (moshiArray.count ) {
        
        PFObject* cellObject = [moshiArray objectAtIndex:indexPath.row];
        
        
        PFFile *pic = (PFFile*)[cellObject objectForKey:@"MoshiPicture"];
        [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                UIImage *picture = [UIImage imageWithData:data];
                
                cell.imageView.image = picture;
                cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];

            }
        }];
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewMoshi"]) {
        MoshiDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.detailInfo = [moshiArray objectAtIndex:_indexSelected];
    }}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_moshiReady) {
        _indexSelected = indexPath.row;
        [self performSegueWithIdentifier:@"viewMoshi" sender:self];
    }
}

@end
