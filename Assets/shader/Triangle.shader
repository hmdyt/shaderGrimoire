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

            float3 calc_lambert_diffuse(half3 light_direction, half3 light_color, float3 surface_normal)
            {
                float t = dot(surface_normal, light_direction);
                t *= -1.;
                if (t < 0.)
                {
                    t = 0.;
                }
                return t * light_color;
            }

            float3 calc_phong_specular(half3 light_direction, half3 light_color, float3 surface_potision, float3 surface_normal)
            {
                float3 refrect_direction = reflect(light_direction, surface_normal);
                float3 to_eye = normalize(GetCameraPositionWS() - surface_potision);
                float t = dot(refrect_direction, to_eye);
                if (t < 0.)
                {
                    t = 0.;
                }
                t = pow(t, 32.);
                return t * light_color;
            }
            
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

                float3 diffuse_light = calc_lambert_diffuse(light_direction, light_color, o.normal_ws);
                float3 specular_light = calc_phong_specular(light_direction, light_color, o.world_pos, o.normal_ws);
                float3 total_light = 0.5 * (diffuse_light + specular_light);

                // point light
                uint additional_lights_count = GetAdditionalLightsCount();
                for (uint i = 0; i < additional_lights_count; ++i)
                {
                    Light light = GetAdditionalLight(i, o.world_pos);
                    float3 direction = -light.direction;
                    float3 color = light.color;
                    float3 attenuation = light.distanceAttenuation;

                    diffuse_light = calc_lambert_diffuse(direction, color, o.normal_ws) * attenuation;
                    specular_light = calc_phong_specular(direction, color, o.world_pos, o.normal_ws) * attenuation;
                    total_light += diffuse_light + specular_light;
                }
                
                // ambient light
                total_light.x += 0.1;
                total_light.y += 0.1;
                total_light.z += 0.1;

                final_color.xyz *= total_light;

                return final_color;
            }

            ENDHLSL
        }
    }
}
