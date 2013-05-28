//
//  NotesController.h
//  NoteDrop
//
//  Created by JRamos on 5/27/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListNotesController.h"

@interface NotesController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic) UIToolbar *keyboardToolbar;

//- (id)initWithFilesystem:(DBFilesystem *)filesystem root:(DBPath *)root;

@end
