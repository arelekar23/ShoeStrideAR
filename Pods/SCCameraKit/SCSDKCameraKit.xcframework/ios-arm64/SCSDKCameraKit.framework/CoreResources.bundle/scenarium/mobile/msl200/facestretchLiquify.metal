#pragma clang diagnostic ignored "-Wmissing-prototypes"
#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;
#define STD_DISABLE_VERTEX_NORMAL 1
#define STD_DISABLE_VERTEX_TANGENT 1
#define STD_DISABLE_VERTEX_TEXTURE1 1
#include "required2.metal"
#include "std2_vs.metal"
#include "std2_fs.metal"
#include "std2_texture.metal"
//SG_REFLECTION_BEGIN(100)
//attribute vec4 atbCoord2d 18
//ubo float UserUniforms 2:0:960 {
//float4x4 ptsInvMat 0:[10]:64
//float4 coeffs 640:[10]:16
//float3 camDirO 800:[10]:16
//}
//SG_REFLECTION_END

namespace SNAP_VS {
struct userUniformsObj
{
float4x4 ptsInvMat[10];
float4 coeffs[10];
float3 camDirO[10];
};
#ifndef CAMERA_ORTHO
#define CAMERA_ORTHO 0
#elif CAMERA_ORTHO==1
#undef CAMERA_ORTHO
#define CAMERA_ORTHO 1
#endif
#ifndef LIQUIFY_FACESTRETCH
#define LIQUIFY_FACESTRETCH 0
#elif LIQUIFY_FACESTRETCH==1
#undef LIQUIFY_FACESTRETCH
#define LIQUIFY_FACESTRETCH 1
#endif
#ifndef MAX_LIQUIFY
#define MAX_LIQUIFY 10
#endif
struct sc_Set2
{
constant userUniformsObj* UserUniforms [[id(0)]];
};
struct sc_VertOut
{
sc_SysOut sc_sysOut;
float2 varScreenSpacePointsPos0 [[user(locn10)]];
float2 varScreenSpacePointsPos1 [[user(locn11)]];
float2 varScreenSpacePointsPos2 [[user(locn12)]];
float2 varScreenSpacePointsPos3 [[user(locn13)]];
float2 varScreenSpacePointsPos4 [[user(locn14)]];
float2 varScreenSpacePointsPos5 [[user(locn15)]];
float2 varScreenSpacePointsPos6 [[user(locn16)]];
float2 varScreenSpacePointsPos7 [[user(locn17)]];
float2 varScreenSpacePointsPos8 [[user(locn18)]];
float2 varScreenSpacePointsPos9 [[user(locn19)]];
};
struct sc_VertIn
{
sc_SysAttributes sc_sysAttributes;
float4 atbCoord2d [[attribute(18)]];
};
float2 calculateObjSpace(thread const int& i,thread const float4& worldPos,constant userUniformsObj& UserUniforms,thread sc_SysIn& sc_sysIn,thread sc_SysOut& sc_sysOut,const constant sc_Set0& sc_set0,const constant sc_Set1& sc_set1)
{
float4 vertexPosObjSpace=UserUniforms.ptsInvMat[i]*worldPos;
float3 viewDirObjSpace;
float4 camPosObjSpace;
#if (CAMERA_ORTHO)
{
viewDirObjSpace=UserUniforms.camDirO[i];
camPosObjSpace=vertexPosObjSpace-float4(viewDirObjSpace,0.0);
}
#else
{
camPosObjSpace=UserUniforms.ptsInvMat[i]*float4((*sc_set0.LibraryUniforms).sc_Camera.position,1.0);
viewDirObjSpace=normalize(vertexPosObjSpace.xyz-camPosObjSpace.xyz);
}
#endif
float denom=viewDirObjSpace.z;
float t=10000.0;
if (denom!=0.0)
{
t=(-camPosObjSpace.z)/denom;
}
if (t<0.0)
{
t=10000.0;
}
return camPosObjSpace.xy+(viewDirObjSpace.xy*t);
}
vertex sc_VertOut main_vert(sc_VertIn sc_vertIn [[stage_in]],constant sc_Set0& sc_set0 [[buffer(0)]],constant sc_Set1& sc_set1 [[buffer(1)]],constant sc_Set2& sc_set2 [[buffer(2)]],uint gl_InstanceIndex [[instance_id]],uint gl_VertexIndex [[vertex_id]])
{
sc_SysIn sc_sysIn;
sc_sysIn.sc_sysAttributes=sc_vertIn.sc_sysAttributes;
sc_sysIn.gl_VertexIndex=gl_VertexIndex;
sc_sysIn.gl_InstanceIndex=gl_InstanceIndex;
sc_VertOut sc_vertOut={};
sc_Vertex_t v=sc_LoadVertexAttributes(sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
v.position=float4(sc_vertIn.atbCoord2d.xy,0.0,1.0);
sc_Vertex_t param=v;
sc_ProcessVertex(param,sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
sc_vertOut.sc_sysOut.varScreenPos=sc_vertIn.atbCoord2d;
float4 screenPos=float4(sc_vertIn.atbCoord2d.xy,-1.0,1.0);
float2 floatSum=float2(sc_vertIn.atbCoord2d.z,sc_vertIn.atbCoord2d.w);
#if (LIQUIFY_FACESTRETCH)
{
float2 l9_0=sc_vertOut.sc_sysOut.varScreenPos.xy+floatSum;
sc_vertOut.sc_sysOut.varScreenPos=float4(l9_0.x,l9_0.y,sc_vertOut.sc_sysOut.varScreenPos.z,sc_vertOut.sc_sysOut.varScreenPos.w);
float2 l9_1=screenPos.xy+floatSum;
screenPos=float4(l9_1.x,l9_1.y,screenPos.z,screenPos.w);
}
#endif
float4 worldPos=(*sc_set0.LibraryUniforms).sc_ViewProjectionMatrixInverseArray[sc_GetStereoViewIndex(sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1)]*screenPos;
float3 l9_2=worldPos.xyz/float3(worldPos.w);
worldPos=float4(l9_2.x,l9_2.y,l9_2.z,worldPos.w);
worldPos.w=1.0;
#if (MAX_LIQUIFY>0)
{
int param_1=0;
float4 param_2=worldPos;
sc_vertOut.varScreenSpacePointsPos0=calculateObjSpace(param_1,param_2,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>1)
{
int param_3=1;
float4 param_4=worldPos;
sc_vertOut.varScreenSpacePointsPos1=calculateObjSpace(param_3,param_4,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>2)
{
int param_5=2;
float4 param_6=worldPos;
sc_vertOut.varScreenSpacePointsPos2=calculateObjSpace(param_5,param_6,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>3)
{
int param_7=3;
float4 param_8=worldPos;
sc_vertOut.varScreenSpacePointsPos3=calculateObjSpace(param_7,param_8,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>4)
{
int param_9=4;
float4 param_10=worldPos;
sc_vertOut.varScreenSpacePointsPos4=calculateObjSpace(param_9,param_10,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>5)
{
int param_11=5;
float4 param_12=worldPos;
sc_vertOut.varScreenSpacePointsPos5=calculateObjSpace(param_11,param_12,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>6)
{
int param_13=6;
float4 param_14=worldPos;
sc_vertOut.varScreenSpacePointsPos6=calculateObjSpace(param_13,param_14,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>7)
{
int param_15=7;
float4 param_16=worldPos;
sc_vertOut.varScreenSpacePointsPos7=calculateObjSpace(param_15,param_16,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>8)
{
int param_17=8;
float4 param_18=worldPos;
sc_vertOut.varScreenSpacePointsPos8=calculateObjSpace(param_17,param_18,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (MAX_LIQUIFY>9)
{
int param_19=9;
float4 param_20=worldPos;
sc_vertOut.varScreenSpacePointsPos9=calculateObjSpace(param_19,param_20,(*sc_set2.UserUniforms),sc_sysIn,sc_vertOut.sc_sysOut,sc_set0,sc_set1);
}
#endif
#if (!LIQUIFY_FACESTRETCH)
{
float2 l9_3=floatSum*0.5;
sc_vertOut.sc_sysOut.varScreenPos=float4(sc_vertOut.sc_sysOut.varScreenPos.x,sc_vertOut.sc_sysOut.varScreenPos.y,l9_3.x,l9_3.y);
}
#endif
return sc_vertOut;
}
} // VERTEX SHADER


namespace SNAP_FS {
struct userUniformsObj
{
float4x4 ptsInvMat[10];
float4 coeffs[10];
float3 camDirO[10];
};
#ifndef MAX_LIQUIFY
#define MAX_LIQUIFY 10
#endif
#ifndef LIQUIFY_FACESTRETCH
#define LIQUIFY_FACESTRETCH 0
#elif LIQUIFY_FACESTRETCH==1
#undef LIQUIFY_FACESTRETCH
#define LIQUIFY_FACESTRETCH 1
#endif
#ifndef CAMERA_ORTHO
#define CAMERA_ORTHO 0
#elif CAMERA_ORTHO==1
#undef CAMERA_ORTHO
#define CAMERA_ORTHO 1
#endif
struct sc_Set2
{
constant userUniformsObj* UserUniforms [[id(0)]];
};
struct sc_FragOut
{
sc_SysOut sc_sysOut;
};
struct sc_FragIn
{
sc_SysIn sc_sysIn;
float2 varScreenSpacePointsPos0 [[user(locn10)]];
float2 varScreenSpacePointsPos1 [[user(locn11)]];
float2 varScreenSpacePointsPos2 [[user(locn12)]];
float2 varScreenSpacePointsPos3 [[user(locn13)]];
float2 varScreenSpacePointsPos4 [[user(locn14)]];
float2 varScreenSpacePointsPos5 [[user(locn15)]];
float2 varScreenSpacePointsPos6 [[user(locn16)]];
float2 varScreenSpacePointsPos7 [[user(locn17)]];
float2 varScreenSpacePointsPos8 [[user(locn18)]];
float2 varScreenSpacePointsPos9 [[user(locn19)]];
};
float liquifyVector(thread const float& curDistanceSquared,thread const float& radiusSquared,thread const float& coeficient)
{
return pow(fast::clamp(curDistanceSquared/radiusSquared,0.00078125001,1.0),coeficient);
}
float2 calcOffsetForPoint(thread const int& i,thread const float2& varScreenSpacePointsPos,thread const float4& varScreenPos,constant userUniformsObj& UserUniforms)
{
float dist=dot(varScreenSpacePointsPos,varScreenSpacePointsPos);
float2 fromPointCenterVector=varScreenPos.xy-UserUniforms.coeffs[i].xy;
float param=dist;
float param_1=UserUniforms.coeffs[i].w;
float param_2=UserUniforms.coeffs[i].z;
float vecCoef=liquifyVector(param,param_1,param_2)-1.0;
vecCoef*=step(dist,UserUniforms.coeffs[i].w);
return fromPointCenterVector*vecCoef;
}
fragment sc_FragOut main_frag(sc_FragIn sc_fragIn [[stage_in]],constant sc_Set0& sc_set0 [[buffer(0)]],constant sc_Set1& sc_set1 [[buffer(1)]],constant sc_Set2& sc_set2 [[buffer(2)]],float4 gl_FragCoord [[position]],bool gl_FrontFacing [[front_facing]])
{
sc_fragIn.sc_sysIn.gl_FragCoord=gl_FragCoord;
sc_fragIn.sc_sysIn.gl_FrontFacing=gl_FrontFacing;
sc_FragOut sc_fragOut={};
sc_DiscardStereoFragment(sc_fragIn.sc_sysIn,sc_set0,sc_set1);
float2 liqVec=float2(0.0);
float2 posToFetch=sc_fragIn.sc_sysIn.varScreenPos.xy;
#if (MAX_LIQUIFY>0)
{
int param=0;
float2 param_1=sc_fragIn.varScreenSpacePointsPos0;
float4 param_2=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param,param_1,param_2,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>1)
{
int param_3=1;
float2 param_4=sc_fragIn.varScreenSpacePointsPos1;
float4 param_5=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_3,param_4,param_5,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>2)
{
int param_6=2;
float2 param_7=sc_fragIn.varScreenSpacePointsPos2;
float4 param_8=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_6,param_7,param_8,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>3)
{
int param_9=3;
float2 param_10=sc_fragIn.varScreenSpacePointsPos3;
float4 param_11=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_9,param_10,param_11,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>4)
{
int param_12=4;
float2 param_13=sc_fragIn.varScreenSpacePointsPos4;
float4 param_14=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_12,param_13,param_14,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>5)
{
int param_15=5;
float2 param_16=sc_fragIn.varScreenSpacePointsPos5;
float4 param_17=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_15,param_16,param_17,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>6)
{
int param_18=6;
float2 param_19=sc_fragIn.varScreenSpacePointsPos6;
float4 param_20=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_18,param_19,param_20,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>7)
{
int param_21=7;
float2 param_22=sc_fragIn.varScreenSpacePointsPos7;
float4 param_23=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_21,param_22,param_23,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>8)
{
int param_24=8;
float2 param_25=sc_fragIn.varScreenSpacePointsPos8;
float4 param_26=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_24,param_25,param_26,(*sc_set2.UserUniforms));
}
#endif
#if (MAX_LIQUIFY>9)
{
int param_27=9;
float2 param_28=sc_fragIn.varScreenSpacePointsPos9;
float4 param_29=sc_fragIn.sc_sysIn.varScreenPos;
liqVec+=calcOffsetForPoint(param_27,param_28,param_29,(*sc_set2.UserUniforms));
}
#endif
posToFetch+=liqVec;
posToFetch=(posToFetch*float2(0.5))+float2(0.5);
#if (!LIQUIFY_FACESTRETCH)
{
posToFetch+=sc_fragIn.sc_sysIn.varScreenPos.zw;
}
#endif
float2 param_30=posToFetch;
float4 resultColor=sc_ScreenTextureSampleView(param_30,sc_fragIn.sc_sysIn,sc_set0,sc_set1);
float4 param_31=resultColor;
sc_writeFragData0(param_31,sc_fragIn.sc_sysIn,sc_fragOut.sc_sysOut,sc_set0,sc_set1);
return sc_fragOut;
}
} // FRAGMENT SHADER
