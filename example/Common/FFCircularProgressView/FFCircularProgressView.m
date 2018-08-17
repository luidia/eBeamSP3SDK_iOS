//
//  FFCircularProgressBar.m
//  PenTestExtension
//
//  Created by Luidia on 2018. 05. 04..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "FFCircularProgressView.h"

@interface FFCircularProgressView()
@property (nonatomic, retain) CAShapeLayer *progressBackgroundLayer;
@property (nonatomic, retain) CAShapeLayer *progressLayer;
@property (nonatomic, retain) CAShapeLayer *iconLayer;
@property (nonatomic, retain) UILabel* percentageLabel;

@property (nonatomic, assign) BOOL isSpinning;
@end

@implementation FFCircularProgressView
@synthesize drawArrawToStop;
#define kArrowSizeRatio .12
#define kStopSizeRatio  .3
#define kTickWidthRatio .3

-(void) dealloc {
    [tintColor release];
    self.progressBackgroundLayer = nil;
    self.progressLayer = nil;
    self.iconLayer = nil;
    [self.percentageLabel removeFromSuperview];
    self.percentageLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.drawArrawToStop = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _lineWidth = 2.;//fmaxf(self.frame.size.width * 0.025, 1.f);
        tintColor = [[UIColor colorWithRed:253./255. green:176./255.0 blue:42./255. alpha:1.0] retain];;//[[UIColor colorWithRed:0 green:122/255.0 blue:1.0 alpha:1.0] retain];
        
        self.progressBackgroundLayer = [CAShapeLayer layer];
        _progressBackgroundLayer.strokeColor = tintColor.CGColor;
        _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
        _progressBackgroundLayer.lineCap = kCALineCapRound;
        _progressBackgroundLayer.lineWidth = _lineWidth;
        [self.layer addSublayer:_progressBackgroundLayer];

        self.progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineCap = kCALineCapSquare;
        _progressLayer.lineWidth = _lineWidth * 2.0;
        [self.layer addSublayer:_progressLayer];

        self.iconLayer = [CAShapeLayer layer];
        _iconLayer.strokeColor = tintColor.CGColor;
        _iconLayer.fillColor = nil;
        _iconLayer.lineCap = kCALineCapButt;
        _iconLayer.lineWidth = _lineWidth;
        _iconLayer.fillRule = kCAFillRuleNonZero;
        [self.layer addSublayer:_iconLayer];
        
        self.percentageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        [self.percentageLabel setTextColor:tintColor];
        [self.percentageLabel setTextAlignment:NSTextAlignmentCenter];
        [self.percentageLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [self addSubview:self.percentageLabel];
    }
    return self;
}

- (void)setTintColor:(UIColor *)tColor
{
    [tintColor release];
    tintColor = [[UIColor colorWithCGColor:tColor.CGColor] retain];
    _progressBackgroundLayer.strokeColor = tintColor.CGColor;
    _progressLayer.strokeColor = tintColor.CGColor;
    _iconLayer.strokeColor = tintColor.CGColor;
}

- (void)drawRect:(CGRect)rect
{
    // Make sure the layers cover the whole view
    _progressBackgroundLayer.frame = self.bounds;
    _progressLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;

    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
//    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;

    // Draw background
    [self drawBackgroundCircle:_isSpinning];

    // Draw progress
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    // CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    CGFloat endAngle = (self.progress * 2 * (float)M_PI) + startAngle;
    UIBezierPath *processPath = [UIBezierPath bezierPath];
    processPath.lineCapStyle = kCGLineCapButt;
    processPath.lineWidth = _lineWidth;

    CGFloat radius = (self.bounds.size.width - _lineWidth*3) / 2.0;
    [processPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    [_progressLayer setPath:processPath.CGPath];
    
    if ([self progress] == 1.0) {
        [self drawTick];
    } else if (([self progress] > 0) && [self progress] < 1.0) {
        [self drawStop];
    } else {
        [self drawArrow];
    }
}

#pragma mark -
#pragma mark Setters

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = fmaxf(lineWidth, 1.f);
    
    _progressBackgroundLayer.lineWidth = _lineWidth;
    _progressLayer.lineWidth = _lineWidth * 2.0;
    _iconLayer.lineWidth = _lineWidth;
}

#pragma mark -
#pragma mark Drawing

- (void) drawBackgroundCircle:(BOOL) partial {
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    CGFloat radius = (self.bounds.size.width - _lineWidth)/2;
    
    // Draw background
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = _lineWidth;
    processBackgroundPath.lineCapStyle = kCGLineCapRound;
    
    // Recompute the end angle to make it at 90% of the progress
    if (partial) {
        endAngle = (1.8F * (float)M_PI) + startAngle;
    }

    [processBackgroundPath addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];

    _progressBackgroundLayer.path = processBackgroundPath.CGPath;
}

