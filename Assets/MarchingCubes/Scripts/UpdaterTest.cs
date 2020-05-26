using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdaterTest : MarchingCubesUpdater
{

	[SerializeField] ComputeShader updater;
	[SerializeField, Range (0.01f, 0.5f)] float threshold = 0.5f;
	[SerializeField, Range (0.01f, 0.1f)] float strength = 0.1f;
	[SerializeField, Range (0.1f, 5f)] float TimeScale = 1f;

	float SumTime = 0;

	void Start ()
	{

	}

	public override void updateBuffer (ref ComputeBuffer marchingcubesBuffer, int CellCountOneLiine)
	{
		var allIndexCount = (CellCountOneLiine + 1) * (CellCountOneLiine + 1) * (CellCountOneLiine + 1);

		SumTime += Time.deltaTime * TimeScale;
		updater.SetFloat ("Time", SumTime);
		updater.SetInt ("StripCount", CellCountOneLiine);
		updater.SetFloat ("Threshold", threshold);
		updater.SetFloat ("Strength", strength);
		updater.SetBuffer (0, "IndexsBuffer", marchingcubesBuffer);
		updater.Dispatch (0, allIndexCount / 8 + 1, 1, 1);
	}
}
