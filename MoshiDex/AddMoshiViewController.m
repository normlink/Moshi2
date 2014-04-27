//
//  AddMoshiViewController.m
//  MoshiDex
//
//  Created by Jeremy Herrero on 1/3/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "AddMoshiViewController.h"

@interface AddMoshiViewController () {
    UIImagePickerController *myPicker;
}

- (IBAction)submitMoshi:(id)sender;
- (IBAction)selectPhoto:(id)sender;

@end

@implementation AddMoshiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    myPicker = [[UIImagePickerController alloc]init];
    myPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    myPicker.allowsEditing = YES;
    myPicker.delegate = self;
    // now we present the picker
}

- (IBAction)submitMoshi:(id)sender {
    PFObject *object = [PFObject objectWithClassName:@"MoshiData"];
    object[@"MoshiApproved"] = @NO;
    object[@"MoshiName"] = @"Test";
    object[@"MoshiNumber"] =@2;
    object[@"MoshiSeries"] = @4;
    object[@"MoshiSpecies"] = @"ek";
//    object[@"MoshiPicture"] = [UIImage imageNamed:@"face.png"];
    object[@"MoshiType"] = @"test";
    object[@"MoshiLocation"] = @"test";
    object[@"MoshiRare"] = @"test";
    object[@"MoshiDescription"] = @"test";
    //    gameScore[@"score"] = @1337;
    //    gameScore[@"playerName"] = @"Sean Plott";
    //    gameScore[@"cheatMode"] = @NO;
    //    [gameScore saveEventually];
//    [object saveInBackground];
}

- (IBAction)selectPhoto:(id)sender {
    [self presentViewController:myPicker animated:YES completion:nil];
}

@end
