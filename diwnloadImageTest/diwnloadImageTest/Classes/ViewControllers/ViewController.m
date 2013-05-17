//
//  ViewController.m
//  diwnloadImageTest
//
//  Created by abdus on 4/29/13.
//  Copyright (c) 2013 abdus.me. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (retain) NSMutableArray *imagesArray;
@end

@implementation ViewController
@synthesize hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imagesArray = [[NSMutableArray alloc] init];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark initiatingDownloadingRequest
-(void)initiateDownloading
{
    [self showWaitingView];
    NSArray *links = [NSArray arrayWithObjects:
                      @"http://www.theparisreview.org/blog/wp-content/uploads/2013/02/TomCruise_071720.jpg",
                      @"http://media1.santabanta.com/full1/Global%20Celebrities(M)/Tom%20Cruise/tom-cruise-19a.jpg",
                      @"http://i.huffpost.com/gen/640420/thumbs/o-TOM-CRUISE-570.jpg",
                      @"http://2.bp.blogspot.com/-d7zP0iihn8Y/UV3dlS6afRI/AAAAAAAAU0M/yrdDUrAOT0A/s1600/Tom-Cruise--620_1622688a.jpg",
                      @"http://img.thesun.co.uk/multimedia/archive/01646/SNN0116TOM---_1646312a.jpg",
                      @"http://www.theparisreview.org/blog/wp-content/uploads/2013/02/TomCruise_071720.jpg",
                      @"http://media1.santabanta.com/full1/Global%20Celebrities(M)/Tom%20Cruise/tom-cruise-19a.jpg",
                      @"http://i.huffpost.com/gen/640420/thumbs/o-TOM-CRUISE-570.jpg",
                      @"http://2.bp.blogspot.com/-d7zP0iihn8Y/UV3dlS6afRI/AAAAAAAAU0M/yrdDUrAOT0A/s1600/Tom-Cruise--620_1622688a.jpg",
                      @"http://img.thesun.co.uk/multimedia/archive/01646/SNN0116TOM---_1646312a.jpg",
                      nil];
    
    [self performSelectorInBackground:@selector(downloadFilesfromCDN:) withObject:links];
    [self performSelector:@selector(timeout) withObject:nil afterDelay:60*5];
}
#pragma mark
#pragma mark Parse Methods
-(void)saveObjectOnServer
{
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"abdus" forKey:@"foo"];
    [testObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
             NSLog(@"The gameScore saved successfully.");
        }
        else
        {
            NSLog(@"There was an error saving the gameScore.");
        }
    }];
}

-(void)retrieveObject
{
   // 
    PFQuery *query = [PFQuery queryWithClassName:@"TestObject"];
    PFObject *obj = [query getObjectWithId:@"6z6x2aAvJU"];
    NSString *value = [obj objectForKey:@"foo"];
    NSLog(@"Data recieved %@",value);

}

#pragma mark
#pragma mark IBAction
- (IBAction)buttonClicked:(id)sender
{
    for (int i=0; i<[self.imagesArray count]; i++)
    {
        [self removeImage:[self.imagesArray objectAtIndex:i]];
    }
    NSLog(@"Deleted");
}

- (IBAction)download:(id)sender
{
    [self initiateDownloading];
}

- (IBAction)saveButtonClicked:(id)sender
{
    [self saveObjectOnServer];
}

- (IBAction)retrieveButtonClicked:(id)sender
{
    [self retrieveObject];
}

#pragma mark
#pragma mark Delete from DD
- (void)removeImage:(NSString*)fileName
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%@", fileName]];
    
    [fileManager removeItemAtPath: fullPath error:nil];
    
}

#pragma mark
#pragma mark Downloading Utility
- (void) downloadFilesfromCDN :(NSArray*)filenames
{
    
    NSMutableArray *mfiles = [[NSMutableArray alloc] init];
    
    BOOL error = FALSE;
    int i=0;
    for (NSString* filename in filenames)
    {
        NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *fileName = [NSString stringWithFormat:@"image%d.png",i];
        NSString *path = [[searchPath objectAtIndex:0]  stringByAppendingString:[NSString stringWithFormat:@"/%@",fileName]];
        [self.imagesArray addObject:fileName];
        i++;
        id file = [self downloadFilefromSingleFile:filename];
        if ([file isKindOfClass:[NSData class]])
        {
            if ([(NSData*)file writeToFile:path atomically:YES] != FALSE)
            {
                [mfiles addObject:path];
            } else
            {
                NSLog(@"writing file failed");
            }
        }
        else
        {
            NSLog(@"Download file Failed");
        }
    }
    
    if (error)
    {
        NSLog(@"ERROR");
    }
    else
    {
           NSLog(@"array items %@ ",[mfiles description]);
        [self hideWaitingView];
    }
}


- (id) downloadFilefromSingleFile :(NSString*)filename
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:filename]];
    [request setHTTPMethod:@"GET"];
    
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    if (err != nil)
    {
        return FALSE;
    }
    
    return data;
    
}

//- (BOOL) downloadFilefromServerFromArray :(NSString*)filename
//{
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://example.com/getlinks.php"]]];
//    [request setHTTPMethod:@"GET"];
//    
//    NSError *err = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
//    
//    if (err != nil)
//    {
//        NSLog(@"Download Error");
//        return FALSE;
//    } // Download error
//    
//    NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    NSString *path = [[searchPath objectAtIndex:0]  stringByAppendingString:[NSString stringWithFormat:@"/%@",filename]];
//    
//    if ([data writeToFile:path atomically:YES] != FALSE)
//    {
//        return TRUE;
//    }
//    else
//    {
//        return FALSE; // Error
//    }
//}



#pragma mark
#pragma mark Waiting View
-(void)showWaitingView
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = NSLocalizedString(@"downloading ...", @"");
}
- (void)hideWaitingView
{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.hud = nil;
}
- (void)timeout
{
    
    self.hud.labelText = NSLocalizedString(@"Timeout", @"");
    self.hud.detailsLabelText = NSLocalizedString(@"Please try again later.", @"");
    self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	self.hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:3.0];
    
}
@end
