//
//  NuoRenderer.h
//  ModelViewer
//
//  Created by middleware on 11/8/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


#import "NuoRenderPassTarget.h"



@interface NuoRenderPass : NSObject

@property (nonatomic, weak) id<MTLDevice> device;

@property (nonatomic, strong) NuoRenderPassTarget* renderTarget;


- (void)setDrawableSize:(CGSize)drawableSize;

/**
 *  manage the underlying graphics render-pass support (i.e. in Metal, a command encoder).
 *
 *  a Nuo render pass accepts a command-buffer from ouside for each frame, and always manage the render pass
 *  through the following two functions. no code is allowed to create a render pass except through
 *  "currentRenderPass:".
 *
 *  a render pass should never call its own "endCurrentPass", which is called only by the pipeline
 *  or a parent render pass
 */
- (id<MTLRenderCommandEncoder>)currentRenderPass:(id<MTLCommandBuffer>)commandBuffer;
- (void)endCurrentPass;

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
