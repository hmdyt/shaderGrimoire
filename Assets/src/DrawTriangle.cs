using UnityEngine;

namespace src
{
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class DrawTriangle : MonoBehaviour
    {
        private void Start()
        {
            SetupPointLight();
        }

        private static void SetupPointLight()
        {
            var pointLightGameObject = new GameObject("PointLight");
            var pointLight = pointLightGameObject.AddComponent<Light>();
            pointLight.type = LightType.Point;

            pointLight.color = Color.yellow;
            pointLight.intensity = 1.0f;
            pointLight.range = 10.0f;
            
            pointLightGameObject.transform.position = new Vector3(0, 0, 0);
        }
    }
}
