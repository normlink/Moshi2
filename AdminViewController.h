//
//  AdminViewController.h
//  MoshiDex
//
//  Created by Yaniv Kerem on 5/5/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol AdminDelegate;

@interface AdminViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) id <AdminDelegate> adminDelegate;
@property (nonatomic) BOOL adminReloadVar;

@property (strong, nonatomic) PFObject * detailInfo;

@end

@protocol AdminDelegate <NSObject>

-(void)adminReload:(BOOL)var;


@end

