Shader "Custom/TriangleShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump" {}
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
                float4 tangent : TANGENT;
            };

            struct vs_output
            {
                float4 pos : SV_POSITION;
                float3 color : COLOR;
                float2 uv : TEXCOORD0;
                float3 world_pos : TEXCOORD1;
                float3 normal_ws : TEXCOORD2;
                float3 tangent_ws : TEXCOORD3;
                float3 bitangent_ws : TEXCOORD4;
            };

            TEXTURE2D (_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D (_BumpMap);
            SAMPLER(sampler_BumpMap);
            float _BumpScale;

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

            float3 calc_rim_light(half3 light_direction, half3 light_color, float3 surface_potision, float3 surface_normal)
            {
                half3 light_direction_view = TransformWorldToView(light_direction);
                float3 surface_potision_view = TransformWorldToView(surface_potision);
                float3 surface_normal_view = TransformWorldToViewNormal(surface_normal);
                float power1 = 1 - saturate(dot(surface_normal_view, light_direction_view));
                float power2 = 1 - saturate(dot(surface_normal_view, -surface_potision_view));
                return light_color * pow(power1 * power2, 1.3);
            }
            
            vs_output vs_main(vs_input i)
            {
                vs_output o;
                o.pos = TransformObjectToHClip(i.pos);
                o.world_pos = TransformObjectToWorld(i.pos);
                o.color = i.color;
                o.uv = i.uv;

                VertexNormalInputs normal_inputs = GetVertexNormalInputs(i.normal, i.tangent);
                o.normal_ws = normal_inputs.normalWS;
                o.tangent_ws = normal_inputs.tangentWS;
                o.bitangent_ws = normal_inputs.bitangentWS;

                return o;
            }

            float4 ps_main(vs_output o) : SV_Target0
            {
                float4 final_color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, o.uv);

                float4 normal_map = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, o.uv);
                float3 normal_ts = UnpackNormal(normal_map);

                float3x3 tbn = float3x3(
                    o.tangent_ws.x, o.bitangent_ws.x, o.normal_ws.x,
                    o.tangent_ws.y, o.bitangent_ws.y, o.normal_ws.y,
                    o.tangent_ws.z, o.bitangent_ws.z, o.normal_ws.z
                    );

                float3 normal_ws = normalize(mul(normal_ts, tbn));
                
                half3 light_direction = - GetMainLight().direction;
                half3 light_color = GetMainLight().color;

                float3 diffuse_light = calc_lambert_diffuse(light_direction, light_color, normal_ws);
                float3 specular_light = calc_phong_specular(light_direction, light_color, o.world_pos, normal_ws);
                float3 rim_light = calc_rim_light(light_direction, light_color, o.world_pos, normal_ws);
                float3 total_light = 0.5 * (diffuse_light + specular_light + 3*rim_light);

                // point light
                uint additional_lights_count = GetAdditionalLightsCount();
                for (uint i = 0; i < additional_lights_count; ++i)
                {
                    Light light = GetAdditionalLight(i, o.world_pos);
                    float3 direction = -light.direction;
                    float3 color = light.color;
                    float attenuation = light.distanceAttenuation;

                    diffuse_light = calc_lambert_diffuse(direction, color, normal_ws) * attenuation;
                    specular_light = calc_phong_specular(direction, color, o.world_pos, normal_ws) * attenuation;
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
