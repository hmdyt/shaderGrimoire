Shader "Custom/TriangleShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" }

        Pass
        {
            Name "UnlitPass"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vs_main
            #pragma fragment ps_main
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            
            struct vs_input
            {
                float4 pos : POSITION;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct vs_output
            {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 world_pos : TEXCOORD1;
                float3 normal_ws : NORMAL;
            };

            TEXTURE2D (_MainTex);
            SAMPLER(sampler_MainTex);
            
            vs_output vs_main(vs_input i)
            {
                vs_output o;
                o.pos = TransformObjectToHClip(i.pos);
                o.world_pos = TransformObjectToWorld(i.pos);
                o.color = i.color;
                o.uv = i.uv;
                o.normal_ws = TransformObjectToWorldNormal(i.normal);
                
                return o;
            }

            float4 ps_main(vs_output o) : SV_Target0
            {
                float4 final_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, o.uv);
                half3 light_direction = - GetMainLight().direction;
                half3 light_color = GetMainLight().color;

                float t = dot(o.normal_ws, light_direction);
                t *= -1.;
                if (t < 0.)
                {
                    t = 0.;
                }
                float3 diffuse_light = t * light_color;

                float3 refrect_direction = reflect(light_direction, o.normal_ws);
                float3 to_eye = normalize(GetCameraPositionWS() - o.world_pos);
                t = dot(refrect_direction, to_eye);
                if (t < 0.)
                {
                    t = 0.;
                }
                t = pow(t, 32.);
                float3 specular_light = t * light_color;

                float3 total_light = diffuse_light + specular_light;
                
                // ambient light
                total_light.x += 0.3;
                total_light.y += 0.3;
                total_light.z += 0.3;

                final_color.xyz *= total_light;
                return final_color;
            }
            ENDHLSL
        }
    }
}
