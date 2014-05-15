//
//  MoshiDetailsViewController.m
//  MoshiDex
//
//  Created by Jeremy Herrero on 12/29/13.
//  Copyright (c) 2013 Grants International Inc. All rights reserved.
//

#import "MoshiDetailsViewController.h"

@interface MoshiDetailsViewController () {
    
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UILabel *number;
    __weak IBOutlet UILabel *series;
    __weak IBOutlet UILabel *species;
    __weak IBOutlet UILabel *type;
    __weak IBOutlet UILabel *location;
    __weak IBOutlet UILabel *rarity;
    __weak IBOutlet UITextView *description;
}

@end

@implementation MoshiDetailsViewController

@synthesize detailInfo;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getPicDoText];
}

-(void) getPicDoText{
//    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
//    [query getObjectInBackgroundWithId:detailInfo.objectId block:^(PFObject *object, NSError *error) {
//        
//    //    [query whereKey:@"MoshiName" equalTo:[detailInfo objectForKey:@"MoshiName"]];
////    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
////            for (PFObject *object in objects) {
//    
                PFFile* pic =[detailInfo objectForKey:@"MoshiPicture"];
                [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        avatar.image = [UIImage imageWithData:data];
                    }else {
                        NSString *errorString = [[error userInfo] objectForKey:@"error"];
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                    }
                }];
    
                self.title = detailInfo[@"MoshiName"];
                number.text = [NSString stringWithFormat:@"Number:  %@", detailInfo[@"MoshiNumber"]];
                series.text = [NSString stringWithFormat:@"Series:  %@", detailInfo[@"MoshiSeries"]];
                species.text = [NSString stringWithFormat:@"Species:  %@", detailInfo[@"MoshiSpecies"]];
                type.text = [NSString stringWithFormat:@"Type:  %@", detailInfo[@"MoshiType"]];
                location.text = [NSString stringWithFormat:@"Location:  %@", detailInfo[@"MoshiLocation"]];
                rarity.text = [NSString stringWithFormat:@"Rarity:  %@", detailInfo[@"MoshiRare"]];
                description.text = detailInfo[@"MoshiDescription"];

}

@end
