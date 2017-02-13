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

- (void)drawWithCommandBuffer:(id<MTLCommandBuffer>)commandBuffer
            withInFlightIndex:(unsigned int)inFlight;

- (BOOL)isPipelinePass;


@end
