//
//  AdminViewController.h
//  MoshiDex
//
//  Created by Yaniv Kerem on 5/5/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AdminViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) PFObject * detailInfo;

@end
