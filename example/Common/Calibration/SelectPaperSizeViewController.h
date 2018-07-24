//
//  SelectPaperSizeViewController.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 07. 24..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNFPenLibExtension;

@protocol SelectPaperSizeViewControllerDelegate
-(void) closeSelectPaperSizeViewController;
-(void) selectDefaultPaperSize;
-(void) selectCustomPaperSize;
@end

@interface SelectPaperSizeViewController : UIViewController
{
    PNFPenLibExtension *m_PenController;
}
@property (nonatomic, assign) id delegate;

-(void) SetPenController:(PNFPenLibExtension *) pController;
@end
