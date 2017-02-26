Shader "Hidden/StencilRoughness"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        CGINCLUDE
        #include "UnityCG.cginc"

        struct Input
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
        };

        struct Varyings
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
        };

        sampler2D _MainTex;
        sampler2D _CameraGBufferTexture1;
        sampler2D _CameraDepthTexture;

        float _RoughnessThreashold;

        Varyings Vertex(Input v)
        {
            Varyings o;
            o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
            o.uv = v.uv;
            return o;
        }

        fixed4 FragmentPassThrough(Varyings input) : SV_Target
        {
            return tex2D(_MainTex, input.uv);
        }

        fixed4 FragmentSelect(Varyings input) : SV_Target
        {
            float roughness = tex2D(_CameraGBufferTexture1, input.uv).a;
            if (roughness < _RoughnessThreashold)
            {
                discard;
            }
            return tex2D(_MainTex, input.uv);
        }

        fixed4 FragmentMix1(Varyings input) : SV_Target
        {
            return lerp(tex2D(_MainTex, input.uv), fixed4(input.uv, .5, 1.), .5);
        }

        fixed4 FragmentMix2(Varyings input) : SV_Target
        {
            return lerp(tex2D(_MainTex, input.uv), 1. - fixed4(input.uv, .5, 1.), .5);
        }
        ENDCG

        Pass
        {
            Stencil
            {
                Ref 0
                Comp Always
                Pass Replace
            }
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentPassThrough
            ENDCG
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Always
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentSelect
            ENDCG
        }

        Pass
        {
            Stencil
            {
                Ref 0
                Comp Equal
                Pass Keep
            }

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentMix1
            ENDCG
        }

        Pass
        {
            Stencil
            {
                Ref 1
                Comp Equal
                Pass Keep
            }

            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment FragmentMix2
            ENDCG
        }
    }
}
