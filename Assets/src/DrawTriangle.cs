using UnityEngine;

namespace src
{
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class DrawTriangle : MonoBehaviour
    {
        public Material material;

        private void Start()
        {
            SetupMesh();
        }
        
        private void SetupMesh()
        {
            var mesh = new Mesh();

            var vertices = new Vector3[]
            {
                new(-0.5f, -0.5f, 0.0f), 
                new(0.0f, 0.5f, 0.0f), 
                new(0.5f, -0.5f, 0) 
            };
        
            var indices = new [] { 0, 1, 2 };

            var colors = new [] { Color.red, Color.green, Color.blue };
            
            var uvs = new Vector2[]
            {
                new(0.0f, 1.0f),
                new(0.5f, 0.0f),
                new(1.0f, 1.0f)
            };
            
            mesh.vertices = vertices;
            mesh.triangles = indices;
            mesh.colors = colors;
            mesh.uv = uvs;
        
            GetComponent<MeshFilter>().mesh = mesh;
            GetComponent<MeshRenderer>().material = material;
        }
    }
}
