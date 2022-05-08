// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

// Use the non-batching version of this shader if you are using
// local mode, and are seeing the textures move when you zoom in
// due to dynamic batching. (Dynamic batching converts local vertex
// data into world space, making local vertex position data unavailable
// to the shader.)

Shader "UVFree/StandardMetallic/Single-Texture-NoBlend" {
	Properties {
		// Triplanar space, for UI
		[HideInInspector] _TriplanarSpace("Triplanar Space", Float) = 0.0

		_TexPower("Texture Power", Range(0.0, 20.0)) = 10.0
		
		_Color ("Color", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		
		_VertexColorStrength("Vertex Color Strength", Range(0.0,1.0)) = 1.0
		
		_Glossiness ("Smoothness", Range(0.0,1.0)) = 0.5

		[Gamma] _Metallic ("Metallic", Range(0.0,1.0)) = 0.0
		_MetallicGlossMap("Metallic", 2D) = "black" {}
		_UsingMetallicGlossMap("Using Metallic Gloss Map", float) = 0.0
		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

		_BumpScale("Bump Scale", Float) = 1.0
		_BumpMap("Normal Map", 2D) = "bump" {}

		_Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
		_ParallaxMap ("Height Map", 2D) = "black" {}

		_OcclusionStrength("Occlusion Strength", Range(0.0, 1.0)) = 1.0
		_OcclusionMap("Occlusion", 2D) = "white" {}

		_EmissionColor("Emission Color", Color) = (0.0,0.0,0.0)
		_EmissionMap("Emission", 2D) = "white" {}

		_DetailMask("Detail Mask", 2D) = "white" {}

		_DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
		_DetailNormalMapScale("Scale", Float) = 1.0
		_DetailNormalMap("Normal Map", 2D) = "bump" {}

		// UI-only data
		[HideInInspector] _EmissionScaleUI("Scale", Float) = 0.0
		[HideInInspector] _EmissionColorUI("Color", Color) = (1.0,1.0,1.0)

	}
	SubShader {
		Tags {
			"RenderType"="Opaque"
			"PerformanceChecks"="False"
			//"DisableBatching"="True"
		}
		LOD 300
		
		CGPROGRAM
		#pragma target 3.0

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert fullforwardshadows nodynlightmap
		#pragma shader_feature _UVFREE_LOCAL
		#pragma shader_feature _EMISSION
		#pragma shader_feature _METALLICGLOSSMAP 
		#pragma shader_feature _DETAIL
		#pragma shader_feature _OCCLUSION
		#pragma shader_feature _PARALLAXMAP
		#pragma shader_feature _SPECULARHIGHLIGHTS_OFF
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#include "UnityCG.cginc"

		// Uncomment to enable experimental feature which flips
		// backward textures. Note: Causes some normals to be flipped.
		// #define _UVFREE_FLIP_BACKWARD_TEXTURES
		
		// Comment out following line to omit vertex colors
		#define _UVFREE_VERTEX_COLOR
		
		// Instanced Properties
		// https://docs.unity3d.com/Manual/GPUInstancing.html
		UNITY_INSTANCING_BUFFER_START (MyProperties)
		UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
#define _Color_arr MyProperties
		UNITY_INSTANCING_BUFFER_END(MyProperties)

		// Non-instanced properties
		half _TexPower;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _BumpMap;
		half _BumpScale;
		fixed _Metallic;
		fixed _Glossiness;

		#ifdef _DETAIL
			sampler2D _DetailAlbedoMap;
			float4 _DetailAlbedoMap_ST;
			sampler2D _DetailMask;
			sampler2D _DetailNormalMap;
			half _DetailNormalMapScale;
		#endif

		#ifdef _METALLICGLOSSMAP
			sampler2D _MetallicGlossMap;
			fixed _UsingMetallicGlossMap;		
		#endif

		#ifdef _OCCLUSION
			sampler2D _OcclusionMap;
			fixed _OcclusionStrength;
			
		#endif

		#ifdef _PARALLAXMAP
			sampler2D _ParallaxMap;
			half _Parallax;
		#endif

		#ifdef _EMISSION
			sampler2D _EmissionMap;
			half4 _EmissionColor;
		#endif

		#ifdef	_UVFREE_VERTEX_COLOR
			fixed _VertexColorStrength;
		#endif

		struct Input {
		
			fixed3 powerNormal;
			
			#ifdef _UVFREE_FLIP_BACKWARD_TEXTURES
				fixed3 normal;
			#endif
			
			float3 worldPos;
			fixed3 viewDirForParallax;

			#ifdef _UVFREE_VERTEX_COLOR
				fixed4 color:COLOR;
			#endif
			
			UNITY_VERTEX_INPUT_INSTANCE_ID	
		};


		void vert (inout appdata_full v, out Input o) {
		
			UNITY_INITIALIZE_OUTPUT(Input,o);

			#ifdef _UVFREE_LOCAL
				#ifdef _UVFREE_FLIP_BACKWARD_TEXTURES
					o.normal = v.normal;
				#endif
				o.powerNormal = pow(abs(v.normal), _TexPower);	
				o.powerNormal = max(o.powerNormal, 0.0001);
				o.powerNormal /= dot(o.powerNormal, 1.0);
				
				v.tangent.xyz = 
					cross(v.normal, fixed3(0.0,sign(v.normal.x),0.0)) * (o.powerNormal.x)
				  + cross(v.normal, fixed3(0.0,0.0,sign(v.normal.y))) * (o.powerNormal.y)
				  + cross(v.normal, fixed3(0.0,sign(v.normal.z),0.0)) * (o.powerNormal.z)
				;
				
				v.tangent.w = 
					(-(v.normal.x) * (o.powerNormal.x))
				  +	(-(v.normal.y) * (o.powerNormal.y))
				  +	(-(v.normal.z) * (o.powerNormal.z))
				;
				
			#else
				fixed3 worldNormal = normalize( mul( unity_ObjectToWorld, fixed4(v.normal, 0.0).xyz ) );

				float3 blend = 0;
				// Blend for sides only
				float2 xyBlend = abs(normalize(worldNormal.xy));
				blend.xy = max(0, xyBlend - 0.67);
				blend.xy /= max(0.00001, dot(blend.xy, float2(1,1)));

				// Blend for top
				blend.z = saturate((abs(worldNormal.z) - 0.675) * 80.0);
				blend.xy *= (1 - blend.z);

				o.powerNormal = blend;

				#ifdef _UVFREE_FLIP_BACKWARD_TEXTURES
					o.normal = worldNormal;
				#endif

				//o.powerNormal = pow(abs(worldNormal), _TexPower);
				//o.powerNormal = max(o.powerNormal, 0.0001);
				//o.powerNormal /= dot(o.powerNormal, 1.0);
								
				v.tangent.xyz = 
					cross(v.normal, mul(unity_WorldToObject,fixed4(0.0,sign(worldNormal.x),0.0,0.0)).xyz * (o.powerNormal.x))
				  + cross(v.normal, mul(unity_WorldToObject,fixed4(0.0,0.0,sign(worldNormal.y),0.0)).xyz * (o.powerNormal.y))
				  + cross(v.normal, mul(unity_WorldToObject,fixed4(0.0,sign(worldNormal.z),0.0,0.0)).xyz * (o.powerNormal.z))
				;
				
				v.tangent.w = 
					(-(worldNormal.x) * (o.powerNormal.x))
				  +	(-(worldNormal.y) * (o.powerNormal.y))
				  +	(-(worldNormal.z) * (o.powerNormal.z))
				;
				
			#endif

			#ifdef _PARALLAXMAP
        		TANGENT_SPACE_ROTATION;
        		o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        	#endif
		}
		
		void surf (Input IN, inout SurfaceOutputStandard o) {
		
			// TRIPLANAR UVs BASED ON WORLD OR LOCAL POSITION
			//
			
			#ifdef _UVFREE_LOCAL
				float3 pos = mul(unity_WorldToObject, float4(IN.worldPos, 1.0)).xyz;
				
				float2 posX = pos.zy;
				float2 posY = pos.xz;
				float2 posZ = float2(-pos.x, pos.y);
			#else
				float3 pos = IN.worldPos;
			
				float2 posX = IN.worldPos.zy;
				float2 posY = IN.worldPos.xz;
				float2 posZ = float2(-IN.worldPos.x, IN.worldPos.y);				
			#endif

			float2 xUV = posX * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 yUV = posY * _MainTex_ST.xy + _MainTex_ST.zw;
			float2 zUV = posZ * _MainTex_ST.xy + _MainTex_ST.zw;

			
			#ifdef _UVFREE_FLIP_BACKWARD_TEXTURES
				fixed3 powerSign = sign(IN.normal);
				xUV.x *= powerSign.x;
				zUV.x *= powerSign.z;
				yUV.y *= powerSign.y;
			#endif
			
			// PARALLAX
			//
			
			#ifdef _PARALLAXMAP

				half parallaxX = tex2D (_ParallaxMap, xUV).r;
				half parallaxY = tex2D (_ParallaxMap, yUV).g;
				half parallaxZ = tex2D (_ParallaxMap, zUV).b;
				
				half parallax = 
					parallaxX * IN.powerNormal.x
				  + parallaxY * IN.powerNormal.y
				  + parallaxZ * IN.powerNormal.z
				  ;
				float2 parallaxOffset = ParallaxOffset (parallax, _Parallax, IN.viewDirForParallax);
				xUV += parallaxOffset;
				yUV += parallaxOffset;
				zUV += parallaxOffset;

			#endif
			
			// DIFFUSE
			//
			
			fixed4 texX = tex2D(_MainTex, xUV);
			fixed4 texY = tex2D(_MainTex, yUV);
			fixed4 texZ = tex2D(_MainTex, zUV);			
			
			fixed4 tex = 
			    texX * IN.powerNormal.x
			  + texY * IN.powerNormal.y
			  + texZ * IN.powerNormal.z;				// how brightly to color the textures
														// powerNormal determines which of the three sides gets rendered
			
			#ifdef _UVFREE_VERTEX_COLOR			 
				tex *= lerp(fixed4(1.0,1.0,1.0,1.0), IN.color, _VertexColorStrength);
			#endif
				
			fixed4 tint = UNITY_ACCESS_INSTANCED_PROP (_Color_arr, _Color);
			fixed3 albedo = max(fixed3(0.0, 0.0, 0.0), tex.rgb * tint.rgb);


			// DIFFUSE DETAIL
			//
			
			#ifdef _DETAIL
				fixed detailMaskX = tex2D(_DetailMask, xUV).a;
				fixed detailMaskY = tex2D(_DetailMask, yUV).a;
				fixed detailMaskZ = tex2D(_DetailMask, zUV).a;
				
				fixed detailMask = 
					detailMaskX * IN.powerNormal.x
				  + detailMaskY * IN.powerNormal.y
				  + detailMaskZ * IN.powerNormal.z;
				
				float2 xUVDetail = pos.zy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float2 yUVDetail = pos.xz * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float2 zUVDetail = float2(-pos.x, pos.y) * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				
				#ifdef _UVFREE_FLIP_BACKWARD_TEXTURES
					xUVDetail.x *= powerSign.x;
					zUVDetail.x *= powerSign.z;
					yUVDetail.y *= powerSign.y;
				#endif
							
				#ifdef _PARALLAXMAP
					xUVDetail += parallaxOffset;
					yUVDetail += parallaxOffset;
					zUVDetail += parallaxOffset;
				#endif
				
				fixed3 detailAlbedoX = tex2D (_DetailAlbedoMap, xUVDetail).rgb;
				fixed3 detailAlbedoY = tex2D (_DetailAlbedoMap, yUVDetail).rgb;
				fixed3 detailAlbedoZ = tex2D (_DetailAlbedoMap, zUVDetail).rgb;
				
				fixed3 detailAlbedo = 
					detailAlbedoX * IN.powerNormal.x
				  + detailAlbedoY * IN.powerNormal.y
				  + detailAlbedoZ * IN.powerNormal.z;
				 
				//albedo *= detailAlbedo;
				albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, detailMask);
			#endif
			o.Albedo = albedo;
			o.Alpha = tex.a * tint.a;
						
			// NORMAL
			//
			
			fixed3 bumpX = UnpackScaleNormal(tex2D(_BumpMap, xUV), _BumpScale);
			fixed3 bumpY = UnpackScaleNormal(tex2D(_BumpMap, yUV), _BumpScale);
			fixed3 bumpZ = UnpackScaleNormal(tex2D(_BumpMap, zUV), _BumpScale);
			
			fixed3 bump = 
			    bumpX * IN.powerNormal.x
			  + bumpY * IN.powerNormal.y
			  + bumpZ * IN.powerNormal.z
			;
			
			
			// NORMAL DETAIL
			//
			#ifdef _DETAIL
				fixed3 detailNormalTangentX = UnpackScaleNormal(tex2D (_DetailNormalMap, xUVDetail), _DetailNormalMapScale);
				fixed3 detailNormalTangentY = UnpackScaleNormal(tex2D (_DetailNormalMap, yUVDetail), _DetailNormalMapScale);
				fixed3 detailNormalTangentZ = UnpackScaleNormal(tex2D (_DetailNormalMap, zUVDetail), _DetailNormalMapScale);
				
				fixed3 detailNormalTangent = 
					detailNormalTangentX * IN.powerNormal.x
				  + detailNormalTangentY * IN.powerNormal.y
				  + detailNormalTangentZ * IN.powerNormal.z;
				  
				bump = lerp(
					bump,
					BlendNormals(bump, detailNormalTangent),
					detailMask);
				
			#endif
			
			o.Normal = normalize(bump);

			// METALLIC/GLOSS
			//
			
			fixed2 mg = fixed2(
				_Metallic,
				_Glossiness
			);

			#ifdef _METALLICGLOSSMAP
				fixed2 mgX = lerp(mg, tex2D(_MetallicGlossMap, xUV).ra, _UsingMetallicGlossMap);
				fixed2 mgY = lerp(mg, tex2D(_MetallicGlossMap, yUV).ra, _UsingMetallicGlossMap);
				fixed2 mgZ = lerp(mg, tex2D(_MetallicGlossMap, zUV).ra, _UsingMetallicGlossMap);				  

				mg = 
					mgX * IN.powerNormal.x
				  + mgY * IN.powerNormal.y
				  + mgZ * IN.powerNormal.z;
				  
			#endif
			o.Metallic = mg.x;
			o.Smoothness = mg.y;

			// EMISSION
			//
						
			#ifndef _EMISSION
				o.Emission = 0.0;
			#else
				fixed3 emissionX = tex2D(_EmissionMap, xUV).rgb;
				fixed3 emissionY = tex2D(_EmissionMap, yUV).rgb;
				fixed3 emissionZ = tex2D(_EmissionMap, zUV).rgb;
				
				o.Emission = (emissionX * IN.powerNormal.x + emissionY * IN.powerNormal.y + emissionZ * IN.powerNormal.z)
				  * _EmissionColor.rgb;

			#endif
					
			// OCCLUSION
			//
			
			#ifdef _OCCLUSION
				
				fixed occX = tex2D(_OcclusionMap, xUV).g;
				fixed occY = tex2D(_OcclusionMap, yUV).g;
				fixed occZ = tex2D(_OcclusionMap, zUV).g;
				
				o.Occlusion = LerpOneTo(
					(occX * IN.powerNormal.x + occY * IN.powerNormal.y + occZ * IN.powerNormal.z),
				   _OcclusionStrength);
				
			#else
				o.Occlusion = 1.0;
			#endif
				
		}
		ENDCG
	} 
	FallBack "Diffuse"
	CustomEditor "UVFreePBRShaderGUI"
	
}
