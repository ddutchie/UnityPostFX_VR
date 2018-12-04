using UnityEngine;

namespace VRFX
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class GraphicNovelFX : MonoBehaviour
    {
        #region Exposed attributes and public methods

        [Space]
        [SerializeField] Color _lineColor = Color.black;
        [SerializeField] Color _fillColor1 = Color.white;
        [SerializeField] Color _fillColor2 = Color.white;
        [SerializeField] Color _fillColor3 = Color.white;

        [Space]
        [Range(1, 5)]
        public float lineThickness;
        public Color lineColor { set { _lineColor = value; } }
        [Range(0, 1)]
        public float colorThreshold;
        [Range(0.1f, 0.2f)]
        public float depthThreshold;
        public Color fillColor1 { set { _fillColor1 = value; } }
        public Color fillColor2 { set { _fillColor2 = value; } }
        public Color fillColor3 { set { _fillColor3 = value; } }
        [Range(1,20)]
        public float ditherOffset = 9;




        #endregion
        
        [SerializeField] Shader _shader;
        Material _material;
        

        #region MonoBehaviour methods


        void OnDestroy()
        {
            if (Application.isPlaying)
                Destroy(_material);
            else
                DestroyImmediate(_material);
        }



        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (_material == null)
            {
                _material = new Material(_shader);
                _material.hideFlags = HideFlags.DontSave;
            }
            //Set Variables in shader
            _material.SetColor("_LineColor", _lineColor);
            _material.SetFloat("_LineThickness", lineThickness);
            _material.SetFloat("_ColorThreshold", colorThreshold);
            _material.SetFloat("_DepthThreshold", depthThreshold);
            _material.SetFloat("_DitherOption", ditherOffset);

            _material.SetColor("_LineColor", _lineColor);
            _material.SetColor("_FillColor1", _fillColor1);
            _material.SetColor("_FillColor2", _fillColor2);
            _material.SetColor("_FillColor3", _fillColor3);
            
            Graphics.Blit(source, destination, _material, 0);
        }

        #endregion
    }
}
