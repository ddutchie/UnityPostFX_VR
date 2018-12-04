Shader "Hidden/VRFX/GraphicNovel"
{
    Properties
    {
        _MainTex("", 2D) = "white" {}
        _OverlayTex("", 2D) = "black" {}
    }

    CGINCLUDE
	#include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

	float _LineThickness;

    float4 _LineColor;
	float3 _FillColor1;
	float3 _FillColor2;
	float3 _FillColor3;

	float _ColorThreshold;
	float _DepthThreshold;
	float _DitherOption;

    // Select color for posterization
	fixed3 SelectColor(float x, fixed3 c1, fixed3 c2, fixed3 c3)
	{
		return x < 1 ? c1 : (x < 2 ? c2 : c3);
	}
	// Dithering with the 3x3 Bayer matrix
	fixed Dither3x3(float2 uv)
	{
		const float3x3 pattern = float3x3(0, 7, 3, 6, 5, 2, 4, 1, 8) / _DitherOption - 0.5;
		uint2 iuv = uint2(uv * _MainTex_TexelSize.zw) % 3;
		return pattern[iuv.x][iuv.y];
	}
    // Edge detection with the Roberts cross operator
    fixed DetectEdge(float2 uv)
    {
        float4 duv = float4(0, 0, _MainTex_TexelSize.xy);

        float c11 = tex2D(_MainTex, uv + duv.xy*_LineThickness).g;
        float c12 = tex2D(_MainTex, uv + duv.zy*_LineThickness).g;
        float c21 = tex2D(_MainTex, uv + duv.xw*_LineThickness).g;
        float c22 = tex2D(_MainTex, uv + duv.zw*_LineThickness).g;

        float g_c = length(float2(c11 - c22, c12 - c21));
        g_c = saturate((g_c - _ColorThreshold) * 40);

        float d11 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + duv.xy*_LineThickness);
        float d12 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + duv.zy*_LineThickness);
        float d21 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + duv.xw*_LineThickness);
        float d22 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv + duv.zw*_LineThickness);

        float g_d = length(float2(d11 - d22, d12 - d21));
        g_d = saturate((g_d - _DepthThreshold) * 40);

        return max(g_c, g_d);
    }


    fixed4 frag(v2f_img i) : SV_Target
    {
        float2 uv = UnityStereoTransformScreenSpaceTex(i.uv);
		float c = tex2D(_MainTex,uv);
		// (1 - Linear01Depth(d) *1)
		//float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
        // Edge detection and posterization
        fixed edge = DetectEdge(uv);
		fixed luma = LinearRgbToLuminance(c);
		fixed colorSelection = luma * 3 + Dither3x3(uv);
		fixed3 fill = SelectColor(colorSelection, _FillColor1, _FillColor2, _FillColor3);
		fixed3 c_out = lerp(fill, _LineColor.rgb, edge * _LineColor.a);
		
        return fixed4(GammaToLinearSpace(c_out), 1);
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
