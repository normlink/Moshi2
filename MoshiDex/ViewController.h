//
//  ViewController.h
//  MoshiDex
//
//  Created by Jeremy Herrero on 12/26/13.
//  Copyright (c) 2013 Grants International Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMoshiViewController.h"
#include "AdminViewController.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,AddMoshiDelegate,AdminDelegate>


@property (nonatomic) NSInteger indexSelected;

@end
