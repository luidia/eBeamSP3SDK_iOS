//
//  SelectBoardSizeViewController.m
//  PenTestExtension
//
//  Created by Luidia on 2018. 07. 24..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "SelectBoardSizeViewController.h"
#import "Common.h"
#import "PNFPenLibExtension.h"
#import "FFCircularProgressView.h"

@interface SelectBoardSizeViewController () <UITableViewDataSource, UITableViewDelegate>
{
    FFCircularProgressView* indicator;
    
    IBOutlet UITableView *mTableView;
    NSMutableArray* tableViewItems;
    
    int selectBoardIdx;
    NSString* selectBoardName;
}
@property (retain) NSMutableArray* tableViewItems;
@property (readwrite) int selectBoardIdx;
@property (readwrite) NSString* selectBoardName;
@end

@implementation SelectBoardSizeViewController
@synthesize delegate;
@synthesize tableViewItems;
@synthesize selectBoardIdx;
@synthesize selectBoardName;

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
    
    if(self.selectBoardName){
        [self.selectBoardName release];
        self.selectBoardName = nil;
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
    
    [self.tableViewItems addObject:@"Left max"];
    [self.tableViewItems addObject:@"Right max"];
    [self.tableViewItems addObject:@"Top max"];
    [self.tableViewItems addObject:@"Bottom max"];
    [self.tableViewItems addObject:@"Both max"];
    [self.tableViewItems addObject:@"Custom setting board size"];
    
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
        
        NSString *msg = @"Board size changed to [STR]";
        msg = [msg stringByReplacingOccurrencesOfString:@"[STR]" withString:self.selectBoardName];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:msg
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (delegate) {
                if ([self.delegate respondsToSelector:@selector(selectDefaultBoardSize)])
                    [delegate selectDefaultBoardSize];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([szS isEqualToString:@"CALIBRATION_SAVE_FAIL"] || [szS isEqualToString:@"DI_SEND_ERR"]) {
        HIDE_INDICATOR()
        
        [mTableView reloadData];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"change Board size fail"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (delegate) {
                if ([self.delegate respondsToSelector:@selector(closeSelectBoardSizeViewController)])
                    [delegate closeSelectBoardSizeViewController];
            }
            [self dismissViewControllerAnimated:YES completion:^{}];
        }];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) checkCalibration {
    self.selectBoardIdx = 5;
    CGPoint calResultPoint[4];
    
    for(int i=0;i<5;i++){
        if(i == 0){
            if(m_PenController.StationPosition != DIRECTION_LEFT){
                continue;
            }
            FT_8X5()
        }else if(i == 1){
            if(m_PenController.StationPosition != DIRECTION_RIGHT){
                continue;
            }
            FT_8X5()
        }else if(i == 2){
            if(m_PenController.StationPosition != DIRECTION_TOP){
                continue;
            }
            FT_4X6()
        }else if(i == 3){
            if(m_PenController.StationPosition != DIRECTION_BOTTOM){
                continue;
            }
            FT_4X6_BOTTOM()
        }else if(i == 4){
            if(m_PenController.StationPosition != DIRECTION_BOTH){
                continue;
            }
            FT_8X5()
        }
        
        if (CGPointEqualToPoint(m_PenController.deviceCalibrationData_0, calResultPoint[0]) &&
            CGPointEqualToPoint(m_PenController.deviceCalibrationData_1, calResultPoint[1]) &&
            CGPointEqualToPoint(m_PenController.deviceCalibrationData_2, calResultPoint[2]) &&
            CGPointEqualToPoint(m_PenController.deviceCalibrationData_3, calResultPoint[3])) {
            self.selectBoardIdx = i;
            break;
        }
    }
}

- (IBAction)closeClicked:(id)sender {
    if (delegate)
    {
        if ([self.delegate respondsToSelector:@selector(closeSelectBoardSizeViewController)])
            [delegate closeSelectBoardSizeViewController];
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
    
    if(indexPath.row == self.selectBoardIdx){
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
        //Custom Board
        self.selectBoardIdx = 5;
        
        if (delegate)
        {
            if ([self.delegate respondsToSelector:@selector(selectCustomBoardSize)])
                [delegate selectCustomBoardSize];
        }
        [self dismissViewControllerAnimated:YES completion:^{}];
    }else if(indexPath.row == 0){
        //Left max Board
        self.selectBoardIdx = 0;
        
        FT_8X5()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_LEFT CalibPoint:calResultPoint];
        
        self.selectBoardName = @"left max";
        SHOW_INDICATOR(self.view)
    }
    else if(indexPath.row == 1){
        //Right max Board
        self.selectBoardIdx = 1;
        
        FT_8X5()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_RIGHT CalibPoint:calResultPoint];
        
        self.selectBoardName = @"right max";
        SHOW_INDICATOR(self.view)
    }else if(indexPath.row == 2){
        //Top max Board
        self.selectBoardIdx = 2;
        
        FT_4X6()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_TOP CalibPoint:calResultPoint];
        
        self.selectBoardName = @"top max";
        SHOW_INDICATOR(self.view)
    }else if(indexPath.row == 3){
        //Bottom max Board
        self.selectBoardIdx = 3;
        
        FT_4X6_BOTTOM()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_BOTTOM CalibPoint:calResultPoint];
        
        self.selectBoardName = @"bottom max";
        SHOW_INDICATOR(self.view)
    }else if(indexPath.row == 4){
        //Both max Board
        self.selectBoardIdx = 4;
        
        FT_8X5()
        [m_PenController sendCalibrationDataToDevice:DIRECTION_BOTH CalibPoint:calResultPoint];
        
        self.selectBoardName = @"both max";
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
