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
    
    __weak IBOutlet UITableView *moshiTableView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMoshi)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.simpleanywhere.com/moshidex/moshiapi.json"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        moshiRetrievalArray = [[NSArray alloc] initWithArray:tempArray];
        
        _moshiReady = NO;
        
        moshiNameArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiNumberArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiSeries = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiSpecies = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiType = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiLocation = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiRarity = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiDescription = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        moshiPicArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
        
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
        
        for (int count = 0; count < moshiRetrievalArray.count; count++) {
            PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
            [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@", [moshiRetrievalArray objectAtIndex:count]] block:^(PFObject *moshiData, NSError *error) {
                [moshiNameArray addObject:[moshiData objectForKey:@"MoshiName"]];
                [moshiNumberArray addObject:[moshiData objectForKey:@"MoshiNumber"]];
                [moshiSeries addObject:[moshiData objectForKey:@"MoshiSeries"]];
                [moshiSpecies addObject:[moshiData objectForKey:@"MoshiSpecies"]];
                [moshiType addObject:[moshiData objectForKey:@"MoshiType"]];
                [moshiLocation addObject:[moshiData objectForKey:@"MoshiLocation"]];
                [moshiRarity addObject:[moshiData objectForKey:@"MoshiRare"]];
                [moshiDescription addObject:[moshiData objectForKey:@"MoshiDescription"]];
                if (!error) {
                    PFFile *imageFile = [moshiData objectForKey:@"MoshiPicture"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:data];
                            [moshiPicArray addObject:image];
                        }
                    }];
                }
            }];
        }
        [self reloadData];
    }];
}

- (void)reloadData {
    if (moshiPicArray.count == moshiRetrievalArray.count) {
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

#pragma mark UITableView Delegate
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return moshiRetrievalArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifer"];
    }
    if (moshiNameArray.count > 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [moshiNameArray objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [moshiNumberArray objectAtIndex:indexPath.row]];
        cell.imageView.image = [moshiPicArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"viewMoshi"]) {
        MoshiDetailsViewController *detailsVC = segue.destinationViewController;
        detailsVC.nameIncoming = [moshiNameArray objectAtIndex:_indexSelected];
        detailsVC.numberIncoming = [moshiNumberArray objectAtIndex:_indexSelected];
        detailsVC.seriesIncoming = [moshiSeries objectAtIndex:_indexSelected];
        detailsVC.speciesIncoming = [moshiSpecies objectAtIndex:_indexSelected];
        detailsVC.typeIncoming = [moshiType objectAtIndex:_indexSelected];
        detailsVC.locationIncoming = [moshiLocation objectAtIndex:_indexSelected];
        detailsVC.rarityIncoming = [moshiRarity objectAtIndex:_indexSelected];
        detailsVC.descriptionIncoming = [moshiDescription objectAtIndex:_indexSelected];
        detailsVC.imageIncoming = [moshiPicArray objectAtIndex:_indexSelected];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_moshiReady) {
        _indexSelected = indexPath.row;
        [self performSegueWithIdentifier:@"viewMoshi" sender:self];
    }
}

@end