- (void) drawTick {
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height)/2;
    
    /*
     First draw a tick that looks like this:
     
     A---F
     |   |
     |   E-------D
     |           |
     B-----------C
     
     (Remember: (0,0) is top left)
     */
    UIBezierPath *tickPath = [UIBezierPath bezierPath];
    CGFloat tickWidth = radius * kTickWidthRatio;
    [tickPath moveToPoint:CGPointMake(0, 0)];                            // A
    [tickPath addLineToPoint:CGPointMake(0, tickWidth * 2)];             // B
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3, tickWidth * 2)]; // C
    [tickPath addLineToPoint:CGPointMake(tickWidth * 3, tickWidth)];     // D
    [tickPath addLineToPoint:CGPointMake(tickWidth, tickWidth)];         // E
    [tickPath addLineToPoint:CGPointMake(tickWidth, 0)];                 // F
    [tickPath closePath];
    
    // Now rotate it through -45 degrees...
    [tickPath applyTransform:CGAffineTransformMakeRotation(-M_PI_4)];
    
    // ...and move it into the right place.
    [tickPath applyTransform:CGAffineTransformMakeTranslation(radius * .46, 1.02 * radius)];
    
    [_iconLayer setPath:tickPath.CGPath];
    [_iconLayer setFillColor:[UIColor whiteColor].CGColor];
    [_progressBackgroundLayer setFillColor:_progressLayer.strokeColor];
}

- (void) drawStop {
//    return;
//    CGFloat radius = (self.bounds.size.width)/2;
//    CGFloat ratio = kStopSizeRatio;
//    CGFloat sideSize = self.bounds.size.width * ratio;
//    
//    UIBezierPath *stopPath = [UIBezierPath bezierPath];
//    [stopPath moveToPoint:CGPointMake(0, 0)];
//    [stopPath addLineToPoint:CGPointMake(sideSize, 0.0)];
//    [stopPath addLineToPoint:CGPointMake(sideSize, sideSize)];
//    [stopPath addLineToPoint:CGPointMake(0.0, sideSize)];
//    [stopPath closePath];
//    
//    // ...and move it into the right place.
//    [stopPath applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];
//    
//    [_iconLayer setPath:stopPath.CGPath];
//    [_iconLayer setStrokeColor:_progressLayer.strokeColor];
//    [_iconLayer setFillColor:tintColor.CGColor];
}

- (void) drawArrow {
    if (self.drawArrawToStop) {
        [self drawStop];
    }
    else {
        [_iconLayer setStrokeColor:[UIColor clearColor].CGColor];
        _iconLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return;
#if 0
    CGFloat radius = (self.bounds.size.width)/2;
    CGFloat ratio = kArrowSizeRatio;
    CGFloat segmentSize = self.bounds.size.width * ratio;

    // Draw icon
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0, 0.0)];
    [path addLineToPoint:CGPointMake(segmentSize * 2.0, 0.0)];
    [path addLineToPoint:CGPointMake(segmentSize * 2.0, segmentSize)];
    [path addLineToPoint:CGPointMake(segmentSize * 3.0, segmentSize)];
    [path addLineToPoint:CGPointMake(segmentSize, segmentSize * 3.3)];
    [path addLineToPoint:CGPointMake(-segmentSize, segmentSize)];
    [path addLineToPoint:CGPointMake(0.0, segmentSize)];
    [path addLineToPoint:CGPointMake(0.0, 0.0)];
    [path closePath];

    [path applyTransform:CGAffineTransformMakeTranslation(-segmentSize /2.0, -segmentSize / 1.2)];
    [path applyTransform:CGAffineTransformMakeTranslation(radius * (1-ratio), radius* (1-ratio))];
    _iconLayer.path = path.CGPath;
    [_iconLayer setStrokeColor:[UIColor clearColor].CGColor];
    _iconLayer.fillColor = nil;
#endif
}

#pragma mark Setters

- (void)setProgress:(CGFloat)progress {
    if (progress > 1.0) progress = 1.0;
    
    if (_progress != progress) {
        _progress = progress;
        
        if (_progress == 1.0) {
            [self animateProgressBackgroundLayerFillColor];
        }
        
        if (_progress == 0.0) {
            _progressBackgroundLayer.fillColor = self.backgroundColor.CGColor;
        }
        
        [self setNeedsDisplay];
        
        [self.percentageLabel setText:[NSString stringWithFormat:@"%d%%", (int)(_progress*100)]];
    }
}

#pragma mark Animations

- (void) animateProgressBackgroundLayerFillColor {
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
    
    colorAnimation.duration = .5;
    colorAnimation.repeatCount = 1.0;
    colorAnimation.removedOnCompletion = NO;
    
    colorAnimation.fromValue = ( id) _progressBackgroundLayer.backgroundColor;
    colorAnimation.toValue = ( id) _progressLayer.strokeColor;
    
    colorAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [_progressBackgroundLayer addAnimation:colorAnimation forKey:@"colorAnimation"];
}

- (void) startSpinProgressBackgroundLayer {
    self.isSpinning = YES;
    [self drawBackgroundCircle:YES];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [_progressBackgroundLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) stopSpinProgressBackgroundLayer {
    [self drawBackgroundCircle:NO];
    
    [_progressBackgroundLayer removeAllAnimations];
    self.isSpinning = NO;
}

@end
