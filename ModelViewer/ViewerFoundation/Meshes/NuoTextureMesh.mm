//
//  NuoTextureMesh.m
//  ModelViewer
//
//  Created by middleware on 11/3/16.
//  Copyright © 2016 middleware. All rights reserved.
//

#import "NuoTextureMesh.h"
#import "NuoTextureBase.h"


@implementation NuoTextureMesh
{
    __weak id<MTLSamplerState> _samplerState;
}


- (instancetype)initWithDevice:(id<MTLDevice>)device
{
    float vertices[] =
    {
        -1, 1, 0, 1.0,     0, 0, 0, 0,
        -1, -1, 0, 1.0,    0, 1, 0, 0,
        1, -1, 0, 1.0,     1, 1, 0, 0,
        1, 1, 0, 1.0,      1, 0, 0, 0,
    };
    
    uint32_t indices[] =
    {
        0, 1, 2,
        2, 3, 0
    };
    
    self = [super initWithDevice:device
              withVerticesBuffer:(void*)vertices withLength:(size_t)sizeof(vertices)
                     withIndices:(void*)indices withLength:(size_t)sizeof(indices)];
    
    if (self)
    {
    }
    
    return self;
}


- (void)makePipelineAndSampler:(MTLPixelFormat)pixelFormat withSampleCount:(NSUInteger)sampleCount
{
    id<MTLLibrary> library = [self.device newDefaultLibrary];
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.vertexFunction = [library newFunctionWithName:@"texture_project"];
    pipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragment_texutre"];
    pipelineDescriptor.sampleCount = sampleCount;
    pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat;
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    MTLVertexDescriptor* vertexDescriptor = [MTLVertexDescriptor new];
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
    vertexDescriptor.attributes[1].offset = 16;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.layouts[0].stride = 32;
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    pipelineDescriptor.vertexDescriptor = vertexDescriptor;
    
    [self makePipelineState:pipelineDescriptor];
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = NO;
    
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    _samplerState = [[NuoTextureBase getInstance:self.device] textureSamplerState:YES];
}


- (void)drawMesh:(id<MTLRenderCommandEncoder>)renderPass indexBuffer:(NSInteger)index
{
    [renderPass setFrontFacingWinding:MTLWindingCounterClockwise];
    [renderPass setRenderPipelineState:self.renderPipelineState];
    [renderPass setDepthStencilState:self.depthStencilState];
    
    [renderPass setVertexBuffer:self.vertexBuffer offset:0 atIndex:0];
    [renderPass setFragmentTexture:_modelTexture atIndex:0];
    [renderPass setFragmentSamplerState:_samplerState atIndex:0];
    
    [renderPass drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                           indexCount:[self.indexBuffer length] / sizeof(uint32_t)
                            indexType:MTLIndexTypeUInt32
                          indexBuffer:self.indexBuffer
                    indexBufferOffset:0];
}


@end
