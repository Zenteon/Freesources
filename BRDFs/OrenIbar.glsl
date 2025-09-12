/*
    The brdf is made up of two lobes, the first one starts off fully lambertian before flattening
    in the center and showing retroreflection around the edges (and in the reciprocal case, brightening in areas ndl is low)
    
    The second lobe handles multiscattering. It assumes that 50% of the initial light that makes it past
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
    float t = 0.05+ 4.0*ndv;
    float b = 1.0 / (t+1.0);
    r = 1.25*r / (0.25+r);
    return 1.0 - mix(1.0,b,r);
}

vec3 OrenIbar(float ndl, float ndv, float r, vec3 alb)
{
    vec2 LV = max(vec2(ndl, ndv), 0.0001);
    r = max(r*r,0.001);
 
    //Primary diffuse term
    vec2 ab = vec2(0.25+0.28*r,0.25) / r;
    vec2 f = ab.x*LV / (ab.y+LV);
    float OI_S = f.x*f.x*f.y / (LV.y*LV.x);
    
    //Multiscattering
    vec3 OI_MS = LV.x*OI_MS_Approx(ndv,r) * (0.5+0.25*alb / (1.0 - 0.5*alb));
    
    return OI_S+OI_MS;
}
