//
//  CacheMgr.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 07. 20..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CacheMgrDelegate
@optional
-(void) CacheMgrPullData:(id)obj;
@end

@interface CacheMgr : NSObject
{
    id<CacheMgrDelegate> delegate;
    int maxQueueCount;
}

@property (nonatomic, assign) id delegate;
@property (readwrite) int maxQueueCount;

-(void) addObject:(id)obj;
-(id) object:(int)idx;
-(void) playWithPull;
-(int) queueCount;
-(void) queueClear;
@end
