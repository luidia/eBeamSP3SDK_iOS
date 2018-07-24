//
//  Common.h
//  PenTest
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#ifndef PenTest_Common_h
#define PenTest_Common_h

#define SHOW_INDICATOR(VIEW)\
if (indicator) {\
    [indicator stopSpinProgressBackgroundLayer];\
    [indicator removeFromSuperview];\
    [indicator release];\
    indicator = nil;\
}\
if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {\
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];\
}\
[[UIApplication sharedApplication] beginIgnoringInteractionEvents];\
if (indicator == nil) {\
    indicator = [[FFCircularProgressView alloc] initWithFrame:CGRectMake(40, 40, 40, 40)];\
    [indicator setCenter:CGPointMake(VIEW.center.x, VIEW.bounds.size.height/2)];\
    [VIEW addSubview:indicator];\
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|\
    UIViewAutoresizingFlexibleLeftMargin|\
    UIViewAutoresizingFlexibleRightMargin|\
    UIViewAutoresizingFlexibleTopMargin];\
    [VIEW bringSubviewToFront:indicator];\
    [indicator startSpinProgressBackgroundLayer];\
}

#define HIDE_INDICATOR()\
if (indicator) {\
    [indicator stopSpinProgressBackgroundLayer];\
    [indicator removeFromSuperview];\
    [indicator release];\
    indicator = nil;\
}\
if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {\
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];\
}

// TODO:: eBeam Smartpen
#define LETTER()\
calResultPoint[0] = CGPointMake(1737, 541);\
calResultPoint[1] = CGPointMake(1737, 4818);\
calResultPoint[2] = CGPointMake(5445, 4818);\
calResultPoint[3] = CGPointMake(5445, 541);\

#define A4()\
calResultPoint[0] = CGPointMake(1768, 563);\
calResultPoint[1] = CGPointMake(1768, 5160);\
calResultPoint[2] = CGPointMake(5392, 5160);\
calResultPoint[3] = CGPointMake(5392, 563);\

#define A5()\
calResultPoint[0] = CGPointMake(2341, 542);\
calResultPoint[1] = CGPointMake(2341, 3631);\
calResultPoint[2] = CGPointMake(4865, 3631);\
calResultPoint[3] = CGPointMake(4865, 542);\

#define B5()\
calResultPoint[0] = CGPointMake(2027, 561);\
calResultPoint[1] = CGPointMake(2027, 4462);\
calResultPoint[2] = CGPointMake(5183, 4462);\
calResultPoint[3] = CGPointMake(5183, 561);\

#define B6()\
calResultPoint[0] = CGPointMake(2500, 544);\
calResultPoint[1] = CGPointMake(2500, 3154);\
calResultPoint[2] = CGPointMake(4704, 3154);\
calResultPoint[3] = CGPointMake(4704, 544);\

// TODO:: eBeam Smartmarker
#define FT_8X5()\
calResultPoint[0] = CGPointMake(1450, 44100);\
calResultPoint[1] = CGPointMake(1450, 56150);\
calResultPoint[2] = CGPointMake(20620, 56150);\
calResultPoint[3] = CGPointMake(20620, 44100);\

#define FT_4X6()\
calResultPoint[0] = CGPointMake(11590, 1450);\
calResultPoint[1] = CGPointMake(11590, 15827);\
calResultPoint[2] = CGPointMake(21230, 15827);\
calResultPoint[3] = CGPointMake(21230, 1450);\

#define FT_4X6_BOTTOM()\
calResultPoint[0] = CGPointMake(45305, 50708);\
calResultPoint[1] = CGPointMake(45305, 65085);\
calResultPoint[2] = CGPointMake(54945, 65085);\
calResultPoint[3] = CGPointMake(54945, 50708);\

#endif
