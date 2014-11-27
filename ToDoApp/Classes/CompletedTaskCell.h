//
//  CompletedTaskCell.h
//  ToDoApp
//
//  Created by Jakub Truhlar on 24.11.14.
//  Copyright (c) 2014 Jakub Truhlar. All rights reserved.
//

#import "SWTableViewCell.h"

@interface CompletedTaskCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end
