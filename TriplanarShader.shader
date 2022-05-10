Shader "Triplanar Shader"
{
    Properties
    {
        [NoScaleOffset] _Diffuse("Diffuse", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 0)
        _Scale("Scale", Float) = 1
        _Tiling("Tiling", Vector) = (1, 1, 0, 0)
        _Offset("Offset", Vector) = (0, 0, 0, 0)
        _Rotation("Rotation", Vector) = (0, 0, 0, 0)
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
        {
            Tags
            {
                // RenderPipeline: <None>
                "RenderType" = "Opaque"
                "BuiltInMaterialType" = "Lit"
                "Queue" = "Geometry"
                "ShaderGraphShader" = "true"
                "ShaderGraphTargetId" = "BuiltInLitSubTarget"
            }
            Pass
            {
                Name "BuiltIn Forward"
                Tags
                {
                    "LightMode" = "ForwardBase"
                }

            // Render State
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            #define BUILTIN_TARGET_API 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #endif
            #ifdef _BUILTIN_ALPHATEST_ON
            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
            #endif
            #ifdef _BUILTIN_AlphaClip
            #define _AlphaClip _BUILTIN_AlphaClip
            #endif
            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
            #endif


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float3 viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                 float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                 float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 WorldSpaceNormal;
                 float3 TangentSpaceNormal;
                 float3 WorldSpacePosition;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                 float2 interp4 : INTERP4;
                 float3 interp5 : INTERP5;
                 float4 interp6 : INTERP6;
                 float4 interp7 : INTERP7;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                output.interp1.xyz = input.normalWS;
                output.interp2.xyzw = input.tangentWS;
                output.interp3.xyz = input.viewDirectionWS;
                #if defined(LIGHTMAP_ON)
                output.interp4.xy = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.interp5.xyz = input.sh;
                #endif
                output.interp6.xyzw = input.fogFactorAndVertexLight;
                output.interp7.xyzw = input.shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.tangentWS = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.interp4.xy;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.interp5.xyz;
                #endif
                output.fogFactorAndVertexLight = input.interp6.xyzw;
                output.shadowCoord = input.interp7.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Diffuse_TexelSize;
            float _Scale;
            float4 _Color;
            float2 _Tiling;
            float2 _Offset;
            float3 _Rotation;
            CBUFFER_END

                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Diffuse);
                SAMPLER(sampler_Diffuse);
                TEXTURE2D(_NormalMap);
                SAMPLER(sampler_NormalMap);
                float4 _NormalMap_TexelSize;

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Includes
                // GraphIncludes: <None>

                // Graph Functions

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }

                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }

                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f / 180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);

                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix * 2 - 1;

                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;

                    Out = UV;
                }

                void Unity_Absolute_float3(float3 In, out float3 Out)
                {
                    Out = abs(In);
                }

                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }

                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }

                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1 = IN.WorldSpacePosition[0];
                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2 = IN.WorldSpacePosition[1];
                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3 = IN.WorldSpacePosition[2];
                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_A_4 = 0;
                    float2 _Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                    float _Property_6d6d799069c64bbc88c7d493d1c58034_Out_0 = _Scale;
                    float _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2;
                    Unity_Divide_float(_Property_6d6d799069c64bbc88c7d493d1c58034_Out_0, 10, _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2);
                    float2 _Multiply_3873f65859374cdeabc7870ff773a003_Out_2;
                    Unity_Multiply_float2_float2(_Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_3873f65859374cdeabc7870ff773a003_Out_2);
                    float2 _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0 = _Tiling;
                    float2 _Property_ca329b23ebcb474bac30accc465470e6_Out_0 = _Offset;
                    float2 _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3;
                    Unity_TilingAndOffset_float(_Multiply_3873f65859374cdeabc7870ff773a003_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3);
                    float3 _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0 = _Rotation;
                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_R_1 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[0];
                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[1];
                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[2];
                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_A_4 = 0;
                    float _Add_f8432701c63d41a696f14f76b6a0990c_Out_2;
                    Unity_Add_float(_Split_e1478dd0b1e249edbcc837c52d3085bd_R_1, 90, _Add_f8432701c63d41a696f14f76b6a0990c_Out_2);
                    float2 _Rotate_43b6a3c764a04562821ce221efda444f_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3, float2 (0, 0), _Add_f8432701c63d41a696f14f76b6a0990c_Out_2, _Rotate_43b6a3c764a04562821ce221efda444f_Out_3);
                    float4 _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_43b6a3c764a04562821ce221efda444f_Out_3));
                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_R_4 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.r;
                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_G_5 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.g;
                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_B_6 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.b;
                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_A_7 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.a;
                    float3 _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1;
                    Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1);
                    float3 _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2;
                    Unity_Multiply_float3_float3(_Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2);
                    float _Split_54452dbfaa174a36ba0a54d33c331027_R_1 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[0];
                    float _Split_54452dbfaa174a36ba0a54d33c331027_G_2 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[1];
                    float _Split_54452dbfaa174a36ba0a54d33c331027_B_3 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[2];
                    float _Split_54452dbfaa174a36ba0a54d33c331027_A_4 = 0;
                    float4 _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2;
                    Unity_Multiply_float4_float4(_SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_R_1.xxxx), _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2);
                    float2 _Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                    float2 _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2;
                    Unity_Multiply_float2_float2(_Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2);
                    float2 _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3;
                    Unity_TilingAndOffset_float(_Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3);
                    float2 _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2, _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3);
                    float4 _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3));
                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_R_4 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.r;
                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_G_5 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.g;
                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_B_6 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.b;
                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_A_7 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.a;
                    float4 _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2;
                    Unity_Multiply_float4_float4(_SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_G_2.xxxx), _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2);
                    float2 _Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2);
                    float2 _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2;
                    Unity_Multiply_float2_float2(_Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2);
                    float2 _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3;
                    Unity_TilingAndOffset_float(_Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3);
                    float2 _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3, _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3);
                    float4 _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3));
                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_R_4 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.r;
                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_G_5 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.g;
                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_B_6 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.b;
                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_A_7 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.a;
                    float4 _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2;
                    Unity_Multiply_float4_float4(_SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_B_3.xxxx), _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2);
                    float4 _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2;
                    Unity_Add_float4(_Multiply_7617318190a54cacbce577ac28ea38b6_Out_2, _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2);
                    float4 _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2;
                    Unity_Add_float4(_Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2, _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2);
                    float4 _Property_068392aad9f244c69363de540e8985da_Out_0 = _Color;
                    float4 _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2;
                    Unity_Multiply_float4_float4(_Add_411fef93f66044fb85c7d2b2be126c6f_Out_2, _Property_068392aad9f244c69363de540e8985da_Out_0, _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2);
                    surface.BaseColor = (_Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2.xyz);
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs

                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                    output.WorldSpacePosition = input.positionWS;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                }

                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                {
                    result.vertex = float4(attributes.positionOS, 1);
                    result.tangent = attributes.tangentOS;
                    result.normal = attributes.normalOS;
                    result.texcoord1 = attributes.uv1;
                    result.vertex = float4(vertexDescription.Position, 1);
                    result.normal = vertexDescription.Normal;
                    result.tangent = float4(vertexDescription.Tangent, 0);
                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                }

                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                {
                    result.pos = varyings.positionCS;
                    result.worldPos = varyings.positionWS;
                    result.worldNormal = varyings.normalWS;
                    result.viewDir = varyings.viewDirectionWS;
                    // World Tangent isn't an available input on v2f_surf

                    result._ShadowCoord = varyings.shadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = varyings.sh;
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lmap.xy = varyings.lightmapUV;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                }

                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                {
                    result.positionCS = surfVertex.pos;
                    result.positionWS = surfVertex.worldPos;
                    result.normalWS = surfVertex.worldNormal;
                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                    // World Tangent isn't an available input on v2f_surf
                    result.shadowCoord = surfVertex._ShadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if UNITY_SHOULD_SAMPLE_SH
                    result.sh = surfVertex.sh;
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lightmapUV = surfVertex.lmap.xy;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                }

                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                ENDHLSL
                }
                Pass
                {
                    Name "BuiltIn ForwardAdd"
                    Tags
                    {
                        "LightMode" = "ForwardAdd"
                    }

                    // Render State
                    Blend SrcAlpha One, One One
                    ZWrite Off

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 3.0
                    #pragma multi_compile_instancing
                    #pragma multi_compile_fog
                    #pragma multi_compile_fwdadd_fullshadows
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                    #pragma multi_compile _ LIGHTMAP_ON
                    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                    #pragma multi_compile _ _SHADOWS_SOFT
                    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                    #pragma multi_compile _ SHADOWS_SHADOWMASK
                    // GraphKeywords: <None>

                    // Defines
                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD1
                    #define VARYINGS_NEED_POSITION_WS
                    #define VARYINGS_NEED_NORMAL_WS
                    #define VARYINGS_NEED_TANGENT_WS
                    #define VARYINGS_NEED_VIEWDIRECTION_WS
                    #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_FORWARD_ADD
                    #define BUILTIN_TARGET_API 1
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #endif
                    #ifdef _BUILTIN_ALPHATEST_ON
                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                    #endif
                    #ifdef _BUILTIN_AlphaClip
                    #define _AlphaClip _BUILTIN_AlphaClip
                    #endif
                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                    #endif


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                         float4 uv1 : TEXCOORD1;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 positionWS;
                         float3 normalWS;
                         float4 tangentWS;
                         float3 viewDirectionWS;
                        #if defined(LIGHTMAP_ON)
                         float2 lightmapUV;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                         float3 sh;
                        #endif
                         float4 fogFactorAndVertexLight;
                         float4 shadowCoord;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                         float3 WorldSpaceNormal;
                         float3 TangentSpaceNormal;
                         float3 WorldSpacePosition;
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 interp0 : INTERP0;
                         float3 interp1 : INTERP1;
                         float4 interp2 : INTERP2;
                         float3 interp3 : INTERP3;
                         float2 interp4 : INTERP4;
                         float3 interp5 : INTERP5;
                         float4 interp6 : INTERP6;
                         float4 interp7 : INTERP7;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        output.interp0.xyz = input.positionWS;
                        output.interp1.xyz = input.normalWS;
                        output.interp2.xyzw = input.tangentWS;
                        output.interp3.xyz = input.viewDirectionWS;
                        #if defined(LIGHTMAP_ON)
                        output.interp4.xy = input.lightmapUV;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        output.interp5.xyz = input.sh;
                        #endif
                        output.interp6.xyzw = input.fogFactorAndVertexLight;
                        output.interp7.xyzw = input.shadowCoord;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        output.positionWS = input.interp0.xyz;
                        output.normalWS = input.interp1.xyz;
                        output.tangentWS = input.interp2.xyzw;
                        output.viewDirectionWS = input.interp3.xyz;
                        #if defined(LIGHTMAP_ON)
                        output.lightmapUV = input.interp4.xy;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        output.sh = input.interp5.xyz;
                        #endif
                        output.fogFactorAndVertexLight = input.interp6.xyzw;
                        output.shadowCoord = input.interp7.xyzw;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }


                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float4 _Diffuse_TexelSize;
                    float _Scale;
                    float4 _Color;
                    float2 _Tiling;
                    float2 _Offset;
                    float3 _Rotation;
                    CBUFFER_END

                        // Object and Global properties
                        SAMPLER(SamplerState_Linear_Repeat);
                        TEXTURE2D(_Diffuse);
                        SAMPLER(sampler_Diffuse);
                        TEXTURE2D(_NormalMap);
                        SAMPLER(sampler_NormalMap);
                        float4 _NormalMap_TexelSize;

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Includes
                        // GraphIncludes: <None>

                        // Graph Functions

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }

                        void Unity_Add_float(float A, float B, out float Out)
                        {
                            Out = A + B;
                        }

                        void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                        {
                            //rotation matrix
                            Rotation = Rotation * (3.1415926f / 180.0f);
                            UV -= Center;
                            float s = sin(Rotation);
                            float c = cos(Rotation);

                            //center rotation matrix
                            float2x2 rMatrix = float2x2(c, -s, s, c);
                            rMatrix *= 0.5;
                            rMatrix += 0.5;
                            rMatrix = rMatrix * 2 - 1;

                            //multiply the UVs by the rotation matrix
                            UV.xy = mul(UV.xy, rMatrix);
                            UV += Center;

                            Out = UV;
                        }

                        void Unity_Absolute_float3(float3 In, out float3 Out)
                        {
                            Out = abs(In);
                        }

                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A + B;
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            description.Position = IN.ObjectSpacePosition;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 BaseColor;
                            float3 NormalTS;
                            float3 Emission;
                            float Metallic;
                            float Smoothness;
                            float Occlusion;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            UnityTexture2D _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1 = IN.WorldSpacePosition[0];
                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2 = IN.WorldSpacePosition[1];
                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3 = IN.WorldSpacePosition[2];
                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_A_4 = 0;
                            float2 _Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                            float _Property_6d6d799069c64bbc88c7d493d1c58034_Out_0 = _Scale;
                            float _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2;
                            Unity_Divide_float(_Property_6d6d799069c64bbc88c7d493d1c58034_Out_0, 10, _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2);
                            float2 _Multiply_3873f65859374cdeabc7870ff773a003_Out_2;
                            Unity_Multiply_float2_float2(_Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_3873f65859374cdeabc7870ff773a003_Out_2);
                            float2 _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0 = _Tiling;
                            float2 _Property_ca329b23ebcb474bac30accc465470e6_Out_0 = _Offset;
                            float2 _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3;
                            Unity_TilingAndOffset_float(_Multiply_3873f65859374cdeabc7870ff773a003_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3);
                            float3 _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0 = _Rotation;
                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_R_1 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[0];
                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[1];
                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[2];
                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_A_4 = 0;
                            float _Add_f8432701c63d41a696f14f76b6a0990c_Out_2;
                            Unity_Add_float(_Split_e1478dd0b1e249edbcc837c52d3085bd_R_1, 90, _Add_f8432701c63d41a696f14f76b6a0990c_Out_2);
                            float2 _Rotate_43b6a3c764a04562821ce221efda444f_Out_3;
                            Unity_Rotate_Degrees_float(_TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3, float2 (0, 0), _Add_f8432701c63d41a696f14f76b6a0990c_Out_2, _Rotate_43b6a3c764a04562821ce221efda444f_Out_3);
                            float4 _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_43b6a3c764a04562821ce221efda444f_Out_3));
                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_R_4 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.r;
                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_G_5 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.g;
                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_B_6 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.b;
                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_A_7 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.a;
                            float3 _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1;
                            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1);
                            float3 _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2;
                            Unity_Multiply_float3_float3(_Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2);
                            float _Split_54452dbfaa174a36ba0a54d33c331027_R_1 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[0];
                            float _Split_54452dbfaa174a36ba0a54d33c331027_G_2 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[1];
                            float _Split_54452dbfaa174a36ba0a54d33c331027_B_3 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[2];
                            float _Split_54452dbfaa174a36ba0a54d33c331027_A_4 = 0;
                            float4 _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2;
                            Unity_Multiply_float4_float4(_SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_R_1.xxxx), _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2);
                            float2 _Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                            float2 _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2;
                            Unity_Multiply_float2_float2(_Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2);
                            float2 _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3;
                            Unity_TilingAndOffset_float(_Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3);
                            float2 _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3;
                            Unity_Rotate_Degrees_float(_TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2, _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3);
                            float4 _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3));
                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_R_4 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.r;
                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_G_5 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.g;
                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_B_6 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.b;
                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_A_7 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.a;
                            float4 _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2;
                            Unity_Multiply_float4_float4(_SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_G_2.xxxx), _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2);
                            float2 _Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2);
                            float2 _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2;
                            Unity_Multiply_float2_float2(_Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2);
                            float2 _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3;
                            Unity_TilingAndOffset_float(_Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3);
                            float2 _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3;
                            Unity_Rotate_Degrees_float(_TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3, _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3);
                            float4 _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3));
                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_R_4 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.r;
                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_G_5 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.g;
                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_B_6 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.b;
                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_A_7 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.a;
                            float4 _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2;
                            Unity_Multiply_float4_float4(_SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_B_3.xxxx), _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2);
                            float4 _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2;
                            Unity_Add_float4(_Multiply_7617318190a54cacbce577ac28ea38b6_Out_2, _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2);
                            float4 _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2;
                            Unity_Add_float4(_Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2, _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2);
                            float4 _Property_068392aad9f244c69363de540e8985da_Out_0 = _Color;
                            float4 _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2;
                            Unity_Multiply_float4_float4(_Add_411fef93f66044fb85c7d2b2be126c6f_Out_2, _Property_068392aad9f244c69363de540e8985da_Out_0, _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2);
                            surface.BaseColor = (_Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2.xyz);
                            surface.NormalTS = IN.TangentSpaceNormal;
                            surface.Emission = float3(0, 0, 0);
                            surface.Metallic = 0;
                            surface.Smoothness = 0.5;
                            surface.Occlusion = 1;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                            float3 unnormalizedNormalWS = input.normalWS;
                            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                            output.WorldSpacePosition = input.positionWS;
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                        }

                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                        {
                            result.vertex = float4(attributes.positionOS, 1);
                            result.tangent = attributes.tangentOS;
                            result.normal = attributes.normalOS;
                            result.texcoord1 = attributes.uv1;
                            result.vertex = float4(vertexDescription.Position, 1);
                            result.normal = vertexDescription.Normal;
                            result.tangent = float4(vertexDescription.Tangent, 0);
                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                        }

                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                        {
                            result.pos = varyings.positionCS;
                            result.worldPos = varyings.positionWS;
                            result.worldNormal = varyings.normalWS;
                            result.viewDir = varyings.viewDirectionWS;
                            // World Tangent isn't an available input on v2f_surf

                            result._ShadowCoord = varyings.shadowCoord;

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if UNITY_SHOULD_SAMPLE_SH
                            result.sh = varyings.sh;
                            #endif
                            #if defined(LIGHTMAP_ON)
                            result.lmap.xy = varyings.lightmapUV;
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                        }

                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                        {
                            result.positionCS = surfVertex.pos;
                            result.positionWS = surfVertex.worldPos;
                            result.normalWS = surfVertex.worldNormal;
                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                            // World Tangent isn't an available input on v2f_surf
                            result.shadowCoord = surfVertex._ShadowCoord;

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if UNITY_SHOULD_SAMPLE_SH
                            result.sh = surfVertex.sh;
                            #endif
                            #if defined(LIGHTMAP_ON)
                            result.lightmapUV = surfVertex.lmap.xy;
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                        }

                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "BuiltIn Deferred"
                            Tags
                            {
                                "LightMode" = "Deferred"
                            }

                            // Render State
                            Cull Back
                            Blend One Zero
                            ZTest LEqual
                            ZWrite On

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 4.5
                            #pragma multi_compile_instancing
                            #pragma exclude_renderers nomrt
                            #pragma multi_compile_prepassfinal
                            #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            #pragma multi_compile _ LIGHTMAP_ON
                            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                            #pragma multi_compile _ _SHADOWS_SOFT
                            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                            #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                            // GraphKeywords: <None>

                            // Defines
                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD1
                            #define VARYINGS_NEED_POSITION_WS
                            #define VARYINGS_NEED_NORMAL_WS
                            #define VARYINGS_NEED_TANGENT_WS
                            #define VARYINGS_NEED_VIEWDIRECTION_WS
                            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SHADERPASS_DEFERRED
                            #define BUILTIN_TARGET_API 1
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #endif
                            #ifdef _BUILTIN_ALPHATEST_ON
                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                            #endif
                            #ifdef _BUILTIN_AlphaClip
                            #define _AlphaClip _BUILTIN_AlphaClip
                            #endif
                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                            #endif


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                 float4 uv1 : TEXCOORD1;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 positionWS;
                                 float3 normalWS;
                                 float4 tangentWS;
                                 float3 viewDirectionWS;
                                #if defined(LIGHTMAP_ON)
                                 float2 lightmapUV;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                 float3 sh;
                                #endif
                                 float4 fogFactorAndVertexLight;
                                 float4 shadowCoord;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                                 float3 WorldSpaceNormal;
                                 float3 TangentSpaceNormal;
                                 float3 WorldSpacePosition;
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 interp0 : INTERP0;
                                 float3 interp1 : INTERP1;
                                 float4 interp2 : INTERP2;
                                 float3 interp3 : INTERP3;
                                 float2 interp4 : INTERP4;
                                 float3 interp5 : INTERP5;
                                 float4 interp6 : INTERP6;
                                 float4 interp7 : INTERP7;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                output.interp0.xyz = input.positionWS;
                                output.interp1.xyz = input.normalWS;
                                output.interp2.xyzw = input.tangentWS;
                                output.interp3.xyz = input.viewDirectionWS;
                                #if defined(LIGHTMAP_ON)
                                output.interp4.xy = input.lightmapUV;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                output.interp5.xyz = input.sh;
                                #endif
                                output.interp6.xyzw = input.fogFactorAndVertexLight;
                                output.interp7.xyzw = input.shadowCoord;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                output.positionWS = input.interp0.xyz;
                                output.normalWS = input.interp1.xyz;
                                output.tangentWS = input.interp2.xyzw;
                                output.viewDirectionWS = input.interp3.xyz;
                                #if defined(LIGHTMAP_ON)
                                output.lightmapUV = input.interp4.xy;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                output.sh = input.interp5.xyz;
                                #endif
                                output.fogFactorAndVertexLight = input.interp6.xyzw;
                                output.shadowCoord = input.interp7.xyzw;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }


                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float4 _Diffuse_TexelSize;
                            float _Scale;
                            float4 _Color;
                            float2 _Tiling;
                            float2 _Offset;
                            float3 _Rotation;
                            CBUFFER_END

                                // Object and Global properties
                                SAMPLER(SamplerState_Linear_Repeat);
                                TEXTURE2D(_Diffuse);
                                SAMPLER(sampler_Diffuse);
                                TEXTURE2D(_NormalMap);
                                SAMPLER(sampler_NormalMap);
                                float4 _NormalMap_TexelSize;

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Includes
                                // GraphIncludes: <None>

                                // Graph Functions

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }

                                void Unity_Add_float(float A, float B, out float Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                {
                                    //rotation matrix
                                    Rotation = Rotation * (3.1415926f / 180.0f);
                                    UV -= Center;
                                    float s = sin(Rotation);
                                    float c = cos(Rotation);

                                    //center rotation matrix
                                    float2x2 rMatrix = float2x2(c, -s, s, c);
                                    rMatrix *= 0.5;
                                    rMatrix += 0.5;
                                    rMatrix = rMatrix * 2 - 1;

                                    //multiply the UVs by the rotation matrix
                                    UV.xy = mul(UV.xy, rMatrix);
                                    UV += Center;

                                    Out = UV;
                                }

                                void Unity_Absolute_float3(float3 In, out float3 Out)
                                {
                                    Out = abs(In);
                                }

                                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                {
                                    Out = A + B;
                                }

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    description.Position = IN.ObjectSpacePosition;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float3 BaseColor;
                                    float3 NormalTS;
                                    float3 Emission;
                                    float Metallic;
                                    float Smoothness;
                                    float Occlusion;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    UnityTexture2D _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
                                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1 = IN.WorldSpacePosition[0];
                                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2 = IN.WorldSpacePosition[1];
                                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3 = IN.WorldSpacePosition[2];
                                    float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_A_4 = 0;
                                    float2 _Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                                    float _Property_6d6d799069c64bbc88c7d493d1c58034_Out_0 = _Scale;
                                    float _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2;
                                    Unity_Divide_float(_Property_6d6d799069c64bbc88c7d493d1c58034_Out_0, 10, _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2);
                                    float2 _Multiply_3873f65859374cdeabc7870ff773a003_Out_2;
                                    Unity_Multiply_float2_float2(_Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_3873f65859374cdeabc7870ff773a003_Out_2);
                                    float2 _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0 = _Tiling;
                                    float2 _Property_ca329b23ebcb474bac30accc465470e6_Out_0 = _Offset;
                                    float2 _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3;
                                    Unity_TilingAndOffset_float(_Multiply_3873f65859374cdeabc7870ff773a003_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3);
                                    float3 _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0 = _Rotation;
                                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_R_1 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[0];
                                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[1];
                                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[2];
                                    float _Split_e1478dd0b1e249edbcc837c52d3085bd_A_4 = 0;
                                    float _Add_f8432701c63d41a696f14f76b6a0990c_Out_2;
                                    Unity_Add_float(_Split_e1478dd0b1e249edbcc837c52d3085bd_R_1, 90, _Add_f8432701c63d41a696f14f76b6a0990c_Out_2);
                                    float2 _Rotate_43b6a3c764a04562821ce221efda444f_Out_3;
                                    Unity_Rotate_Degrees_float(_TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3, float2 (0, 0), _Add_f8432701c63d41a696f14f76b6a0990c_Out_2, _Rotate_43b6a3c764a04562821ce221efda444f_Out_3);
                                    float4 _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_43b6a3c764a04562821ce221efda444f_Out_3));
                                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_R_4 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.r;
                                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_G_5 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.g;
                                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_B_6 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.b;
                                    float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_A_7 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.a;
                                    float3 _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1;
                                    Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1);
                                    float3 _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2;
                                    Unity_Multiply_float3_float3(_Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2);
                                    float _Split_54452dbfaa174a36ba0a54d33c331027_R_1 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[0];
                                    float _Split_54452dbfaa174a36ba0a54d33c331027_G_2 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[1];
                                    float _Split_54452dbfaa174a36ba0a54d33c331027_B_3 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[2];
                                    float _Split_54452dbfaa174a36ba0a54d33c331027_A_4 = 0;
                                    float4 _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2;
                                    Unity_Multiply_float4_float4(_SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_R_1.xxxx), _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2);
                                    float2 _Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                                    float2 _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2;
                                    Unity_Multiply_float2_float2(_Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2);
                                    float2 _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3;
                                    Unity_TilingAndOffset_float(_Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3);
                                    float2 _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3;
                                    Unity_Rotate_Degrees_float(_TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2, _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3);
                                    float4 _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3));
                                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_R_4 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.r;
                                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_G_5 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.g;
                                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_B_6 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.b;
                                    float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_A_7 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.a;
                                    float4 _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2;
                                    Unity_Multiply_float4_float4(_SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_G_2.xxxx), _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2);
                                    float2 _Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2);
                                    float2 _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2;
                                    Unity_Multiply_float2_float2(_Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2);
                                    float2 _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3;
                                    Unity_TilingAndOffset_float(_Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3);
                                    float2 _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3;
                                    Unity_Rotate_Degrees_float(_TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3, _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3);
                                    float4 _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3));
                                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_R_4 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.r;
                                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_G_5 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.g;
                                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_B_6 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.b;
                                    float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_A_7 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.a;
                                    float4 _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2;
                                    Unity_Multiply_float4_float4(_SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_B_3.xxxx), _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2);
                                    float4 _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2;
                                    Unity_Add_float4(_Multiply_7617318190a54cacbce577ac28ea38b6_Out_2, _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2);
                                    float4 _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2;
                                    Unity_Add_float4(_Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2, _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2);
                                    float4 _Property_068392aad9f244c69363de540e8985da_Out_0 = _Color;
                                    float4 _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2;
                                    Unity_Multiply_float4_float4(_Add_411fef93f66044fb85c7d2b2be126c6f_Out_2, _Property_068392aad9f244c69363de540e8985da_Out_0, _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2);
                                    surface.BaseColor = (_Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2.xyz);
                                    surface.NormalTS = IN.TangentSpaceNormal;
                                    surface.Emission = float3(0, 0, 0);
                                    surface.Metallic = 0;
                                    surface.Smoothness = 0.5;
                                    surface.Occlusion = 1;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs

                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                    float3 unnormalizedNormalWS = input.normalWS;
                                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                    output.WorldSpacePosition = input.positionWS;
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                }

                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                {
                                    result.vertex = float4(attributes.positionOS, 1);
                                    result.tangent = attributes.tangentOS;
                                    result.normal = attributes.normalOS;
                                    result.texcoord1 = attributes.uv1;
                                    result.vertex = float4(vertexDescription.Position, 1);
                                    result.normal = vertexDescription.Normal;
                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                }

                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                {
                                    result.pos = varyings.positionCS;
                                    result.worldPos = varyings.positionWS;
                                    result.worldNormal = varyings.normalWS;
                                    result.viewDir = varyings.viewDirectionWS;
                                    // World Tangent isn't an available input on v2f_surf

                                    result._ShadowCoord = varyings.shadowCoord;

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    result.sh = varyings.sh;
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    result.lmap.xy = varyings.lightmapUV;
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                }

                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                {
                                    result.positionCS = surfVertex.pos;
                                    result.positionWS = surfVertex.worldPos;
                                    result.normalWS = surfVertex.worldNormal;
                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                    // World Tangent isn't an available input on v2f_surf
                                    result.shadowCoord = surfVertex._ShadowCoord;

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    result.sh = surfVertex.sh;
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    result.lightmapUV = surfVertex.lmap.xy;
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                }

                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

                                ENDHLSL
                                }
                                Pass
                                {
                                    Name "ShadowCaster"
                                    Tags
                                    {
                                        "LightMode" = "ShadowCaster"
                                    }

                                    // Render State
                                    Cull Back
                                    Blend One Zero
                                    ZTest LEqual
                                    ZWrite On
                                    ColorMask 0

                                    // Debug
                                    // <None>

                                    // --------------------------------------------------
                                    // Pass

                                    HLSLPROGRAM

                                    // Pragmas
                                    #pragma target 3.0
                                    #pragma multi_compile_shadowcaster
                                    #pragma vertex vert
                                    #pragma fragment frag

                                    // DotsInstancingOptions: <None>
                                    // HybridV1InjectedBuiltinProperties: <None>

                                    // Keywords
                                    #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                    // GraphKeywords: <None>

                                    // Defines
                                    #define _NORMALMAP 1
                                    #define _NORMAL_DROPOFF_TS 1
                                    #define ATTRIBUTES_NEED_NORMAL
                                    #define ATTRIBUTES_NEED_TANGENT
                                    #define FEATURES_GRAPH_VERTEX
                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                                    #define BUILTIN_TARGET_API 1
                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                    #endif
                                    #ifdef _BUILTIN_ALPHATEST_ON
                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                    #endif
                                    #ifdef _BUILTIN_AlphaClip
                                    #define _AlphaClip _BUILTIN_AlphaClip
                                    #endif
                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                    #endif


                                    // custom interpolator pre-include
                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                    // Includes
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                    // --------------------------------------------------
                                    // Structs and Packing

                                    // custom interpolators pre packing
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                    struct Attributes
                                    {
                                         float3 positionOS : POSITION;
                                         float3 normalOS : NORMAL;
                                         float4 tangentOS : TANGENT;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : INSTANCEID_SEMANTIC;
                                        #endif
                                    };
                                    struct Varyings
                                    {
                                         float4 positionCS : SV_POSITION;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };
                                    struct SurfaceDescriptionInputs
                                    {
                                    };
                                    struct VertexDescriptionInputs
                                    {
                                         float3 ObjectSpaceNormal;
                                         float3 ObjectSpaceTangent;
                                         float3 ObjectSpacePosition;
                                    };
                                    struct PackedVaryings
                                    {
                                         float4 positionCS : SV_POSITION;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };

                                    PackedVaryings PackVaryings(Varyings input)
                                    {
                                        PackedVaryings output;
                                        ZERO_INITIALIZE(PackedVaryings, output);
                                        output.positionCS = input.positionCS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }

                                    Varyings UnpackVaryings(PackedVaryings input)
                                    {
                                        Varyings output;
                                        output.positionCS = input.positionCS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }


                                    // --------------------------------------------------
                                    // Graph

                                    // Graph Properties
                                    CBUFFER_START(UnityPerMaterial)
                                    float4 _Diffuse_TexelSize;
                                    float _Scale;
                                    float4 _Color;
                                    float2 _Tiling;
                                    float2 _Offset;
                                    float3 _Rotation;
                                    CBUFFER_END

                                        // Object and Global properties
                                        SAMPLER(SamplerState_Linear_Repeat);
                                        TEXTURE2D(_Diffuse);
                                        SAMPLER(sampler_Diffuse);
                                        TEXTURE2D(_NormalMap);
                                        SAMPLER(sampler_NormalMap);
                                        float4 _NormalMap_TexelSize;

                                        // -- Property used by ScenePickingPass
                                        #ifdef SCENEPICKINGPASS
                                        float4 _SelectionID;
                                        #endif

                                        // -- Properties used by SceneSelectionPass
                                        #ifdef SCENESELECTIONPASS
                                        int _ObjectId;
                                        int _PassValue;
                                        #endif

                                        // Graph Includes
                                        // GraphIncludes: <None>

                                        // Graph Functions
                                        // GraphFunctions: <None>

                                        // Custom interpolators pre vertex
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                        // Graph Vertex
                                        struct VertexDescription
                                        {
                                            float3 Position;
                                            float3 Normal;
                                            float3 Tangent;
                                        };

                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                        {
                                            VertexDescription description = (VertexDescription)0;
                                            description.Position = IN.ObjectSpacePosition;
                                            description.Normal = IN.ObjectSpaceNormal;
                                            description.Tangent = IN.ObjectSpaceTangent;
                                            return description;
                                        }

                                        // Custom interpolators, pre surface
                                        #ifdef FEATURES_GRAPH_VERTEX
                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                        {
                                        return output;
                                        }
                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                        #endif

                                        // Graph Pixel
                                        struct SurfaceDescription
                                        {
                                        };

                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                        {
                                            SurfaceDescription surface = (SurfaceDescription)0;
                                            return surface;
                                        }

                                        // --------------------------------------------------
                                        // Build Graph Inputs

                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                        {
                                            VertexDescriptionInputs output;
                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                            output.ObjectSpaceNormal = input.normalOS;
                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                            output.ObjectSpacePosition = input.positionOS;

                                            return output;
                                        }
                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                        {
                                            SurfaceDescriptionInputs output;
                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                        #else
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                        #endif
                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                return output;
                                        }

                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                        {
                                            result.vertex = float4(attributes.positionOS, 1);
                                            result.tangent = attributes.tangentOS;
                                            result.normal = attributes.normalOS;
                                            result.vertex = float4(vertexDescription.Position, 1);
                                            result.normal = vertexDescription.Normal;
                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                        }

                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                        {
                                            result.pos = varyings.positionCS;
                                            // World Tangent isn't an available input on v2f_surf


                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                            #if UNITY_SHOULD_SAMPLE_SH
                                            #endif
                                            #if defined(LIGHTMAP_ON)
                                            #endif
                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                            #endif

                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                        }

                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                        {
                                            result.positionCS = surfVertex.pos;
                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                            // World Tangent isn't an available input on v2f_surf

                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                            #if UNITY_SHOULD_SAMPLE_SH
                                            #endif
                                            #if defined(LIGHTMAP_ON)
                                            #endif
                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                            #endif

                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                        }

                                        // --------------------------------------------------
                                        // Main

                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                        ENDHLSL
                                        }
                                        Pass
                                        {
                                            Name "DepthOnly"
                                            Tags
                                            {
                                                "LightMode" = "DepthOnly"
                                            }

                                            // Render State
                                            Cull Back
                                            Blend One Zero
                                            ZTest LEqual
                                            ZWrite On
                                            ColorMask 0

                                            // Debug
                                            // <None>

                                            // --------------------------------------------------
                                            // Pass

                                            HLSLPROGRAM

                                            // Pragmas
                                            #pragma target 3.0
                                            #pragma multi_compile_instancing
                                            #pragma vertex vert
                                            #pragma fragment frag

                                            // DotsInstancingOptions: <None>
                                            // HybridV1InjectedBuiltinProperties: <None>

                                            // Keywords
                                            // PassKeywords: <None>
                                            // GraphKeywords: <None>

                                            // Defines
                                            #define _NORMALMAP 1
                                            #define _NORMAL_DROPOFF_TS 1
                                            #define ATTRIBUTES_NEED_NORMAL
                                            #define ATTRIBUTES_NEED_TANGENT
                                            #define FEATURES_GRAPH_VERTEX
                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                            #define SHADERPASS SHADERPASS_DEPTHONLY
                                            #define BUILTIN_TARGET_API 1
                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                            #endif
                                            #ifdef _BUILTIN_ALPHATEST_ON
                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                            #endif
                                            #ifdef _BUILTIN_AlphaClip
                                            #define _AlphaClip _BUILTIN_AlphaClip
                                            #endif
                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                            #endif


                                            // custom interpolator pre-include
                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                            // Includes
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                            // --------------------------------------------------
                                            // Structs and Packing

                                            // custom interpolators pre packing
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                            struct Attributes
                                            {
                                                 float3 positionOS : POSITION;
                                                 float3 normalOS : NORMAL;
                                                 float4 tangentOS : TANGENT;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                #endif
                                            };
                                            struct Varyings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };
                                            struct SurfaceDescriptionInputs
                                            {
                                            };
                                            struct VertexDescriptionInputs
                                            {
                                                 float3 ObjectSpaceNormal;
                                                 float3 ObjectSpaceTangent;
                                                 float3 ObjectSpacePosition;
                                            };
                                            struct PackedVaryings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };

                                            PackedVaryings PackVaryings(Varyings input)
                                            {
                                                PackedVaryings output;
                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                output.positionCS = input.positionCS;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }

                                            Varyings UnpackVaryings(PackedVaryings input)
                                            {
                                                Varyings output;
                                                output.positionCS = input.positionCS;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }


                                            // --------------------------------------------------
                                            // Graph

                                            // Graph Properties
                                            CBUFFER_START(UnityPerMaterial)
                                            float4 _Diffuse_TexelSize;
                                            float _Scale;
                                            float4 _Color;
                                            float2 _Tiling;
                                            float2 _Offset;
                                            float3 _Rotation;
                                            CBUFFER_END

                                                // Object and Global properties
                                                SAMPLER(SamplerState_Linear_Repeat);
                                                TEXTURE2D(_Diffuse);
                                                SAMPLER(sampler_Diffuse);
                                                TEXTURE2D(_NormalMap);
                                                SAMPLER(sampler_NormalMap);
                                                float4 _NormalMap_TexelSize;

                                                // -- Property used by ScenePickingPass
                                                #ifdef SCENEPICKINGPASS
                                                float4 _SelectionID;
                                                #endif

                                                // -- Properties used by SceneSelectionPass
                                                #ifdef SCENESELECTIONPASS
                                                int _ObjectId;
                                                int _PassValue;
                                                #endif

                                                // Graph Includes
                                                // GraphIncludes: <None>

                                                // Graph Functions
                                                // GraphFunctions: <None>

                                                // Custom interpolators pre vertex
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                // Graph Vertex
                                                struct VertexDescription
                                                {
                                                    float3 Position;
                                                    float3 Normal;
                                                    float3 Tangent;
                                                };

                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                {
                                                    VertexDescription description = (VertexDescription)0;
                                                    description.Position = IN.ObjectSpacePosition;
                                                    description.Normal = IN.ObjectSpaceNormal;
                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                    return description;
                                                }

                                                // Custom interpolators, pre surface
                                                #ifdef FEATURES_GRAPH_VERTEX
                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                {
                                                return output;
                                                }
                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                #endif

                                                // Graph Pixel
                                                struct SurfaceDescription
                                                {
                                                };

                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                {
                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                    return surface;
                                                }

                                                // --------------------------------------------------
                                                // Build Graph Inputs

                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                {
                                                    VertexDescriptionInputs output;
                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                    output.ObjectSpaceNormal = input.normalOS;
                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                    output.ObjectSpacePosition = input.positionOS;

                                                    return output;
                                                }
                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                {
                                                    SurfaceDescriptionInputs output;
                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                #else
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                #endif
                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                        return output;
                                                }

                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                {
                                                    result.vertex = float4(attributes.positionOS, 1);
                                                    result.tangent = attributes.tangentOS;
                                                    result.normal = attributes.normalOS;
                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                    result.normal = vertexDescription.Normal;
                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                }

                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                {
                                                    result.pos = varyings.positionCS;
                                                    // World Tangent isn't an available input on v2f_surf


                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                    #endif
                                                    #if defined(LIGHTMAP_ON)
                                                    #endif
                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                    #endif

                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                }

                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                {
                                                    result.positionCS = surfVertex.pos;
                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                    // World Tangent isn't an available input on v2f_surf

                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                    #endif
                                                    #if defined(LIGHTMAP_ON)
                                                    #endif
                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                    #endif

                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                }

                                                // --------------------------------------------------
                                                // Main

                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                ENDHLSL
                                                }
                                                Pass
                                                {
                                                    Name "Meta"
                                                    Tags
                                                    {
                                                        "LightMode" = "Meta"
                                                    }

                                                    // Render State
                                                    Cull Off

                                                    // Debug
                                                    // <None>

                                                    // --------------------------------------------------
                                                    // Pass

                                                    HLSLPROGRAM

                                                    // Pragmas
                                                    #pragma target 3.0
                                                    #pragma vertex vert
                                                    #pragma fragment frag

                                                    // DotsInstancingOptions: <None>
                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                    // Keywords
                                                    #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                                    // GraphKeywords: <None>

                                                    // Defines
                                                    #define _NORMALMAP 1
                                                    #define _NORMAL_DROPOFF_TS 1
                                                    #define ATTRIBUTES_NEED_NORMAL
                                                    #define ATTRIBUTES_NEED_TANGENT
                                                    #define ATTRIBUTES_NEED_TEXCOORD1
                                                    #define ATTRIBUTES_NEED_TEXCOORD2
                                                    #define VARYINGS_NEED_POSITION_WS
                                                    #define VARYINGS_NEED_NORMAL_WS
                                                    #define FEATURES_GRAPH_VERTEX
                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                    #define SHADERPASS SHADERPASS_META
                                                    #define BUILTIN_TARGET_API 1
                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                    #endif
                                                    #ifdef _BUILTIN_ALPHATEST_ON
                                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                    #endif
                                                    #ifdef _BUILTIN_AlphaClip
                                                    #define _AlphaClip _BUILTIN_AlphaClip
                                                    #endif
                                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                    #endif


                                                    // custom interpolator pre-include
                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                    // Includes
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                    // --------------------------------------------------
                                                    // Structs and Packing

                                                    // custom interpolators pre packing
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                    struct Attributes
                                                    {
                                                         float3 positionOS : POSITION;
                                                         float3 normalOS : NORMAL;
                                                         float4 tangentOS : TANGENT;
                                                         float4 uv1 : TEXCOORD1;
                                                         float4 uv2 : TEXCOORD2;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct Varyings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                         float3 positionWS;
                                                         float3 normalWS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct SurfaceDescriptionInputs
                                                    {
                                                         float3 WorldSpaceNormal;
                                                         float3 WorldSpacePosition;
                                                    };
                                                    struct VertexDescriptionInputs
                                                    {
                                                         float3 ObjectSpaceNormal;
                                                         float3 ObjectSpaceTangent;
                                                         float3 ObjectSpacePosition;
                                                    };
                                                    struct PackedVaryings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                         float3 interp0 : INTERP0;
                                                         float3 interp1 : INTERP1;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };

                                                    PackedVaryings PackVaryings(Varyings input)
                                                    {
                                                        PackedVaryings output;
                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                        output.positionCS = input.positionCS;
                                                        output.interp0.xyz = input.positionWS;
                                                        output.interp1.xyz = input.normalWS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }

                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                    {
                                                        Varyings output;
                                                        output.positionCS = input.positionCS;
                                                        output.positionWS = input.interp0.xyz;
                                                        output.normalWS = input.interp1.xyz;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }


                                                    // --------------------------------------------------
                                                    // Graph

                                                    // Graph Properties
                                                    CBUFFER_START(UnityPerMaterial)
                                                    float4 _Diffuse_TexelSize;
                                                    float _Scale;
                                                    float4 _Color;
                                                    float2 _Tiling;
                                                    float2 _Offset;
                                                    float3 _Rotation;
                                                    CBUFFER_END

                                                        // Object and Global properties
                                                        SAMPLER(SamplerState_Linear_Repeat);
                                                        TEXTURE2D(_Diffuse);
                                                        SAMPLER(sampler_Diffuse);
                                                        TEXTURE2D(_NormalMap);
                                                        SAMPLER(sampler_NormalMap);
                                                        float4 _NormalMap_TexelSize;

                                                        // -- Property used by ScenePickingPass
                                                        #ifdef SCENEPICKINGPASS
                                                        float4 _SelectionID;
                                                        #endif

                                                        // -- Properties used by SceneSelectionPass
                                                        #ifdef SCENESELECTIONPASS
                                                        int _ObjectId;
                                                        int _PassValue;
                                                        #endif

                                                        // Graph Includes
                                                        // GraphIncludes: <None>

                                                        // Graph Functions

                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                        {
                                                            Out = UV * Tiling + Offset;
                                                        }

                                                        void Unity_Add_float(float A, float B, out float Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                                                        {
                                                            //rotation matrix
                                                            Rotation = Rotation * (3.1415926f / 180.0f);
                                                            UV -= Center;
                                                            float s = sin(Rotation);
                                                            float c = cos(Rotation);

                                                            //center rotation matrix
                                                            float2x2 rMatrix = float2x2(c, -s, s, c);
                                                            rMatrix *= 0.5;
                                                            rMatrix += 0.5;
                                                            rMatrix = rMatrix * 2 - 1;

                                                            //multiply the UVs by the rotation matrix
                                                            UV.xy = mul(UV.xy, rMatrix);
                                                            UV += Center;

                                                            Out = UV;
                                                        }

                                                        void Unity_Absolute_float3(float3 In, out float3 Out)
                                                        {
                                                            Out = abs(In);
                                                        }

                                                        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        // Custom interpolators pre vertex
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                        // Graph Vertex
                                                        struct VertexDescription
                                                        {
                                                            float3 Position;
                                                            float3 Normal;
                                                            float3 Tangent;
                                                        };

                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                        {
                                                            VertexDescription description = (VertexDescription)0;
                                                            description.Position = IN.ObjectSpacePosition;
                                                            description.Normal = IN.ObjectSpaceNormal;
                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                            return description;
                                                        }

                                                        // Custom interpolators, pre surface
                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                        {
                                                        return output;
                                                        }
                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                        #endif

                                                        // Graph Pixel
                                                        struct SurfaceDescription
                                                        {
                                                            float3 BaseColor;
                                                            float3 Emission;
                                                        };

                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                        {
                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                            UnityTexture2D _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0 = UnityBuildTexture2DStructNoScale(_Diffuse);
                                                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1 = IN.WorldSpacePosition[0];
                                                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2 = IN.WorldSpacePosition[1];
                                                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3 = IN.WorldSpacePosition[2];
                                                            float _Split_353bc6fd06a04cd2ad6f02f9caee50ae_A_4 = 0;
                                                            float2 _Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                                                            float _Property_6d6d799069c64bbc88c7d493d1c58034_Out_0 = _Scale;
                                                            float _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2;
                                                            Unity_Divide_float(_Property_6d6d799069c64bbc88c7d493d1c58034_Out_0, 10, _Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2);
                                                            float2 _Multiply_3873f65859374cdeabc7870ff773a003_Out_2;
                                                            Unity_Multiply_float2_float2(_Vector2_4ca43656134442f29b4ffd1afc32e8e5_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_3873f65859374cdeabc7870ff773a003_Out_2);
                                                            float2 _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0 = _Tiling;
                                                            float2 _Property_ca329b23ebcb474bac30accc465470e6_Out_0 = _Offset;
                                                            float2 _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3;
                                                            Unity_TilingAndOffset_float(_Multiply_3873f65859374cdeabc7870ff773a003_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3);
                                                            float3 _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0 = _Rotation;
                                                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_R_1 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[0];
                                                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[1];
                                                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3 = _Property_eb9ffaa4bb08487b926d46c5bade9fab_Out_0[2];
                                                            float _Split_e1478dd0b1e249edbcc837c52d3085bd_A_4 = 0;
                                                            float _Add_f8432701c63d41a696f14f76b6a0990c_Out_2;
                                                            Unity_Add_float(_Split_e1478dd0b1e249edbcc837c52d3085bd_R_1, 90, _Add_f8432701c63d41a696f14f76b6a0990c_Out_2);
                                                            float2 _Rotate_43b6a3c764a04562821ce221efda444f_Out_3;
                                                            Unity_Rotate_Degrees_float(_TilingAndOffset_b6d30046f8a74ee1b02a2437ef66e700_Out_3, float2 (0, 0), _Add_f8432701c63d41a696f14f76b6a0990c_Out_2, _Rotate_43b6a3c764a04562821ce221efda444f_Out_3);
                                                            float4 _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_43b6a3c764a04562821ce221efda444f_Out_3));
                                                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_R_4 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.r;
                                                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_G_5 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.g;
                                                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_B_6 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.b;
                                                            float _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_A_7 = _SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0.a;
                                                            float3 _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1;
                                                            Unity_Absolute_float3(IN.WorldSpaceNormal, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1);
                                                            float3 _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2;
                                                            Unity_Multiply_float3_float3(_Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Absolute_6c1febf1755c4f01a69c05e9ef5a4eba_Out_1, _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2);
                                                            float _Split_54452dbfaa174a36ba0a54d33c331027_R_1 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[0];
                                                            float _Split_54452dbfaa174a36ba0a54d33c331027_G_2 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[1];
                                                            float _Split_54452dbfaa174a36ba0a54d33c331027_B_3 = _Multiply_b3296d36c169412db5fb33d641c43a5b_Out_2[2];
                                                            float _Split_54452dbfaa174a36ba0a54d33c331027_A_4 = 0;
                                                            float4 _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2;
                                                            Unity_Multiply_float4_float4(_SampleTexture2D_2138a20e9dcf45538c72f12b65fab25e_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_R_1.xxxx), _Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2);
                                                            float2 _Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_B_3);
                                                            float2 _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2;
                                                            Unity_Multiply_float2_float2(_Vector2_4ca261d8ecb94d5ebdd432a8660bd5de_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2);
                                                            float2 _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3;
                                                            Unity_TilingAndOffset_float(_Multiply_868625b1a0254e6abef1e4f2bdefe5e3_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3);
                                                            float2 _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3;
                                                            Unity_Rotate_Degrees_float(_TilingAndOffset_f5aa5d1042cb4a928c2c631ea2751abd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_G_2, _Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3);
                                                            float4 _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_1fa49c9cba2541af884d770f822a72fc_Out_3));
                                                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_R_4 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.r;
                                                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_G_5 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.g;
                                                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_B_6 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.b;
                                                            float _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_A_7 = _SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0.a;
                                                            float4 _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2;
                                                            Unity_Multiply_float4_float4(_SampleTexture2D_74b23c8a989340fa8027590c1cc7fa59_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_G_2.xxxx), _Multiply_7617318190a54cacbce577ac28ea38b6_Out_2);
                                                            float2 _Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0 = float2(_Split_353bc6fd06a04cd2ad6f02f9caee50ae_R_1, _Split_353bc6fd06a04cd2ad6f02f9caee50ae_G_2);
                                                            float2 _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2;
                                                            Unity_Multiply_float2_float2(_Vector2_8ddeb0c52d804030a0dc390d4fab0cf0_Out_0, (_Divide_bb399920afc64bb59a5fb0aabb70bae6_Out_2.xx), _Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2);
                                                            float2 _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3;
                                                            Unity_TilingAndOffset_float(_Multiply_d30e1693375949c48d2e9e6b6fda345e_Out_2, _Property_3f44f3597b5a47a099a3f19dbff98d06_Out_0, _Property_ca329b23ebcb474bac30accc465470e6_Out_0, _TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3);
                                                            float2 _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3;
                                                            Unity_Rotate_Degrees_float(_TilingAndOffset_da7cdcc099884d35adf592232e3beedd_Out_3, float2 (0, 0), _Split_e1478dd0b1e249edbcc837c52d3085bd_B_3, _Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3);
                                                            float4 _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0 = SAMPLE_TEXTURE2D(_Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.tex, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.samplerstate, _Property_0ca6f40b271c4ffb81e7ff436736d8d3_Out_0.GetTransformedUV(_Rotate_92c5f8b862c94bc29bfd90ce991c6077_Out_3));
                                                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_R_4 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.r;
                                                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_G_5 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.g;
                                                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_B_6 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.b;
                                                            float _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_A_7 = _SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0.a;
                                                            float4 _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2;
                                                            Unity_Multiply_float4_float4(_SampleTexture2D_e1e08c06e5e54af382fbb08c742df0db_RGBA_0, (_Split_54452dbfaa174a36ba0a54d33c331027_B_3.xxxx), _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2);
                                                            float4 _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2;
                                                            Unity_Add_float4(_Multiply_7617318190a54cacbce577ac28ea38b6_Out_2, _Multiply_c6f66face77649ea9eb974e09c908c9d_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2);
                                                            float4 _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2;
                                                            Unity_Add_float4(_Multiply_f44879529be94ee9a27c267774a6fbe9_Out_2, _Add_691706864a0f4265b3fa7b3f89f5510b_Out_2, _Add_411fef93f66044fb85c7d2b2be126c6f_Out_2);
                                                            float4 _Property_068392aad9f244c69363de540e8985da_Out_0 = _Color;
                                                            float4 _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2;
                                                            Unity_Multiply_float4_float4(_Add_411fef93f66044fb85c7d2b2be126c6f_Out_2, _Property_068392aad9f244c69363de540e8985da_Out_0, _Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2);
                                                            surface.BaseColor = (_Multiply_de7cade0dd7f47c28bfca186d2946b9d_Out_2.xyz);
                                                            surface.Emission = float3(0, 0, 0);
                                                            return surface;
                                                        }

                                                        // --------------------------------------------------
                                                        // Build Graph Inputs

                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                        {
                                                            VertexDescriptionInputs output;
                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                            output.ObjectSpaceNormal = input.normalOS;
                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                            output.ObjectSpacePosition = input.positionOS;

                                                            return output;
                                                        }
                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                        {
                                                            SurfaceDescriptionInputs output;
                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                                            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                            float3 unnormalizedNormalWS = input.normalWS;
                                                            const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                                            output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                                            output.WorldSpacePosition = input.positionWS;
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                        #else
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                        #endif
                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                return output;
                                                        }

                                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                        {
                                                            result.vertex = float4(attributes.positionOS, 1);
                                                            result.tangent = attributes.tangentOS;
                                                            result.normal = attributes.normalOS;
                                                            result.texcoord1 = attributes.uv1;
                                                            result.texcoord2 = attributes.uv2;
                                                            result.vertex = float4(vertexDescription.Position, 1);
                                                            result.normal = vertexDescription.Normal;
                                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                        }

                                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                        {
                                                            result.pos = varyings.positionCS;
                                                            result.worldPos = varyings.positionWS;
                                                            result.worldNormal = varyings.normalWS;
                                                            // World Tangent isn't an available input on v2f_surf


                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                            #endif
                                                            #if defined(LIGHTMAP_ON)
                                                            #endif
                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                            #endif

                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                        }

                                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                        {
                                                            result.positionCS = surfVertex.pos;
                                                            result.positionWS = surfVertex.worldPos;
                                                            result.normalWS = surfVertex.worldNormal;
                                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                            // World Tangent isn't an available input on v2f_surf

                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                            #endif
                                                            #if defined(LIGHTMAP_ON)
                                                            #endif
                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                            #endif

                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                        }

                                                        // --------------------------------------------------
                                                        // Main

                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                        ENDHLSL
                                                        }
                                                        Pass
                                                        {
                                                            Name "SceneSelectionPass"
                                                            Tags
                                                            {
                                                                "LightMode" = "SceneSelectionPass"
                                                            }

                                                            // Render State
                                                            Cull Off

                                                            // Debug
                                                            // <None>

                                                            // --------------------------------------------------
                                                            // Pass

                                                            HLSLPROGRAM

                                                            // Pragmas
                                                            #pragma target 3.0
                                                            #pragma multi_compile_instancing
                                                            #pragma vertex vert
                                                            #pragma fragment frag

                                                            // DotsInstancingOptions: <None>
                                                            // HybridV1InjectedBuiltinProperties: <None>

                                                            // Keywords
                                                            // PassKeywords: <None>
                                                            // GraphKeywords: <None>

                                                            // Defines
                                                            #define _NORMALMAP 1
                                                            #define _NORMAL_DROPOFF_TS 1
                                                            #define ATTRIBUTES_NEED_NORMAL
                                                            #define ATTRIBUTES_NEED_TANGENT
                                                            #define FEATURES_GRAPH_VERTEX
                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                            #define SHADERPASS SceneSelectionPass
                                                            #define BUILTIN_TARGET_API 1
                                                            #define SCENESELECTIONPASS 1
                                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                            #endif
                                                            #ifdef _BUILTIN_ALPHATEST_ON
                                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                            #endif
                                                            #ifdef _BUILTIN_AlphaClip
                                                            #define _AlphaClip _BUILTIN_AlphaClip
                                                            #endif
                                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                            #endif


                                                            // custom interpolator pre-include
                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                            // Includes
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                            // --------------------------------------------------
                                                            // Structs and Packing

                                                            // custom interpolators pre packing
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                            struct Attributes
                                                            {
                                                                 float3 positionOS : POSITION;
                                                                 float3 normalOS : NORMAL;
                                                                 float4 tangentOS : TANGENT;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct Varyings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct SurfaceDescriptionInputs
                                                            {
                                                            };
                                                            struct VertexDescriptionInputs
                                                            {
                                                                 float3 ObjectSpaceNormal;
                                                                 float3 ObjectSpaceTangent;
                                                                 float3 ObjectSpacePosition;
                                                            };
                                                            struct PackedVaryings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };

                                                            PackedVaryings PackVaryings(Varyings input)
                                                            {
                                                                PackedVaryings output;
                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                output.positionCS = input.positionCS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }

                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                            {
                                                                Varyings output;
                                                                output.positionCS = input.positionCS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }


                                                            // --------------------------------------------------
                                                            // Graph

                                                            // Graph Properties
                                                            CBUFFER_START(UnityPerMaterial)
                                                            float4 _Diffuse_TexelSize;
                                                            float _Scale;
                                                            float4 _Color;
                                                            float2 _Tiling;
                                                            float2 _Offset;
                                                            float3 _Rotation;
                                                            CBUFFER_END

                                                                // Object and Global properties
                                                                SAMPLER(SamplerState_Linear_Repeat);
                                                                TEXTURE2D(_Diffuse);
                                                                SAMPLER(sampler_Diffuse);
                                                                TEXTURE2D(_NormalMap);
                                                                SAMPLER(sampler_NormalMap);
                                                                float4 _NormalMap_TexelSize;

                                                                // -- Property used by ScenePickingPass
                                                                #ifdef SCENEPICKINGPASS
                                                                float4 _SelectionID;
                                                                #endif

                                                                // -- Properties used by SceneSelectionPass
                                                                #ifdef SCENESELECTIONPASS
                                                                int _ObjectId;
                                                                int _PassValue;
                                                                #endif

                                                                // Graph Includes
                                                                // GraphIncludes: <None>

                                                                // Graph Functions
                                                                // GraphFunctions: <None>

                                                                // Custom interpolators pre vertex
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                // Graph Vertex
                                                                struct VertexDescription
                                                                {
                                                                    float3 Position;
                                                                    float3 Normal;
                                                                    float3 Tangent;
                                                                };

                                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                {
                                                                    VertexDescription description = (VertexDescription)0;
                                                                    description.Position = IN.ObjectSpacePosition;
                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                    return description;
                                                                }

                                                                // Custom interpolators, pre surface
                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                {
                                                                return output;
                                                                }
                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                #endif

                                                                // Graph Pixel
                                                                struct SurfaceDescription
                                                                {
                                                                };

                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                {
                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                    return surface;
                                                                }

                                                                // --------------------------------------------------
                                                                // Build Graph Inputs

                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                {
                                                                    VertexDescriptionInputs output;
                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                    output.ObjectSpacePosition = input.positionOS;

                                                                    return output;
                                                                }
                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                {
                                                                    SurfaceDescriptionInputs output;
                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                #else
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                #endif
                                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                        return output;
                                                                }

                                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                {
                                                                    result.vertex = float4(attributes.positionOS, 1);
                                                                    result.tangent = attributes.tangentOS;
                                                                    result.normal = attributes.normalOS;
                                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                                    result.normal = vertexDescription.Normal;
                                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                }

                                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                {
                                                                    result.pos = varyings.positionCS;
                                                                    // World Tangent isn't an available input on v2f_surf


                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                    #endif
                                                                    #if defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                    #endif

                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                }

                                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                {
                                                                    result.positionCS = surfVertex.pos;
                                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                    // World Tangent isn't an available input on v2f_surf

                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                    #endif
                                                                    #if defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                    #endif

                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                }

                                                                // --------------------------------------------------
                                                                // Main

                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                ENDHLSL
                                                                }
                                                                Pass
                                                                {
                                                                    Name "ScenePickingPass"
                                                                    Tags
                                                                    {
                                                                        "LightMode" = "Picking"
                                                                    }

                                                                    // Render State
                                                                    Cull Back

                                                                    // Debug
                                                                    // <None>

                                                                    // --------------------------------------------------
                                                                    // Pass

                                                                    HLSLPROGRAM

                                                                    // Pragmas
                                                                    #pragma target 3.0
                                                                    #pragma multi_compile_instancing
                                                                    #pragma vertex vert
                                                                    #pragma fragment frag

                                                                    // DotsInstancingOptions: <None>
                                                                    // HybridV1InjectedBuiltinProperties: <None>

                                                                    // Keywords
                                                                    // PassKeywords: <None>
                                                                    // GraphKeywords: <None>

                                                                    // Defines
                                                                    #define _NORMALMAP 1
                                                                    #define _NORMAL_DROPOFF_TS 1
                                                                    #define ATTRIBUTES_NEED_NORMAL
                                                                    #define ATTRIBUTES_NEED_TANGENT
                                                                    #define FEATURES_GRAPH_VERTEX
                                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                    #define SHADERPASS ScenePickingPass
                                                                    #define BUILTIN_TARGET_API 1
                                                                    #define SCENEPICKINGPASS 1
                                                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
                                                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                                    #endif
                                                                    #ifdef _BUILTIN_ALPHATEST_ON
                                                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                                    #endif
                                                                    #ifdef _BUILTIN_AlphaClip
                                                                    #define _AlphaClip _BUILTIN_AlphaClip
                                                                    #endif
                                                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                                    #endif


                                                                    // custom interpolator pre-include
                                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                    // Includes
                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Structs and Packing

                                                                    // custom interpolators pre packing
                                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                                    struct Attributes
                                                                    {
                                                                         float3 positionOS : POSITION;
                                                                         float3 normalOS : NORMAL;
                                                                         float4 tangentOS : TANGENT;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                                        #endif
                                                                    };
                                                                    struct Varyings
                                                                    {
                                                                         float4 positionCS : SV_POSITION;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                        #endif
                                                                    };
                                                                    struct SurfaceDescriptionInputs
                                                                    {
                                                                    };
                                                                    struct VertexDescriptionInputs
                                                                    {
                                                                         float3 ObjectSpaceNormal;
                                                                         float3 ObjectSpaceTangent;
                                                                         float3 ObjectSpacePosition;
                                                                    };
                                                                    struct PackedVaryings
                                                                    {
                                                                         float4 positionCS : SV_POSITION;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                        #endif
                                                                    };

                                                                    PackedVaryings PackVaryings(Varyings input)
                                                                    {
                                                                        PackedVaryings output;
                                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                                        output.positionCS = input.positionCS;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                        output.instanceID = input.instanceID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        output.cullFace = input.cullFace;
                                                                        #endif
                                                                        return output;
                                                                    }

                                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                                    {
                                                                        Varyings output;
                                                                        output.positionCS = input.positionCS;
                                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                                        output.instanceID = input.instanceID;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                        #endif
                                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                        #endif
                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        output.cullFace = input.cullFace;
                                                                        #endif
                                                                        return output;
                                                                    }


                                                                    // --------------------------------------------------
                                                                    // Graph

                                                                    // Graph Properties
                                                                    CBUFFER_START(UnityPerMaterial)
                                                                    float4 _Diffuse_TexelSize;
                                                                    float _Scale;
                                                                    float4 _Color;
                                                                    float2 _Tiling;
                                                                    float2 _Offset;
                                                                    float3 _Rotation;
                                                                    CBUFFER_END

                                                                        // Object and Global properties
                                                                        SAMPLER(SamplerState_Linear_Repeat);
                                                                        TEXTURE2D(_Diffuse);
                                                                        SAMPLER(sampler_Diffuse);
                                                                        TEXTURE2D(_NormalMap);
                                                                        SAMPLER(sampler_NormalMap);
                                                                        float4 _NormalMap_TexelSize;

                                                                        // -- Property used by ScenePickingPass
                                                                        #ifdef SCENEPICKINGPASS
                                                                        float4 _SelectionID;
                                                                        #endif

                                                                        // -- Properties used by SceneSelectionPass
                                                                        #ifdef SCENESELECTIONPASS
                                                                        int _ObjectId;
                                                                        int _PassValue;
                                                                        #endif

                                                                        // Graph Includes
                                                                        // GraphIncludes: <None>

                                                                        // Graph Functions
                                                                        // GraphFunctions: <None>

                                                                        // Custom interpolators pre vertex
                                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                        // Graph Vertex
                                                                        struct VertexDescription
                                                                        {
                                                                            float3 Position;
                                                                            float3 Normal;
                                                                            float3 Tangent;
                                                                        };

                                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                        {
                                                                            VertexDescription description = (VertexDescription)0;
                                                                            description.Position = IN.ObjectSpacePosition;
                                                                            description.Normal = IN.ObjectSpaceNormal;
                                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                                            return description;
                                                                        }

                                                                        // Custom interpolators, pre surface
                                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                        {
                                                                        return output;
                                                                        }
                                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                        #endif

                                                                        // Graph Pixel
                                                                        struct SurfaceDescription
                                                                        {
                                                                        };

                                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                        {
                                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                                            return surface;
                                                                        }

                                                                        // --------------------------------------------------
                                                                        // Build Graph Inputs

                                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                        {
                                                                            VertexDescriptionInputs output;
                                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                            output.ObjectSpaceNormal = input.normalOS;
                                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                            output.ObjectSpacePosition = input.positionOS;

                                                                            return output;
                                                                        }
                                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                        {
                                                                            SurfaceDescriptionInputs output;
                                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







                                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                        #else
                                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                        #endif
                                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                                return output;
                                                                        }

                                                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                        {
                                                                            result.vertex = float4(attributes.positionOS, 1);
                                                                            result.tangent = attributes.tangentOS;
                                                                            result.normal = attributes.normalOS;
                                                                            result.vertex = float4(vertexDescription.Position, 1);
                                                                            result.normal = vertexDescription.Normal;
                                                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                        }

                                                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                        {
                                                                            result.pos = varyings.positionCS;
                                                                            // World Tangent isn't an available input on v2f_surf


                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                            #endif
                                                                            #if defined(LIGHTMAP_ON)
                                                                            #endif
                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                            #endif

                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                        }

                                                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                        {
                                                                            result.positionCS = surfVertex.pos;
                                                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                            // World Tangent isn't an available input on v2f_surf

                                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                                            #endif
                                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                                            #endif
                                                                            #if defined(LIGHTMAP_ON)
                                                                            #endif
                                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                            #endif

                                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                        }

                                                                        // --------------------------------------------------
                                                                        // Main

                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                        ENDHLSL
                                                                        }
        }
            CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
                                                                            CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                            FallBack "Hidden/Shader Graph/FallbackError"
}