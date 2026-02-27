/*
    The brdf is made up of two lobes, the first one starts off fully lambertian before flattening to scatter mostly perpendicular to the macro normal
    
    The second lobe handles multiscattering and retroreflection. It assumes that 50% of the initial light that makes it past
    the first lobe is reflected directly before scattering light, with 50% escaping each time.
    
    At higher roughnesses this second lobe is much more prominent, and the 50% multiscatter means
    that it's highly dynamic in response to albedo color, with white albedos passing the white furnace
    test almost perfectly, and very dark albedos being darker than single scatter Oren Nayar
    
    I have decided to name it Oren-Ibar, as both a pun on my name and the Oren Nayar BRDF
*/
#define PI 3.141592

//Curve fit for multiscattering term, this was calaulated numerically before being fit empirically.
float OI_MS_Approx(float ndv, float r)
{
    float t = 0.0 + 8.0*ndv;
    float b = 1.0 / (t+1.0);
    r = 1.125*r / (0.125+r);
    return 1.0 - mix(1.0,b,r);
}

vec3 OrenIbar(float ndl, float ndv, float ldv, float r, vec3 alb)
{
    vec2 LV = max(vec2(ndl, ndv), 0.0001);
    r = max(r*r,0.001);
 
    //Primary diffuse term
    vec2 ab = vec2(0.125+0.17*r,0.125) / r;
    vec2 f = ab.x*LV / (ab.y+LV);
    float OI_S = f.x*f.y / (LV.y);
    
    //Multiscattering
    vec3 OI_MS = LV.x*OI_MS_Approx(ndv,r) * (0.5+0.5*alb / (2.0 - alb));
    
    float RR = mix(1.0, 0.75 / pow(1.25 - ldv, 1.5), pow(1.0 - ndv,5.0) );
    
    return vec3(0) + OI_S + OI_MS * RR; 
}
