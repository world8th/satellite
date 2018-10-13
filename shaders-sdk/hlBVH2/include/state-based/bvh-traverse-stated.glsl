
// default definitions
#include "./bvh-state-code.glsl"

// intersection current state
struct PrimitiveState {
    vec4 lastIntersection, orig;
#ifdef VRT_USE_FAST_INTERSECTION
    vec4 dir;
#else
    int axis; mat3 iM;
#endif
} primitiveState;

// used for re-init traversing 
vec3 ORIGINAL_ORIGIN = vec3(0.f); dirtype_t ORIGINAL_DIRECTION = dirtype_t(0);

// BVH traversing itself 
bool isLeaf(in ivec2 mem) { return mem.x==mem.y && mem.x >= 1; };
void resetEntry(in bool valid) { 
    [[flatten]] if (currentState == 0) {
        traverseState.idx = (valid ? bvhBlockTop.entryID : -1), traverseState.stackPtr = 0, traverseState.pageID = 0, traverseState.defElementID = 0; 
    } else {
        traverseState.idx = (valid ? bvhBlockIn.entryID : -1), traverseState.defElementID = 0;
    };
};


// initialize state 
void initTraversing( in bool valid, in int eht, in vec3 orig, in dirtype_t pdir ) {
    [[flatten]] if (eht.x >= 0) primitiveState.lastIntersection = hits[eht].uvt;

    // relative origin and vector ( also, preparing mat3x4 support ) 
    // in task-based traversing will have universal transformation for BVH traversing and transforming in dimensions 
    const vec4 torig = 0.f.xxxx, torigTo = 0.f.xxxx, tdir = 0.f.xxxx;
    [[flatten]] if (currentState == 0) {
        torig = -uniteBoxTop(vec4(mult4(bvhBlockTop.transform, vec4(orig, 1.f)).xyz, 1.f)), torigTo = uniteBoxTop(vec4(mult4(bvhBlockTop.transform, vec4(orig, 1.f) + vec4(dcts(pdir).xyz, 0.f)).xyz, 1.f));
    } else {
        torig = -uniteBox   (vec4(mult4(bvhInstance.transform, vec4(orig, 1.f)).xyz, 1.f)), torigTo = uniteBox   (vec4(mult4(bvhInstance.transform, vec4(orig, 1.f) + vec4(dcts(pdir).xyz, 0.f)).xyz, 1.f));
    }; tdir = torigTo+torig;

    const vec4 dirct = tdir*invlen, dirproj = 1.f / precIssue(dirct);
    primitiveState.dir = primitiveState.orig = dirct;

    // test intersection with main box
    vec4 nfe = vec4(0.f.xx, INFINITY.xx);
    const   vec3 interm = fma(fpInner.xxxx, 2.f, 1.f.xxxx).xyz;
    const   vec2 bside2 = vec2(-fpOne, fpOne);
    const mat3x2 bndsf2 = mat3x2( bside2*interm.x, bside2*interm.y, bside2*interm.z );

    // initial traversing state
    valid = valid && intersectCubeF32Single((torig*dirproj).xyz, dirproj.xyz, bsgn, bndsf2, nfe), resetEntry(valid);

    // traversing inputs
    traverseState.diffOffset = min(-nfe.x, 0.f);
    traverseState.directInv = fvec4_(dirproj), traverseState.minusOrig = fvec4_(vec4(fma(fvec4_(torig), traverseState.directInv, ftype_(traverseState.diffOffset).xxxx)));
    primitiveState.orig = fma(primitiveState.orig, traverseState.diffOffset.xxxx, torig);
};


// kill switch when traversing 
void switchStateTo(in int stateTo, in int instanceTo){
    if (currentState != stateTo) {
        primitiveState.lastIntersection.z = min(fma(primitiveState.lastIntersection.z, invlen, -traverseState.diffOffset*invlen), INFINITY);
        switchStackToState(stateTo);
        if (currentState == 1) { // every bottom level states requires to partial resetting states 
            initTraversing(true, -1, ORIGINAL_ORIGIN, ORIGINAL_DIRECTION);
        };
    };
};


// triangle intersection, when it found
void doIntersection(in bool isvalid, in float dlen) {
    isvalid = isvalid && traverseState.defElementID > 0 && traverseState.defElementID <= traverseState.maxElements;
    IFANY (isvalid) {
        if (currentState == 0) {
            switchStateTo(0, traverseState.defElementID);
        } else {
            vec2 uv = vec2(0.f.xx); const float nearT = fma(primitiveState.lastIntersection.z,fpOne,fpInner), d = 
#ifdef VRT_USE_FAST_INTERSECTION
                intersectTriangle(primitiveState.orig, primitiveState.dir, traverseState.defElementID-1, uv.xy, isvalid, nearT);
#else
                intersectTriangle(primitiveState.orig, primitiveState.iM, primitiveState.axis, traverseState.defElementID-1, uv.xy, isvalid);
#endif

            const float tdiff = nearT-d, tmax = 0.f;
            [[flatten]] if (tdiff >= -tmax && d < N_INFINITY && isvalid) {
                [[flatten]] if (abs(tdiff) > tmax || traverseState.defElementID > floatBitsToInt(primitiveState.lastIntersection.w)) {
                    primitiveState.lastIntersection = vec4(uv.xy, d.x, intBitsToFloat(traverseState.defElementID));
                };
            };
        };
    }; traverseState.defElementID=0;
};

#include "./bvh-traverse-code.glsl"
