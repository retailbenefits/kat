//
//  Copyright 2012, 2013 Lolay, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSArray+Lolay.h"

@implementation NSArray (Lolay)

- (id) firstObject {
	return self.count > 0 ? [self objectAtIndex:0] : nil;
}

- (id) middleObject {
	return self.count > 0 ? [self objectAtIndex:self.count / 2] : nil;
}

- (NSArray*) arrayByRemovingObject:(id) object {
	NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self];
	[array removeObject:object];
	return array;
}

- (NSArray*) arrayByRemovingObjects:(NSArray*) objects {
	NSMutableArray* array = [[NSMutableArray alloc] initWithArray:self];
	for (id object in objects) {
		[array removeObject:object];
	}
	return array;
}

- (NSArray*) arrayByRemovingLastObject {
	id object = [self lastObject];
	if (object == nil) {
		return nil;
	}
	
	return [self arrayByRemovingObject:object];
}

- (NSArray*) arrayByIntersectingArray:(NSArray*) objects {
	NSMutableArray* array = [[NSMutableArray alloc] init];
	for (id object in objects) {
		if ([self containsObject:object]) {
			[array addObject:object];
		}
	}
	
	return array;
}

- (NSArray*) arrayByReversing {
	NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity:self.count];
	for (NSUInteger index = self.count; index > 0; index--) {
		[array addObject:[self objectAtIndex:index - 1]];
	}
	return array;
}

@end
