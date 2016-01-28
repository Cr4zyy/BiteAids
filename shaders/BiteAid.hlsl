#include <renderer/RenderSetup.hlsl>

struct VS_INPUT
{
   float3 ssPosition   : POSITION;
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

struct VS_OUTPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
   float4 ssPosition   : SV_POSITION;
};

struct PS_INPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

sampler2D       baseTexture;
sampler2D       depthTexture;
sampler2D       normalTexture;

cbuffer LayerConstants
{
	float        abilityRange;
	float        opacityValue;
	float					r;
	float					g;
	float					b;
};

/**
* Vertex shader.
*/  
VS_OUTPUT SFXBasicVS(VS_INPUT input)
{

   VS_OUTPUT output;

   output.ssPosition = float4(input.ssPosition, 1);
   output.texCoord   = input.texCoord + texelCenter;
   output.color      = input.color;

   return output;

}    

float4 SFXBiteAidPS(PS_INPUT input) : COLOR0
{
	
	float2 texCoord = input.texCoord;
	float normalColor = 0;
	float4 inputPixel = tex2D(baseTexture, texCoord);
	float  depth = tex2D(depthTexture, texCoord).r;
	float  model = max(0, tex2D(depthTexture, texCoord).g * 2 - 1);
	float3 normal = tex2D(normalTexture, texCoord).xyz;
	float  intensity = pow((abs(normal.z) * 1.4), 2);
	float4 edge = 0;
	float2 depth1 = tex2D(depthTexture, input.texCoord).rg;
	
	float red = inputPixel.r;
	float green = inputPixel.g;
	float blue = inputPixel.b;
	
	float x = (input.texCoord.x - 0.5) * 20;
    float y = (input.texCoord.y - 0.5) * 20;	
	float sineX  = sin(-x * .1) * sin(-x * .1);
	float sineY = sin(-y * .02) * sin(-y * .02);
	float biteAreaX  = clamp((sineX * 5),0 ,1);
	float biteAreaY = clamp((sineY * 40),0 ,1);

	float meleeRange = 1.8;
	float meleeRange1 = 1.5;
	float meleeRange2 = 1.2;
	float meleeRangeCone1 = 1;
	float meleeRangeCone2 = 0.75;
	float meleeRangeCone3 = 0.5;
	float meleeRangeInvert = 1.8;
	float meleeRangeInvert1 = 1.8;
	float meleeRangeRing = 0;
	float meleeRangeRing1 = 0;

	float range = abilityRange;
	
	//set depth for bite range marker
	//this sets default range to 1.8 which is a good avg value for skulk, lerk and fade melee attacks but isn't perfect
	//if we have a mod to pull actual alien ranges we use this to set them and overwrite the default range value above

	//this needs to be below the 'zero number' in the mod
	if (range > 0.1) {
		//this must be above the 'zero number' in the mod but below any of the actual ranges
		if (range > 1) {
		
			if (range > 1.45) {
				if (range > 1.55) {
					//range over 5 only applies to umbra and healspray			
					if (range > 5) {
						meleeRange = max((range + 0.35) - depth, 0);
						meleeRangeCone1 = max(1.25 - depth, 0);
						meleeRangeCone2 = max(1 - depth, 0);
						meleeRangeCone3 = max(.75 - depth, 0);
						meleeRange1 = max((range + 0.1) - depth, 0);
						meleeRange2 = max(range - depth, 0);
					}
					//fade and onos
					else {
					meleeRange = max((range + 0.25) - depth, 0);
					meleeRangeCone1 = max((range - (0.2 * range)) - depth, 0); 
					meleeRangeCone2 = max((range - (0.4 * range)) - depth, 0);
					meleeRangeCone3 = max((range - (0.6 * range)) - depth, 0);
					meleeRange1 = max(range - depth, 0);
					meleeRange2 = max((range - 0.2) - depth, 0);
					}
				}
				//lerk
				else {
					meleeRange = max((range + 0.25) - depth, 0);
					meleeRangeCone1 = max((range - (0.2 * range)) - depth, 0); 
					meleeRangeCone2 = max((range - (0.4 * range)) - depth, 0);
					meleeRangeCone3 = max((range - (0.75 * range)) - depth, 0);
					meleeRange1 = max(range - depth, 0);
					meleeRange2 = max(range - depth, 0);
				}
			}
			//skulk
			else {
				meleeRange = max((range + 0.35) - depth, 0);
				meleeRangeCone1 = max((range - (0.25 * range)) - depth, 0); 
				meleeRangeCone2 = max((range - (0.35 * range)) - depth, 0);
				meleeRangeCone3 = max((range - (0.65 * range)) - depth, 0);
				meleeRange1 = max(range - depth, 0);
				meleeRange2 = max(range - depth, 0);
			}
		}
		else{
			meleeRange = 0;
			meleeRangeCone1 = 0;
			meleeRangeCone2 = 0;
			meleeRangeCone2 = 0;
			meleeRange1 = 0;
			meleeRange2 = 0;
		}
	}
	else{
		meleeRange = max(1.75 - depth, 0);
		meleeRangeCone1 = 0;
		meleeRangeCone2 = 0;
		meleeRangeCone2 = 0;
		meleeRange1 = 0;
		meleeRange2 = 0;
	}
	
	//range limit ring
	meleeRangeInvert = clamp(lerp(1,0,meleeRange),0,1);
	meleeRangeInvert1 = clamp(lerp(1,0,meleeRange1),0,1);
	meleeRangeRing = meleeRange1*meleeRangeInvert;
	meleeRangeRing1 = meleeRange2*meleeRangeInvert1;

	const float offset = 0.0004 + depth1.g * 0.00001;
	float  depth2 = tex2D(depthTexture, texCoord + float2( offset, 0)).r;
	float  depth3 = tex2D(depthTexture, texCoord + float2(-offset, 0)).r;
	float  depth4 = tex2D(depthTexture, texCoord + float2( 0,  offset)).r;
	float  depth5 = tex2D(depthTexture, texCoord + float2( 0, -offset)).r;
	
	edge = abs(depth2 - depth) +  
		   abs(depth3 - depth) + 
		   abs(depth4 - depth) + 
		   abs(depth5 - depth);
		     
	edge = min(1, pow(edge + 0.12, 2));
	
	float fadedist = pow(2.6, -depth1.r * 0.23 + 0.23);
	float fadeout = max(0.0, pow(2, max(depth - 0.5, 0) * -0.3));
	float fadeoff = max(0.12, pow(2, max(depth - 0.5, 0) * -0.2));
	
	float biteCone = 0;
	float coneStrength = 0;
	float biteCircle0 = 0;
	float biteCircle1 = 0;
	float biteCircle2 = 0;
	float biteCircle3 = 0;
	float biteCircle4 = 0;
	float biteCircle5 = 0;
	
	//gorge healspray and umbra get larger cones up close
	//smaller multipliers are larger circles
	if (range > 1){
		if (range > 5) {
			biteCircle0 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 1.5, 0, 1)),0,1);
			biteCircle1 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 1.25, 0, 1)),0,1);
			biteCircle2 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 1, 0, 1)),0,1);
			biteCircle4 = lerp(1,0,clamp((biteAreaX + biteAreaY) * 2, 0, 1));
			biteCircle5 = lerp(1,0,clamp((biteAreaX + biteAreaY) * 5, 0, 1));
			}
	//melee attacks
		else {
			biteCircle0 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 9, 0, 1)),0,1);
			biteCircle1 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 3.2, 0, 1)),0,1);
			biteCircle2 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 1.9, 0, 1)),0,1);
			biteCircle3 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY) * 1, 0, 1)),0,1);
			biteCircle4 = lerp(1,0,clamp((biteAreaX + biteAreaY) * 5, 0, 1));
			biteCircle5 = lerp(1,0,clamp((biteAreaX + biteAreaY) * 10, 0, 1));
		}
	} 
	else{
		biteCircle0 = clamp(lerp(1,0,clamp((biteAreaX + biteAreaY), 0, 1)),0,1);
		biteCircle1 = 0;
		biteCircle2 = 0;
		biteCircle3 = 0;
		biteCircle4 = 0;
		biteCircle5 = 0;
		}

	//this makes sure that on high-range abilities the aid isnt blownout
	if (range > 3)
	{
		if (range > 10)
		{
		coneStrength = range / 2000;
		
		}
		else {
			coneStrength = range / 100;
		}
	}
	else 
	{
	coneStrength = 0.2;
	}
	
	if (range > 1){
		if (range > 5){
			biteCone = (model * opacityValue) * (
			meleeRange * biteCircle0 * coneStrength + 
			meleeRangeCone1 * biteCircle1 + 
			meleeRangeCone2 * biteCircle2 +			
			meleeRangeRing * biteCircle3 + 
			meleeRangeRing1 * biteCircle4);
		}
		else{
			biteCone = (model * opacityValue) * (
			meleeRange * biteCircle0 + 
			meleeRangeCone1 * biteCircle1 + 
			meleeRangeCone2 * biteCircle2 +
			meleeRangeCone3 * biteCircle3);
		}
	
	}
	else {
		biteCone = (model * opacityValue) * (meleeRange * biteCircle0);
	}

	float4 colourBite = float4(r, g, b, 1);

	//setup aid
	float4 biteAid = (biteCone * colourBite) * (1 + 0.3 * pow(0.1 + sin(time * 5 + intensity * .2), 2));

	return inputPixel + (biteAid * (model * 1.5)) * 2.5;
}