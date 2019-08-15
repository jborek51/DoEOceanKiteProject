function [posGround,varargout] = circleOnSphere(pathVariable,geomParams)
%pathVariable is parameterized along the path from 0 to 1
%geomParams is a vector in order of the following variables:
%   radius is the radius of the circle on the surface of the sphere
%   latCurve is the average Latitude (the lat of the center)
%   longCurve is the average Longitude (the long of the center)
%   sphereRadius is the radius of the sphere the path is drawn on (optional)
%       if not given, a unit sphere is assumed
%Outpus:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)

    radius = geomParams(1);
    latCurve = geomParams(2);
    longCurve = geomParams(3);
    if latCurve < 0 
        pathVariable = 2*pi - (pathVariable * 2*pi);
    else
        pathVariable = 2*pi * pathVariable;
    end
    if length(geomParams)==4
        sphereRadius = geomParams(4);
    else
        sphereRadius = 1;
    end
    pathVariable = pathVariable(:)'; %make it a row vector
    
    long=@(x) longCurve+(radius*cos(x));
    lat=@(x) latCurve+(radius*sin(x));
    path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                         sin(long(x)).*cos(lat(x));...
                         sin(lat(x));];
    posGround=path(pathVariable);
    if nargout==2
        dLongdS = @(x) -radius.*sin(x);
        dLatdS = @(x) radius.*cos(x);
        dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                            cos(lat(x)).*cos(long(x));
                            zeros(size(pathVariable))];
        dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                          -sin(lat(x)).*sin(long(x));
                          cos(lat(x))];
        dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
        if latCurve < 0 
           tangentVec = -dPathdS(pathVariable);
        else 
           tangentVec = dPathdS(pathVariable);
        end
        
        varargout{1}=tangentVec./sqrt(sum(tangentVec.^2,1));
    end
end