//
//  AspectsInstanceInsteadTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AspectsInstanceInsteadTests : XCTestCase

@end

@implementation AspectsInstanceInsteadTests

//- (void)testInstanceMethodInstead {
//
//    NSError *error = nil;
//    TestObject *obj = [[TestObject alloc] init];
//    __block BOOL triggered = NO;
//    
//    [obj aspect_hookSelector:@selector(executeInstanceMethod) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info){
//        triggered = YES;
//        TestObject *obj = info.instance;
//        XCTAssert(obj.alreadyExecutedMethod == NO);
//    } error:&error];
//    XCTAssert(error == nil);
//    
//    XCTAssert(obj.alreadyExecutedMethod == NO);
//    [obj executeInstanceMethod];
//    XCTAssert(obj.alreadyExecutedMethod == NO);
//    XCTAssert(triggered == YES);
//    
//    [self testInstanceMethodNoHook];
//}

@end
