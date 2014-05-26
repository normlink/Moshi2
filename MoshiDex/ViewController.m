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
#import "AdminViewController.h"

@interface ViewController () {
    
    UIActivityIndicatorView *activityInd;
    UILocalizedIndexedCollation *collation;
    NSMutableArray *moshiArray;
    NSMutableArray *sections;
    NSArray *searchResults;
    NSArray *unapprovedArray;
    NSMutableArray *adminSections;
    NSMutableArray *adminTitles;
    NSMutableArray *tArray;
    int enterAdmin;
    int incrementCheck;
    BOOL editMode;
    BOOL didEdit;
    BOOL didSubmit;
    //    NSMutableArray *imageArray;
    __weak IBOutlet UISegmentedControl *segmentController;
    __weak IBOutlet UITableView *moshiTableView;
}
- (IBAction)sortSelection:(id)sender;


@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    enterAdmin = 0;
    incrementCheck = 0;
    editMode = NO;
    didEdit = NO;
    didSubmit = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addMoshi)];
    self.navigationItem.rightBarButtonItem = addButton;
    
//    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor yellowColor]];
    
    activityInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityInd.center = self.view.center;
    [activityInd setColor:[UIColor yellowColor]];
    [activityInd setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:activityInd];
    [self.view bringSubviewToFront:activityInd];
    [activityInd setHidden:YES];
    
    [self startLoading];
    
    [self getParse];
    
    //    [moshiTableView reloadData];
}

#pragma mark AddMoshiDelegate
-(void)changeAdminVar:(BOOL)var {
    editMode = var;
    if (editMode == YES) {
        self.title = @"AdminMode";
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        enterAdmin +=1;
    }else{
        self.title = @"MoshiDex";
        self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
        
        incrementCheck +=1;
    }
//    NSLog(@"%hhd",editMode);
}
-(void)changeSubmitVar:(BOOL)var{
    didSubmit = var;
}

#pragma mark AdminDelegate
-(void)adminReload:(BOOL)var {
    didEdit = var;
}



//use viewWillAppear to refresh on return to view. Did not implement initially as only needed for admin auto-return from Approval, and data not updated fast enough from Parse before transition (usually takes another couple seconds). Currently am implementing to facilitate initial admin mode sort, and the increment check to do resort on admin exit., and (in concert w/completion block) when do edit/approve/delete.
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (didEdit == YES) {
        [self startLoading];
        [self getParse];
        didEdit = NO;
    }
    if ((editMode == YES) && (enterAdmin == 1)){
        [self startLoading];
        [self getParse];
        enterAdmin = 0;
    }
    if ((editMode == YES) && (didSubmit == YES)){
        [self startLoading];
        [self getParse];
        didSubmit = NO;
    }
    if (incrementCheck == 1) {
        [self startLoading];
        [self getParse];
        incrementCheck = 0;
    }
}
-(void)getParse{
    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
    [query setLimit:1000];
    
    if (editMode == YES) {
        if (segmentController.selectedSegmentIndex == 1) {
            [query orderByAscending:@"MoshiApproved,MoshiNumber"];
        }else{
            [query orderByAscending:@"MoshiApproved,MoshiName"];
        }
    } else {
        [query whereKey:@"MoshiApproved" equalTo:@YES];
        if (segmentController.selectedSegmentIndex == 1) {
            [query orderByAscending:@"MoshiNumber"];
        }else{
            [query orderByAscending:@"MoshiName"];
        }
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            moshiArray = [[NSMutableArray alloc] initWithArray:objects];
            NSLog(@"arraycount %lu",(unsigned long)moshiArray.count );
            [self partitionObjects:moshiArray];
            [self getUnapprovedArray:moshiArray];
            
//            add unapprovedArray and title to arrays for Admin mode indexing:
            adminSections = [[NSMutableArray alloc] initWithArray:sections];
            [adminSections insertObject:unapprovedArray atIndex:0];
            adminTitles = [[NSMutableArray alloc] initWithArray:[collation sectionTitles]];
            [adminTitles insertObject:@"UNAPPROVED" atIndex:0];
        }
        [self reloadData];
    }];
    
}

