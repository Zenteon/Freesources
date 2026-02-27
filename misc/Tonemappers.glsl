/*
  ZenDynamic is roughly built to mimic the human eye
  it's mostly hue preserving, with some deliberate hue shifts in much brighter colors before desaturating

  ZenFilmic is simpler and leaves out the hue shifts
*/
vec3 ZenDynamic(vec3 x)
{
    mat3 M = mat3(
        0.68937, 0.24999, 0.20454,
        0.21798, 0.65832, 0.06249,
        0.09264, 0.09168, 0.73296
    );
    
    vec3 c = M * x;
    
    float L = dot(c, vec3(0.2126,0.7152,0.0722));
    L *= sqrt(L); L /= L + 0.42;
    
    x = x + (c - x) * L;
    x *= sqrt(x); x /= x + 0.42;
    
    return x;
}

//Simpler variant that just fades to white, visually "cooler"
vec3 ZenFilmic(vec3 x)
{
    float L = dot(x, vec3(1)/3.0);
    float L2 = L;
    
    L *= sqrt(L); L /= L + 0.42;
    x = x + (L2 - x) * L;
    x *= sqrt(x); x /= x + 0.42;
    
    return x;
}
