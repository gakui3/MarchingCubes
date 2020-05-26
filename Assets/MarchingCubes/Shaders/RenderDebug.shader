Shader "MarchingCubes/RenderDebug"
{

	CGINCLUDE		
	#include "UnityCG.cginc"

	struct Cell{
		float3 pos;
		int ids[8];
		float3 edgePos[12];
	};

	struct v2f
	{
		float4 pos : POSITION;
	};

	StructuredBuffer<Cell> CellsBuffer;
			
	v2f vert (appdata_base v, uint vid : SV_VertexID)
	{
		v2f o;
		float4 pos = mul(UNITY_MATRIX_VP, float4(CellsBuffer[vid].pos, 1));
		o.pos = pos;
		return o;
	}
			
	float4 frag (v2f i) : SV_Target
	{
		return float4(1, 1, 1, 1);
	}
	ENDCG

	SubShader
	{
		Tags {"RenderType"="Opaque" "Queue" = "Geometry"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
