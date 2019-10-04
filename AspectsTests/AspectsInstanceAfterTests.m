//
//  AspectsInstanceAfterTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface AspectsInstanceAfterTests : XCTestCase

@end

@implementation AspectsInstanceAfterTests

//- (void)testInstanceMethodAfter {
//    
//    NSError *error = nil;
//    TestObject *obj = [[TestObject alloc] init];
//    __block BOOL triggered = NO;
//    
//    [obj aspect_hookSelector:@selector(executeInstanceMethod) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
//        triggered = YES;
//        TestObject *obj = info.instance;
//        XCTAssert(obj.alreadyExecutedMethod == YES);
//    } error:&error];
//    XCTAssert(error == nil);
//    
//    XCTAssert(obj.alreadyExecutedMethod == NO);
//    [obj executeInstanceMethod];
//    XCTAssert(obj.alreadyExecutedMethod == YES);
//    XCTAssert(triggered == YES);
//    
//    [self testInstanceMethodNoHook];
//}

@end
