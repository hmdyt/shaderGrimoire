using UnityEngine;

namespace src
{
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class DrawTriangle : MonoBehaviour
    {
        private void Start()
        {
        }

        private void Update()
        {
            Control();
        }

        private void Control()
        {
            // wasdで二次元移動
            if (Input.GetKey(KeyCode.W))
            {
                Debug.Log("W pressed");
                transform.Translate(Vector3.forward * Time.deltaTime);
            }
            if (Input.GetKey(KeyCode.S))
            {
                transform.Translate(Vector3.back * Time.deltaTime);
            }
            if (Input.GetKey(KeyCode.A))
            {
                transform.Translate(Vector3.left * Time.deltaTime);
            }
            if (Input.GetKey(KeyCode.D))
            {
                transform.Translate(Vector3.right * Time.deltaTime);
            }
        }
    }
}
