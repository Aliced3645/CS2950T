function [ sample_size ] = computeSampleSize( k, b, eps, delta)
%COMPUTESAMPLESIZE Summary of this function goes here
%   Detailed explanation goes here
d = vcDimSel(k,b);
sample_size = sampleSize(eps, delta, d);

end

