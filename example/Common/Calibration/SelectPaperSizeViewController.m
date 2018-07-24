//
//  SelectPaperSizeViewController.m
//  PenTestExtension
//
//  Created by Luidia on 2018. 07. 24..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "SelectPaperSizeViewController.h"
#import "Common.h"
#import "PNFPenLibExtension.h"
#import "FFCircularProgressView.h"

@interface SelectPaperSizeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    FFCircularProgressView* indicator;
    
    IBOutlet UITableView *mTableView;
    NSMutableArray* tableViewItems;
    
    int selectPaperIdx;
    NSString* selectPaperName;
}
@property (retain) NSMutableArray* tableViewItems;
@property (readwrite) int selectPaperIdx;
@property (readwrite) NSString* selectPaperName;
@end

@implementation SelectPaperSizeViewController
@synthesize delegate;
@synthesize tableViewItems;
@synthesize selectPaperIdx;
@synthesize selectPaperName;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PNF_MSG" object:nil];
    
    if(self.tableViewItems){
        [self.tableViewItems removeAllObjects];
        self.tableViewItems = nil;
    }
    
    if(mTableView){
        [mTableView release];
        mTableView = nil;
    }
    
    if(self.selectPaperName){
        [self.selectPaperName release];
        self.selectPaperName = nil;
    }
    
    if (indicator) {
        [indicator stopSpinProgressBackgroundLayer];
        [indicator removeFromSuperview];
        [indicator release];
        indicator = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    self.tableViewItems = [[[NSMutableArray alloc] init] autorelease];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PenCallBackFunc:) name:@"PNF_MSG" object:nil];
    
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    if ([languageCode isEqualToString:@"en"] || [languageCode isEqualToString:@"ca"]) {
        [self.tableViewItems addObject:@"Letter (8.5 x 11 in)"];
        [self.tableViewItems addObject:@"A4 (8.3 x 11.7 in)"];
        [self.tableViewItems addObject:@"A5 (5.8 x 8.3 in)"];
        [self.tableViewItems addObject:@"B5 (6.9 x 9.8 in)"];
        [self.tableViewItems addObject:@"B6 (4.9 x 6.9 in)"];
    }
    else {
        [self.tableViewItems addObject:@"Letter (216 x 279 mm)"];
        [self.tableViewItems addObject:@"A4 (210 x 297 mm)"];
        [self.tableViewItems addObject:@"A5 (148 x 210 mm)"];
        [self.tableViewItems addObject:@"B5 (176 x 250 mm)"];
        [self.tableViewItems addObject:@"B6 (125 x 176 mm)"];
    }
    
    [self.tableViewItems addObject:@"Custom setting paper size"];

    [self checkCalibration];
    
    mTableView.dataSource = self;
    mTableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) SetPenController:(PNFPenLibExtension *) pController {
    m_PenController = pController;
}

//NSNotificationCenter "PNF_LOG_MSG"
- (void) FreeLogMsg:(NSNotification *) note {
    NSString * szS = (NSString *) [note object];
    NSLog(@"FreeLogMsg szS==>%@", szS);
    if ([szS compare:@"FAIL_LISTENING"] == 0 ) {
        
    }
    else if ([szS isEqualToString:@"CONNECTED"]) {
        
    }
    else if ([szS isEqualToString:@"INVALID_PROTOCOL"]) {
        
    }
    else if ([szS isEqualToString:@"SESSION_CLOSED"]) {
        HIDE_INDICATOR()
        
        [self closeClicked:nil];
    }
    else if ([szS isEqualToString:@"PEN_RMD_ERROR"]) {
        
    }
    else if ([szS isEqualToString:@"FIRST_DATA_RECV"]) {
    }
}

//NSNotificationCenter "PNF_MSG"
-(void) PenCallBackFunc:(NSNotification *)call {
    NSString * szS = (NSString *) [call object];
    NSLog(@"PenCallBackFunc szS==>[%@]", szS);
    
    if ([szS isEqualToString:@"CALIBRATION_SAVE_OK"]) {
        HIDE_INDICATOR()
        
        [mTableView reloadData];
        
        NSString *msg = @"Paper size changed to [STR]";
        msg = [msg stringByReplacingOccurrencesOfString:@"[STR]" withString:self.selectPaperName];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (delegate) {
                if ([self.delegate respondsToSelector:@selector(selectDefaultPaperSize)])
                    [delegate selectDefaultPaperSize];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([szS isEqualToString:@"CALIBRATION_SAVE_FAIL"] || [szS isEqualToString:@"DI_SEND_ERR"]) {
        HIDE_INDICATOR()
        
        [mTableView reloadData];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"change Paper size fail"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (delegate) {
                if ([self.delegate respondsToSelector:@selector(closeSelectPaperSizeViewController)])
                    [delegate closeSelectPaperSizeViewController];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) checkCalibration {
    self.selectPaperIdx = 5;
    CGPoint calResultPoint[4];
    for(int i=0;i<5;i++){
        if(i == 0){
            LETTER()
        }else if(i == 1){
            A4()
        }else if(i == 2){
            A5()
        }else if(i == 3){
            B5()
        }else if(i == 4){
            B6()
        }
        
        if (CGPointEqualToPoint(m_PenController.deviceCalibrationData_0, calResultPoint[0]) &&
                    CGPointEqualToPoint(m_PenController.deviceCalibrationData_1, calResultPoint[1]) &&
                    CGPointEqualToPoint(m_PenController.deviceCalibrationData_2, calResultPoint[2]) &&
                    CGPointEqualToPoint(m_PenController.deviceCalibrationData_3, calResultPoint[3])) {
            self.selectPaperIdx = i;
            break;
        }
    }
}

- (IBAction)closeClicked:(id)sender {
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeSelectPaperSizeViewController)])
            [delegate closeSelectPaperSizeViewController];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", (int)indexPath.section, (int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(indexPath.row == self.selectPaperIdx){
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"select_check.png" ]];
        
        cell.textLabel.textColor = [UIColor colorWithRed:253./255. green:176./255. blue:42./255. alpha:1.];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    }else{
        cell.accessoryView = nil;
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    }
    
    cell.textLabel.text = [self.tableViewItems objectAtIndex:indexPath.row];

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CGPoint calResultPoint[4];
    
    if (indexPath.row == 5) {
        //Custom Paper
        self.selectPaperIdx = 5;
        
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(selectCustomPaperSize)])
                [delegate selectCustomPaperSize];
        }
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    else if(indexPath.row == 0){
        //Letter Paper
        self.selectPaperIdx = 0;

        LETTER()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectPaperName = @"Letter";
        SHOW_INDICATOR(self.view)
    }
    else if(indexPath.row == 1){
        //A4 Paper
        self.selectPaperIdx = 1;

        A4()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectPaperName = @"A4";
        SHOW_INDICATOR(self.view)
    }
    else if(indexPath.row == 2){
        //A5 Paper
        self.selectPaperIdx = 2;

        A5()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectPaperName = @"A5";
        SHOW_INDICATOR(self.view)
    }
    else if(indexPath.row == 3){
        //B5 Paper
        self.selectPaperIdx = 3;

        B5()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectPaperName = @"B5";
        SHOW_INDICATOR(self.view)
    }
    else if(indexPath.row == 4){
        //B6 Paper
        self.selectPaperIdx = 4;

        B6()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectPaperName = @"B6";
        SHOW_INDICATOR(self.view)
    }
}

-(BOOL) shouldAutoRotate {
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown;
}
@end
