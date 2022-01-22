/*Control the camera within a spherical space centred around the object space origin*/
using UnityEngine;

public class CameraControl : MonoBehaviour 
{
    public GameObject model;

    //private memebers
    float r, theta, phi;//3 components for the sphere coordinate system: theta---planar angle with positive z; phi---angle with positive y
    Vector3 cameraUp;
    Vector3 lastCameraUp;
    float zoomSpeed = 50f;
    Vector3 lastMousePosition;
    float lastPhi;
    int entry;//a flag notifying if phi becomes 180. 0: no entry; 1 from less side; 2 from greater side

	void Start()
    {
        //initialise the camera
        //position
        r = 75f;
        theta = 0f;
        phi = 45f;
        cameraUp = Vector3.up;
        transform.position = sphereToCartesian(r, theta, phi);

        //orientation
        transform.rotation = Quaternion.identity;//align camera frame with world frame
        transform.LookAt(model.transform, cameraUp);
        lastCameraUp = transform.up;

        lastMousePosition = new Vector3(-1f, 0f, 0f);
        lastPhi = phi;
        entry = 0;
    }

	void Update()
    {
        orbit();
        zoom();
        reset();
	}

    void zoom()
    {
        float scrollValue = Input.GetAxis("Mouse ScrollWheel");

        if (scrollValue != 0f)
        {
            r += (-scrollValue) * zoomSpeed;//modify r based on the scroll value
            if (r < 0)
                r = 0;
            transform.position = sphereToCartesian(r, theta, phi);
        }
    }

    void reset()
    {
        if (Input.GetKeyDown("c"))
        {
            //reset the camera to its inital pose
            //position
            r = 75f;
            theta = 0f;
            phi = 45f;
            cameraUp = Vector3.up;
            transform.position = sphereToCartesian(r, theta, phi);

            //orientation
            transform.rotation = Quaternion.identity;//align camera frame with world frame
            transform.LookAt(model.transform, cameraUp);
            lastCameraUp = transform.up;
        }
    }
    /*spherical coordinate system is generally good for orbiting camera around an object. however, when the camera passes
     * two polars, namely phi = 0 (360) and 180, special cares need to be taken:
     * 1. flip theta by 180
     * 2. flip up vector for transform.lookat
     * 3. compute a speical up vector when camera is exactly at the polars.
     */
    void orbit()
    {
        if (Input.GetMouseButton(0))
        {
            if (lastMousePosition.x == -1f)//a new button-held-down period
                lastMousePosition = Input.mousePosition;
            Vector3 deltaPosition = Input.mousePosition - lastMousePosition;
            lastMousePosition = Input.mousePosition;

            //update phi
            phi += deltaPosition.y * 0.5f;
            //special care 1: polar case: phi = 180
            if (entry != 0)//phi = 180 in last frame
            {
                switch (entry)
                {
                    case 1:
                        if (phi > 180f)//less than 180 to greater than
                        {
                            theta += 180f;
                            entry = 0;
                        }
                        else if (phi < 180f)//back to less than 180, no flipping theta
                            entry = 0;
                    break;
                    case 2:
                        if (phi < 180f)//greater than 180 to less than
                        {
                            theta -= 180f;
                            entry = 0;
                        }
                        else if (phi > 180f)//back to greater than, no flipping theta
                            entry = 0;
                    break;
                }
            }
            else if (phi == 180f)//entering phi = 180 state this frame
            {
                if (lastPhi < 180f)
                    entry = 1;
                else if (lastPhi > 180f)
                    entry = 2;
            }
            else if (lastPhi < 180f && phi > 180f)//might simply pass 180 during the two consecutive frames
            {
                theta += 180f;
            }
            else if (lastPhi > 180f && phi < 180f)
            {
                theta -= 180f;
            }

            //polar case: phi = 0 (360)
            if (phi < 0f)
            {
                phi = 360f + phi;//wrap around
                theta += 180f;
            }
            if (phi > 360f)
            {
                phi -= 360f;//wrap around
                theta -= 180f;
            }

            //special care 2
            if (phi == 0f || phi == 360f)
            {
                cameraUp = lastCameraUp;
            }
            if (phi == 180f)
            {
                cameraUp = lastCameraUp;
            }
            if (phi > 0f && phi < 180f)
            {
                cameraUp = Vector3.up;
            }
            if (phi > 180f && phi < 360f)
            {
                cameraUp = Vector3.down;
            }
            lastPhi = phi;

            //update theta
            theta -= deltaPosition.x * 0.5f;
            //theta wrap around
            if (theta < 0f)
                theta = 360f + theta;
            if (theta >= 360f)
                theta -= 360f;

            transform.position = sphereToCartesian(r, theta, phi);
            transform.LookAt(model.transform, cameraUp);
            lastCameraUp = transform.up;
        }
        if (Input.GetMouseButtonUp(0))//mouse button released, end of current button-held-down period
            lastMousePosition.x = -1f;
    }

    private Vector3 sphereToCartesian(float r, float t, float p)
    {
        Vector3 cartesian = new Vector3();
        if (p == 0f || p == 360f)
        {
            cartesian.x = cartesian.z = 0f;
            cartesian.y = r;
            return cartesian;
        }
        if (p == 180f)
        {
            cartesian.x = cartesian.z = 0f;
            cartesian.y = -r;
            return cartesian;
        }
        cartesian.x = (-1f) * Mathf.Sin(Mathf.Deg2Rad * t) * Mathf.Abs(Mathf.Sin(Mathf.Deg2Rad * p)) * r;
        cartesian.y = Mathf.Cos(Mathf.Deg2Rad * p) * r;
        cartesian.z = Mathf.Cos(Mathf.Deg2Rad * t) * Mathf.Abs(Mathf.Sin(Mathf.Deg2Rad * p)) * r;
        return cartesian;
    }
}
