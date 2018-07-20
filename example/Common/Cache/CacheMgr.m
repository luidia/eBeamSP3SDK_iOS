//
//  CacheMgr.h
//  PenTestExtension
//
//  Created by Luidia on 2018. 07. 20..
//  Copyright © 2018년 Luidia. All rights reserved.
//

#import "CacheMgr.h"

@interface CacheMgr ()
{
    NSMutableArray* queue;
    NSThread* thread;
    NSLock* lock;
    BOOL stopFlag;
    BOOL wait;
}
@property (retain) NSMutableArray* queue;
@property (readwrite) BOOL stopFlag;
@property (readwrite) BOOL wait;
@end

@implementation CacheMgr
@synthesize delegate;
@synthesize queue;
@synthesize stopFlag;
@synthesize wait;
@synthesize maxQueueCount;

-(void) dealloc {
    [self stopThread];
    
    [lock release];
    
    [self.queue removeAllObjects];
    self.queue = nil;
    
    [super dealloc];
}

-(id) init {
    self = [super init];
    if (self) {
        delegate = nil;
        thread = nil;
        self.maxQueueCount = 500;
        lock = [[NSLock alloc] init];
        self.queue = [[[NSMutableArray alloc] init] autorelease];
        [self start];
    }
    return self;
}

-(void) start {
    [self stopThread];
    self.stopFlag = NO;
    self.wait = NO;
    self.queue = [[[NSMutableArray alloc] init] autorelease];
    
    thread = [[NSThread alloc] initWithTarget:self selector:@selector(runThread) object:self];
    [thread setThreadPriority:1];
    [thread start];
}

-(void) stopThread {
    self.stopFlag = YES;

    if (thread) {
        [thread cancel];
        [thread release];
        thread = nil;
    }
    [self.queue removeAllObjects];
}

-(void) runThread {
    @autoreleasepool {
        while (1) {
            if (self.stopFlag){
                break;
            }else{
                [lock lock];
                
                if (self.wait) {
                    [lock unlock];
                    
                    [NSThread sleepForTimeInterval:0.01];
                    continue;
                }
                
                if (self.queue.count == 0) {
                    [lock unlock];
                    [NSThread sleepForTimeInterval:0.01];
                    continue;
                }
                
                if (self.queue.count && !self.wait) {
                    self.wait = YES;
                    [lock unlock];
                    
                    [self performSelectorOnMainThread:@selector(doImpl) withObject:nil waitUntilDone:NO];
                    continue;
                }
                
                [lock unlock];
            }
        }
    }
}

-(void) doImpl {
    if (delegate == nil) {
        [lock lock];
        @autoreleasepool {
            [self.queue removeObjectAtIndex:0];
        }
        [lock unlock];
    }
    if ([self.delegate respondsToSelector:@selector(CacheMgrPullData:)]) {
        [lock lock];
        id obj = [self.queue objectAtIndex:0];
        [lock unlock];
        [self.delegate CacheMgrPullData:obj];
    }
}

-(void) addObject:(id)obj {
    [lock lock];
    if (self.queue.count >= self.maxQueueCount) {
        [lock unlock];
        return;
    }
    [self.queue addObject:obj];
    [lock unlock];
}

-(id) object:(int)idx {
    [lock lock];
    id obj = [self.queue objectAtIndex:idx];
    [lock unlock];
    return obj;
}

-(void) playWithPull {
    [lock lock];
    @autoreleasepool {
        if (self.queue.count) {
            [self.queue removeObjectAtIndex:0];
        }
    }
    self.wait = NO;
    [lock unlock];
}

-(int) queueCount {
    int cnt = 0;
    [lock lock];
    cnt = (int)self.queue.count;
    [lock unlock];
    return cnt;
}
-(void) queueClear {
    [lock lock];
    @autoreleasepool {
        if (self.queue) {
            [self.queue removeAllObjects];
        }
    }
    [lock unlock];
}

@end
