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

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    self.title = _nameIncoming;
//    avatar.image = _imageIncoming;
//
//    NSLog(@"%@", _seriesIncoming);
//    number.text = [NSString stringWithFormat:@"Number:  %@", _numberIncoming];
//    series.text = [NSString stringWithFormat:@"Series:  %@", _seriesIncoming];
//    species.text = [NSString stringWithFormat:@"Species:  %@", _speciesIncoming];
//    type.text = [NSString stringWithFormat:@"Type:  %@", _typeIncoming];
//    location.text = [NSString stringWithFormat:@"Location:  %@", _locationIncoming];
//    rarity.text = [NSString stringWithFormat:@"Rarity:  %@", _rarityIncoming];
//    description.text = _descriptionIncoming;
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self doParseQuery];
}

-(void) doParseQuery{
    PFQuery *query = [PFQuery queryWithClassName:@"MoshiData"];
    [query getObjectInBackgroundWithId:detailInfo.objectId block:^(PFObject *object, NSError *error) {
        
    //    [query whereKey:@"MoshiName" equalTo:[detailInfo objectForKey:@"MoshiName"]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
//            for (PFObject *object in objects) {
    
                PFFile* pic =[object objectForKey:@"MoshiPicture"];
                [pic getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        avatar.image = [UIImage imageWithData:data];
                    }
                }];
                
                self.title = object[@"MoshiName"];
                number.text = [NSString stringWithFormat:@"Number:  %@", object[@"MoshiNumber"]];
                series.text = [NSString stringWithFormat:@"Series:  %@", object[@"MoshiSeries"]];
                species.text = [NSString stringWithFormat:@"Species:  %@", object[@"MoshiSpecies"]];
                type.text = [NSString stringWithFormat:@"Type:  %@", object[@"MoshiType"]];
                location.text = [NSString stringWithFormat:@"Location:  %@", object[@"MoshiLocation"]];
                rarity.text = [NSString stringWithFormat:@"Rarity:  %@", object[@"MoshiRare"]];
                description.text = object[@"MoshiDescription"];
                
//            }
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            NSLog(@"Error: %@", errorString);
        }
    }];
}

@end
