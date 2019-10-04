//
//  AspectsClassTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 4/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface AllInstanceBeforeTests : XCTestCase

@property (nonatomic, assign) BOOL triggered;

@end

@implementation AllInstanceBeforeTests

//- (void)setUp {
//    NSError *error = nil;
//    __block BOOL triggered = NO;
//    
//    [TestObject aspect_hookSelector:@selector(methodWithExecuted:) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
//        triggered = YES;
//    } error:&error];
//    XCTAssert(error == nil);
//    
//    XCTAssert(triggered == NO);
//    [obj methodWithExecuted:NULL];
//    XCTAssert(triggered == YES);
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//}
//
//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}

@end
