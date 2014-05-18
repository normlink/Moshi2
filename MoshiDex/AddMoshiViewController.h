//
//  AddMoshiViewController.h
//  MoshiDex
//
//  Created by Jeremy Herrero on 1/3/14.
//  Copyright (c) 2014 Grants International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddMoshiDelegate;

@interface AddMoshiViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) id <AddMoshiDelegate> enterAdminDelegate;
@property (nonatomic) BOOL adminButtonVar;

@end

@protocol AddMoshiDelegate <NSObject>

-(void)changeAdminVar:(BOOL)var;
-(void)changeSubmitVar:(BOOL)var;


@end