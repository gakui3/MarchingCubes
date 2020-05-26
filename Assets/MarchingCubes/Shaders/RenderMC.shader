Shader "MarchingCubes/RenderMC"
{

	CGINCLUDE		
	#include "UnityCG.cginc"

	struct Cell{
		float3 pos;
		int ids[8];
		float3 edgePos[12];
	};

	struct v2g
	{
		float4 pos : SV_POSITION;
		int index : TEXCOORD2;
	};

	struct g2f
	{
		float4 pos : POSITION;	
		float3 normal : NORMAL;
	};

	StructuredBuffer<Cell> CellsBuffer;
	StructuredBuffer<int> TriTableBuffer;
			
	v2g vert (appdata_base v, uint vid : SV_VertexID)
	{
		v2g o;
		o.pos = mul(UNITY_MATRIX_VP, float4(CellsBuffer[vid].pos, 1));
		o.index = vid;

		return o;
	}

	[maxvertexcount(15)]
	void geom(point v2g p[1], inout TriangleStream<g2f> triStream)
	{
		g2f o;
		float3 pos = CellsBuffer[p[0].index].pos;
		int ids[8];

		//culclate cubeindex
		int cubeindex = 0;
		for(int i=0; i<8; i++){
			int v = CellsBuffer[p[0].index].ids[i];

			if (v == 1) {
				if (i == 0)
					cubeindex |= 1;
				if (i == 1)
					cubeindex |= 2;
				if (i == 2)
					cubeindex |= 4;
				if (i == 3)
					cubeindex |= 8;
				if (i == 4)
					cubeindex |= 16;
				if (i == 5)
					cubeindex |= 32;
				if (i == 6)
					cubeindex |= 64;
				if (i == 7)
					cubeindex |= 128;
			}
		}

		//culculate triangleindex & edge position
		for(int i=0; i<16; i+=3){

			int index0 = cubeindex * 16 + i;
			int index1 = cubeindex * 16 + i + 1;
			int index2 = cubeindex * 16 + i + 2;

			int c0 = TriTableBuffer[index0];
			int c1 = TriTableBuffer[index1];
			int c2 = TriTableBuffer[index2];

			if(c0 == -1 || c1 == -1 || c2 == -1){
				break;
			}

			float4 pos0 = float4(CellsBuffer[p[0].index].edgePos[c0], 1);
			float4 pos1 = float4(CellsBuffer[p[0].index].edgePos[c1], 1);
			float4 pos2 = float4(CellsBuffer[p[0].index].edgePos[c2], 1);

			float3 _normal = normalize(cross((pos1.xyz - pos0.xyz), (pos2.xyz - pos1.xyz)));

			o.pos = mul(UNITY_MATRIX_VP, pos0);
			o.normal = _normal;
			triStream.Append(o);

			o.pos = mul(UNITY_MATRIX_VP, pos1);
			o.normal = _normal;
			triStream.Append(o);

			o.pos = mul(UNITY_MATRIX_VP, pos2);
			o.normal = _normal;
			triStream.Append(o);
		}
	}

			
	float4 frag (g2f i) : SV_Target
	{
		float atten = max(0, -1 * dot(i.normal, _WorldSpaceLightPos0));
		return float4(1, 1, 1, 1) * atten + 0.1;
	}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry" }
		LOD 100
		cull off

		Pass
		{
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma geometry geom 
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback "Diffuse"
}
