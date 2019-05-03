//
//  NuoRenderer.m
//  ModelViewer
//
//  Created by middleware on 11/8/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import "NuoRenderPass.h"


@interface NuoRenderPass()

@end


@implementation NuoRenderPass



- (void)setDrawableSize:(CGSize)drawableSize
{ 
    [_renderTarget setDrawableSize:drawableSize];
}


- (void)setSampleCount:(NSUInteger)sampleCount
{
    [_renderTarget setSampleCount:sampleCount];
}


- (void)predrawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
               withInFlightIndex:(unsigned int)inFlight
{
}


- (void)drawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
            withInFlightIndex:(unsigned int)inFlight
{
}


- (BOOL)isPipelinePass
{
    return NO;
}


- (NuoRenderPassEncoder*)retainDefaultEncoder:(id<MTLCommandBuffer>)commandBuffer
                                 withInFlight:(uint)inFlight
{
    return [_renderTarget retainRenderPassEndcoder:commandBuffer
                                      withInFlight:inFlight];
}


- (void)releaseDefaultEncoder
{
    [_renderTarget releaseRenderPassEndcoder];
}


@end
