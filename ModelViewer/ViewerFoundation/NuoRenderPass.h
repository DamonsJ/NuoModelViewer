//
//  NuoRenderer.h
//  ModelViewer
//
//  Created by middleware on 11/8/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


#import "NuoShadowMapTarget.h"



@interface NuoRenderPass : NSObject

@property (nonatomic, weak) id<MTLDevice> device;

@property (nonatomic, strong) NuoShadowMapTarget* renderTarget;


- (void)setDrawableSize:(CGSize)drawableSize;

/**
 *  draw calls that target to their own target (e.g. shadow map texture)
 */
- (void)predrawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
               withInFlightIndex:(unsigned int)inFlight;

/**
 *  draw calls that target to the *_renderTarget*
 */
- (void)drawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
            withInFlightIndex:(unsigned int)inFlight;

- (BOOL)isPipelinePass;


@end