- (void)reloadData {
    if (moshiArray) {
        [moshiTableView reloadData];
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
    [activityInd startAnimating];
}

- (void)stopLoading {
    [activityInd stopAnimating];
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
-(NSArray*)getUnapprovedArray:(NSMutableArray*)array{
    tArray = [[NSMutableArray alloc] init];
    for (PFObject *object in array) {
        if ([object[@"MoshiApproved"] isEqual:@NO]) {
            [tArray addObject:object];
        }
    }
//    unapprovedArray = [[NSArray alloc] init];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"MoshiName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = @[sorter];
    NSArray *sortedArray = [tArray sortedArrayUsingDescriptors:sortDescriptors];
//    [unapprovedArray arrayByAddingObjectsFromArray:sortedArray];
    unapprovedArray = [[NSArray alloc] initWithArray:sortedArray];

    return unapprovedArray;
}
- (NSMutableArray *)partitionObjects:(NSMutableArray *)array
{
    //    SEL selector = @selector(localizedTitle);
    collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionCount = [[collation sectionTitles] count];
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    for(int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    for (id object in array)
    {
        NSInteger index = [collation sectionForObject:object[@"MoshiName"] collationStringSelector:@selector(lowercaseString)];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    sections = [NSMutableArray arrayWithCapacity:sectionCount];
    int log = 0;
    for (NSMutableArray *section in unsortedSections) {
        log+=1;
        if (![section count] || (section == nil)) {
            [sections addObject:section];
            NSLog(@"Log %d Part1 sections %lu",log,(unsigned long)[sections count]);
        } else {
//                        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:NSSelectorFromString(@"MoshiName")]];
//              Could not figure out proper collationStringSelector so used NSSortDescriptor below:
            NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"MoshiName" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            NSArray *sortDescriptors = @[sorter];
            NSArray *sortedArray = [section sortedArrayUsingDescriptors:sortDescriptors];
            [sections addObject:sortedArray];
            NSLog(@"Log %d Part2 sections %lu",log,(unsigned long)[sections count]);
        }
    }
    //        sections = unsortedSections;
    NSLog(@"unsorted %lu sections %lu", (unsigned long)[unsortedSections count],(unsigned long)[sections count]);
    return sections;
}
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"MoshiName contains[c] %@",searchText];
    searchResults = [moshiArray filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark Search Delegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


#pragma mark UITableView Delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
        if ([[sections objectAtIndex:section] count] > 0) {
            return [[collation sectionTitles] objectAtIndex:section];
        }
    }
    else if ((editMode == YES) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
        if ([[adminSections objectAtIndex:section] count] > 0) {
            return [adminTitles objectAtIndex:section];
        }
    }
    return nil;
}
// This didn't work to eliminate unused index titles:
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return [collation sectionForSectionIndexTitleAtIndex:index];
//}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Set the text color of our header/footer text.
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    //    [header.textLabel setTextColor:[UIColor whiteColor]];
    
    // Set the background color of our header/footer.
    header.contentView.backgroundColor = [UIColor yellowColor];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
        return [collation sectionIndexTitles];
//     for Admin indexing:
    }else
        if ((editMode == YES) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
            NSMutableArray *tempAdM = [[NSMutableArray alloc] initWithArray:[collation sectionIndexTitles]];
            [tempAdM insertObject:@"*UN" atIndex:0];
            NSArray *forAdmin = [NSArray arrayWithArray:tempAdM];
            return forAdmin;
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
        return [[collation sectionTitles] count];
        NSLog(@"titlecount %lu",(unsigned long)[[collation sectionTitles] count]);
    }else if ((editMode == YES) && (segmentController.selectedSegmentIndex == 0) && !(tableView == self.searchDisplayController.searchResultsTableView)){
        return [adminTitles count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    }else if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0)) {
        return [[sections objectAtIndex:section] count];
    }else if ((editMode == YES) && (segmentController.selectedSegmentIndex == 0)) {
        return [[adminSections objectAtIndex:section] count];
    }
    return moshiArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier"];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellIdentifer"];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFObject* cellObject = [searchResults objectAtIndex:indexPath.row];
        
        
        PFFile *pic = (PFFile*)[cellObject objectForKey:@"MoshiPicture"];
        [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                UIImage *picture = [UIImage imageWithData:data];
                
                cell.imageView.image = picture;
                
                //to same-size cell pics (pics may be distorted with this method)
                CGSize itemSize = CGSizeMake(50, 40);
                UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                [cell.imageView.image drawInRect:imageRect];
                cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];
                if ([[cellObject objectForKey:@"MoshiApproved"]  isEqual: @NO]) {
                    [cell.textLabel setHighlighted:YES];
                    [cell.textLabel setHighlightedTextColor:[UIColor redColor]];
                }
            }
        }];
        
    }else if (moshiArray) {
        if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0)) {
            PFObject* cellObject = [[sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            PFFile *pic = (PFFile*)[cellObject objectForKey:@"MoshiPicture"];
            [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    UIImage *picture = [UIImage imageWithData:data];
                    
                    cell.imageView.image = picture;
                    
                    //to same-size cell pics (pics may be distorted with this method)
                    CGSize itemSize = CGSizeMake(50, 40);
                    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    [cell.imageView.image drawInRect:imageRect];
                    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];
                    if ([[cellObject objectForKey:@"MoshiApproved"]  isEqual: @NO]) {
                        [cell.textLabel setHighlighted:YES];
                        [cell.textLabel setHighlightedTextColor:[UIColor redColor]];
                    }
                }
            }];
        }else if (moshiArray) {
            if ((editMode == YES) && (segmentController.selectedSegmentIndex == 0)) {
                PFObject* cellObject = [[adminSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                PFFile *pic = (PFFile*)[cellObject objectForKey:@"MoshiPicture"];
                [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        
                        UIImage *picture = [UIImage imageWithData:data];
                        
                        cell.imageView.image = picture;
                        
                        //to same-size cell pics (pics may be distorted with this method)
                        CGSize itemSize = CGSizeMake(50, 40);
                        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                        [cell.imageView.image drawInRect:imageRect];
                        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];
                        if ([[cellObject objectForKey:@"MoshiApproved"]  isEqual: @NO]) {
                            [cell.textLabel setHighlighted:YES];
                            [cell.textLabel setHighlightedTextColor:[UIColor redColor]];
                        }
                    }
                }];
            
        }else{
            PFObject* cellObject = [moshiArray objectAtIndex:indexPath.row];
            
            
            PFFile *pic = (PFFile*)[cellObject objectForKey:@"MoshiPicture"];
            [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    
                    UIImage *picture = [UIImage imageWithData:data];
                    
                    cell.imageView.image = picture;
                    
                    //to same-size cell pics (pics may be distorted with this method)
                    CGSize itemSize = CGSizeMake(50, 40);
                    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
                    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
                    [cell.imageView.image drawInRect:imageRect];
                    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    cell.textLabel.text = [cellObject objectForKey:@"MoshiName"];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [cellObject objectForKey:@"MoshiNumber"]];
                    if ([[cellObject objectForKey:@"MoshiApproved"]  isEqual: @NO]) {
                        [cell.textLabel setHighlighted:YES];
                        [cell.textLabel setHighlightedTextColor:[UIColor redColor]];
                    }
                }
            }];
        }
        }
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"viewMoshi"]) {
//       NSIndexPath *indexPath = nil;
        if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0)) {
            if (self.searchDisplayController.active) {
//                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                MoshiDetailsViewController *detailsVC = segue.destinationViewController;
                detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
            }else{
                MoshiDetailsViewController *detailsVC = segue.destinationViewController;
                detailsVC.detailInfo = [[sections objectAtIndex:_indexSection] objectAtIndex:_indexSelected];
            }
        }else{
            if (self.searchDisplayController.active) {
//                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                MoshiDetailsViewController *detailsVC = segue.destinationViewController;
                detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
            }else{
                MoshiDetailsViewController *detailsVC = segue.destinationViewController;
                detailsVC.detailInfo = [moshiArray objectAtIndex:_indexSelected];
        }
        
        
//        if (self.searchDisplayController.active) {
////           NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
//            MoshiDetailsViewController *detailsVC = segue.destinationViewController;
//            detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
//        }if ((editMode == NO) && (segmentController.selectedSegmentIndex == 0)) {
//            MoshiDetailsViewController *detailsVC = segue.destinationViewController;
//            detailsVC.detailInfo = [[sections objectAtIndex:_indexSection] objectAtIndex:_indexSelected];
//        } else {
//            MoshiDetailsViewController *detailsVC = segue.destinationViewController;
//            detailsVC.detailInfo = [moshiArray objectAtIndex:_indexSelected];
//        }
        }
    }
    if ([segue.identifier isEqualToString:@"addMoshi"]) {
        AddMoshiViewController *addVC = segue.destinationViewController;
        addVC.enterAdminDelegate = self;
        addVC.adminButtonVar = editMode;
    }
    if ([segue.identifier isEqualToString:@"toAdminVC"]) {
        //       NSIndexPath *indexPath = nil;
        if (segmentController.selectedSegmentIndex == 0) {
            if (self.searchDisplayController.active) {
                //                NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                AdminViewController *detailsVC = segue.destinationViewController;
                detailsVC.adminDelegate = self;
                detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
            }else{
                AdminViewController *detailsVC = segue.destinationViewController;
                detailsVC.adminDelegate = self;
                detailsVC.detailInfo = [[adminSections objectAtIndex:_indexSection] objectAtIndex:_indexSelected];
            }
        }else{
            if (self.searchDisplayController.active) {
                AdminViewController *detailsVC = segue.destinationViewController;
                detailsVC.adminDelegate = self;
                detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
            }else{
                AdminViewController *detailsVC = segue.destinationViewController;
                detailsVC.adminDelegate = self;
                detailsVC.detailInfo = [moshiArray objectAtIndex:_indexSelected];
            }
        }
    }

//    if ([segue.identifier isEqualToString:@"toAdminVC"]) {
////        NSIndexPath *indexPath = nil;
//        
//        if (self.searchDisplayController.active) {
////            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
//            AdminViewController *detailsVC = segue.destinationViewController;
//            detailsVC.adminDelegate = self;
//            detailsVC.detailInfo = [searchResults objectAtIndex:_indexSelected];
//        }else{
////            indexPath = [moshiTableView indexPathForSelectedRow];
//            AdminViewController *detailsVC = segue.destinationViewController;
//            detailsVC.adminDelegate = self;
////            detailsVC.detailInfo = [moshiArray objectAtIndex:_indexSelected];
//            detailsVC.detailInfo = [[adminSections objectAtIndex:_indexSection] objectAtIndex:_indexSelected];
//        }
//    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        _indexSelected = indexPath.row;
        _indexSection = indexPath.section;

        if (editMode == YES) {
            [self performSegueWithIdentifier:@"toAdminVC" sender:self];
        } else {
            [self performSegueWithIdentifier:@"viewMoshi" sender:self];
        }
    
}


@end
