//
//  QUTPollingManager.m
//  uQu
//
//  Created by Andreas Buff on 14/06/15.
//  Copyright (c) 2015 Cookie Monster. All rights reserved.
//
#import "QUTPollingManager.h"

#import "SFAPIClient.h"
#import "QUTAnswer.h"
#import "QUTQuestion.h"

NSString *QUTNotificationNewAnswers = @"QUTNotificationNewAnswers";
NSString *QUTNotificationNewQuestions = @"QUTNotificationNewQuestions";

@interface QUTPollingManager ()
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSArray *previousAnswers;
@end

@implementation QUTPollingManager

- (void)poll
{
    [[SFAPIClient sharedApiClient] getAllAnswersOnSuccess:^(NSArray *result) {
        //sort array by date
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                            sortDescriptorWithKey:@"createDate"
                                            ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
        NSMutableArray *sortedArray = [[result
                                     sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
        if (sortedArray.count > self.previousAnswers.count) {
            NSInteger newCount = sortedArray.count - self.previousAnswers.count;
            NSMutableArray *newAnswers = [NSMutableArray new];
            for (NSInteger i = 0; i < newCount; ++i) {
                [newAnswers addObject:[sortedArray lastObject]];
                [sortedArray removeObject:[sortedArray lastObject]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:QUTNotificationNewAnswers object:<#(id)#>];
        }
    } onError:^(NSError *error) {
        NSLog(@"Uups: %@", error);
    }];
}

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.timer = [NSTimer timerWithTimeInterval:3.5 target:self selector:@selector(poll) userInfo:nil repeats:YES];
        //TODO:
    }
    return self;
}
@end
