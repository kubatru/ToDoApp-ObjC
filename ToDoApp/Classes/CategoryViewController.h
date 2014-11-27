//
//  CategoryViewController.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 20.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

{
    NSArray *colorArray;
    NSMutableArray *categoryArray;
    NSString *colorSelected;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
