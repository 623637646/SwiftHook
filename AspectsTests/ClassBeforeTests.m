//
//  ClassBeforeTests.m
//  AspectsTests
//
//  Created by Yanni Wang on 11/10/19.
//  Copyright © 2019 Yanni. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Aspects.h"
#import "TestObjects/TestObject.h"

@interface ClassBeforeTests : XCTestCase

@end

@implementation ClassBeforeTests

// Aspects don't support this
- (void)testTriggered
{
    __block BOOL triggered = NO;
    NSError *error = nil;
    id<AspectToken> token = [TestObject aspect_hookSelector:@selector(classSimpleMethod) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> info){
        triggered = YES;
    } error:&error];
    XCTAssert(error == nil);

    XCTAssert(triggered == NO);
    [TestObject classSimpleMethod];
    XCTAssert(triggered == YES);

    XCTAssert([token remove] == YES);
}

@end
