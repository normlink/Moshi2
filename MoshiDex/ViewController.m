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
    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.simpleanywhere.com/moshidex/moshiapi.json"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
    
//        NSArray *tempArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
//        moshiRetrievalArray = [[NSArray alloc] initWithArray:tempArray];
    
        _moshiReady = NO;
        
//        moshiNameArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiNumberArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiSeries = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiSpecies = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiType = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiLocation = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiRarity = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiDescription = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
//        moshiPicArray = [[NSMutableArray alloc] initWithCapacity:moshiRetrievalArray.count];
    
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
    
//        for (int count = 0; count < moshiRetrievalArray.count; count++) {
//            PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
//            [query getObjectInBackgroundWithId:[NSString stringWithFormat:@"%@", [moshiRetrievalArray objectAtIndex:count]] block:^(PFObject *moshiData, NSError *error) {
//                [moshiNameArray addObject:[moshiData objectForKey:@"MoshiName"]];
//                [moshiNumberArray addObject:[moshiData objectForKey:@"MoshiNumber"]];
//                [moshiSeries addObject:[moshiData objectForKey:@"MoshiSeries"]];
//                [moshiSpecies addObject:[moshiData objectForKey:@"MoshiSpecies"]];
//                [moshiType addObject:[moshiData objectForKey:@"MoshiType"]];
//                [moshiLocation addObject:[moshiData objectForKey:@"MoshiLocation"]];
//                [moshiRarity addObject:[moshiData objectForKey:@"MoshiRare"]];
//                [moshiDescription addObject:[moshiData objectForKey:@"MoshiDescription"]];
//                if (!error) {
//                    PFFile *imageFile = [moshiData objectForKey:@"MoshiPicture"];
//                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                        if (!error) {
//                            UIImage *image = [UIImage imageWithData:data];
//                            [moshiPicArray addObject:image];
//                        }
//                    }];
//                }
//            }];
//        }
        [moshiTableView reloadData];
//    }];
}
-(void)getParse{
    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
    if (segmentController.selectedSegmentIndex == 1) {
        [query orderByAscending:@"MoshiNumber"];
    }else{
        [query orderByAscending:@"MoshiName"];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            moshiArray = [[NSMutableArray alloc] initWithArray:objects];
            imageArray = [[NSMutableArray alloc] initWithCapacity:[moshiArray count]];
                for (PFObject* obj in moshiArray) {
                    PFFile *pic = (PFFile*)[obj objectForKey:@"MoshiPicture"];
                    [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    [imageArray addObject:image];
                            NSLog(@"%lu, %lu %@",(unsigned long)moshiArray.count,(unsigned long)imageArray.count ,[obj objectForKey:@"MoshiNumber"]);
                        }
                    }];
                }
           
        }
        [self reloadData];
    }];

}

- (void)reloadData {
    if (imageArray.count == moshiArray.count) {
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
//    if (segmentController.selectedSegmentIndex == 0) {
//         NSLog(@"yes");
    
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
    if (moshiArray.count > 1) {
//        cell.textLabel.text = [NSString stringWithFormat:@"%@", [moshiNameArray objectAtIndex:indexPath.row]];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [moshiNumberArray objectAtIndex:indexPath.row]];
//        cell.imageView.image = [moshiPicArray objectAtIndex:indexPath.row];
        
        PFObject* cellObject = [moshiArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];
        cell.imageView.image = [imageArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = @"Loading...";
    }
    
    return cell;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"viewMoshi"]) {
//        MoshiDetailsViewController *detailsVC = segue.destinationViewController;
//        detailsVC.nameIncoming = [moshiNameArray objectAtIndex:_indexSelected];
//        detailsVC.numberIncoming = [moshiNumberArray objectAtIndex:_indexSelected];
//        detailsVC.seriesIncoming = [moshiSeries objectAtIndex:_indexSelected];
//        detailsVC.speciesIncoming = [moshiSpecies objectAtIndex:_indexSelected];
//        detailsVC.typeIncoming = [moshiType objectAtIndex:_indexSelected];
//        detailsVC.locationIncoming = [moshiLocation objectAtIndex:_indexSelected];
//        detailsVC.rarityIncoming = [moshiRarity objectAtIndex:_indexSelected];
//        detailsVC.descriptionIncoming = [moshiDescription objectAtIndex:_indexSelected];
//        detailsVC.imageIncoming = [moshiPicArray objectAtIndex:_indexSelected];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_moshiReady) {
        _indexSelected = indexPath.row;
        [self performSegueWithIdentifier:@"viewMoshi" sender:self];
    }
}

@end
