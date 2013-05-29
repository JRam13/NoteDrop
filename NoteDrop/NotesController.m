//
//  NotesController.m
//  NoteDrop
//
//  Created by JRamos on 5/27/13.
//  Copyright (c) 2013 JRamos. All rights reserved.
//

#import "NotesController.h"
#import <dropbox/dropbox.h>
#import "ListNotesController.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import "AppDelegate.h"

@interface NotesController (){
    ListNotesController *lnc;
}

@property (nonatomic) DBFilesystem *filesystem;
@property (nonatomic) DBPath *root;
@property (nonatomic) NSMutableArray *contents;
@property (nonatomic) NSString *editContent;
@property (nonatomic) NSString *noteName;
@property (nonatomic) DBFile *file;

 

@end

@implementation NotesController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setFileSystem];
    
    lnc = [[ListNotesController alloc] init];
    
	// Do any additional setup after loading the view.
    //hide back button
    [self.navigationItem setHidesBackButton:YES];
    
    
    //make a keyboard toolbar "input accessory view"
    if(_keyboardToolbar == nil){
        _keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, 44)];
        
        UIBarButtonItem *camera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCamera target:self action:@selector(choosePhoto)];
        

        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(resignKeyboardCancel)];

        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(resignKeyboardSave)];
        
        [_keyboardToolbar setItems:[[NSArray alloc] initWithObjects:camera, space, cancel, done, nil] animated:YES];
        
        _textView.inputAccessoryView = _keyboardToolbar;
        
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    _editContent = lnc.content;
    if(lnc.noteName){
        _noteName = lnc.noteName;
    }
    _file = lnc.file;
    
    if(lnc.clearPhoto){
        self.photo.image = nil;
        lnc.clearPhoto = NO;

    }
    
    if(_file){
        self.title = _noteName;
        self.photo.image = [UIImage imageWithData:[_file readData:nil]];
        _textView.text = [_file readString:nil];
    }
    else if(_noteName){
        self.title = _noteName;
        _textView.text = _editContent;
        [self addFileToAccount];
    }
}

- (void)addFileToAccount
{
    
    
    DBPath *newPath = [[DBPath root] childPath:_noteName];
    
    DBFile *file = [lnc.filesystem createFile:newPath error:nil];
    [file writeString:@"" error:nil];

}

- (void) setFileSystem
{
//    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
//
//    //set filesystem
//    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
//    [DBFilesystem setSharedFilesystem:filesystem];
//    
//    _filesystem = filesystem;
//    _root = [DBPath root];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue");
    
    lnc = segue.destinationViewController;
    
}

-(void)reload
{
    NSLog(@"Size: %d", [self.contents count]);
}

- (void)resignKeyboardSave
{
    
    [_textView resignFirstResponder];
    
    if(!_noteName && !_contents){
        NSLog(@"Creating new note");
        DBPath *newPath = [[DBPath root] childPath:[self setDate]];
        DBFile *file = [lnc.filesystem createFile:newPath error:nil];
        [file writeString:_textView.text error:nil];
    }
    
    else if( self.photo.image ){
        
        DBPath *newPath = [[DBPath root] childPath:_noteName];
        NSLog(@"path: %@" , newPath.name);
        UIImage *composite = [self imageByCombiningImageViewWithTextView];
        NSData *imageData = UIImagePNGRepresentation(composite);
        if(!_file){
            DBPath *newPath = [[DBPath root] childPath:_noteName];
            DBFile *file = [lnc.filesystem openFile:newPath error:nil];
            [file writeData:imageData error:nil];
        }else{
            [_file writeData:imageData error:nil];
        }
        
    }
    else{
        
        DBPath *newPath = [[DBPath root] childPath:_noteName];
        NSLog(@"path: %@" , newPath.name);
        if(!_file){
            NSLog(@"Editing file");
            DBFile *file = [lnc.filesystem openFile:newPath error:nil];
            [file writeString:_textView.text error:nil];
        }else{
            [_file writeString:_textView.text error:nil];
        }
    }
    
    //create event if necessary
    if(self.textView.text.length > 6){
        [self addEvent];
    }
        
    
}

- (void) addEvent
{
    //trim whitespace at beginning
    NSString *noWhiteSpace = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //isolate "TODO" portion
    NSString *trimmedText = [noWhiteSpace substringToIndex:5];
    if( [trimmedText caseInsensitiveCompare:@"TODO:"] == NSOrderedSame ){

        //get and trim reminder text
        NSString *reminderText = [[noWhiteSpace substringFromIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSLog(@"ReminderText: %@", reminderText);

        
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = reminderText;
        
        event.startDate = [[NSDate alloc] init];
        event.endDate   = [[NSDate alloc] initWithTimeInterval:600 sinceDate:event.startDate];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        NSLog(@"Reminder Added: %@" , reminderText);
    }
}

- (void)resignKeyboardCancel
{
    [_textView resignFirstResponder];
    
}

-(NSString*)setDate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy-HH:mm:ss"];
    NSString *theDate = [format stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.txt", theDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**************************************************
The following code is inspired by Binkowski & Alex Silva
 ***************************************************/

-(void)choosePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
#if TARGET_IPHONE_SIMULATOR
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
    imagePickerController.editing = YES;
    imagePickerController.delegate = (id)self;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


#pragma mark - UIImagePickerController delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // Resize the image from the camera
	UIImage *scaledImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(self.photo.frame.size.width, self.photo.frame.size.height) interpolationQuality:kCGInterpolationHigh];
    // Crop the image to a square
    UIImage *croppedImage = [scaledImage croppedImage:CGRectMake((scaledImage.size.width - self.photo.frame.size.width)/2, (scaledImage.size.height - self.photo.frame.size.height)/2, self.photo.frame.size.width, self.photo.frame.size.height)];
    // Show the photo on the screen
    self.photo.image = croppedImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage*)imageByCombiningImageViewWithTextView
{
    
    UIGraphicsBeginImageContextWithOptions(self.photo.image.size, NO, 0.0); //retina res
    [self.photo.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.textView.text];
    NSInteger _stringLength = self.textView.text.length;
    [str addAttribute:NSBackgroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, _stringLength)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0] range:NSMakeRange(0, _stringLength)];
    
    self.textView.attributedText = str;
    [self.textView setNeedsDisplay];
    
    [self.textView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //add metadata
    NSMutableDictionary *tiffMetadata = [[NSMutableDictionary alloc] init];
    [tiffMetadata setObject:@"This is metadata!" forKey:_noteName];
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc] init];
    [metadata setObject:tiffMetadata forKey:_noteName];
    
    NSLog(@"Metadata added for: %@", _noteName);
    
    return image;
}

@end
