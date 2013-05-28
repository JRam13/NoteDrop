//
//  ListNotesController.h
//  NoteDrop
//
//  Created by JRamos on 5/28/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListNotesController : UITableViewController

@property (nonatomic) NSString *content;
@property (nonatomic) NSString *noteName;
@property (nonatomic) DBFilesystem *filesystem;
@property (nonatomic) DBFile *file;




- (IBAction)addNote:(UIBarButtonItem *)sender;





@end
