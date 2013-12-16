-- Function: st_rotatezyz(geometry, double precision, double precision, double precision, geometry)
CREATE OR REPLACE FUNCTION ST_RotateXYZ(geomA geometry, rotRadiansX double precision, rotRadiansY double precision, rotRadiansZ double precision, pointOrigin geometry)
  RETURNS geometry AS
$BODY$

-- Rotate around X-axis
WITH rotatedX AS (
    SELECT ST_RotateX(geomA, rotRadiansX, pointOrigin) AS geom
    ),
-- Rotate around Y-axis
rotatedXY AS (
    SELECT ST_RotateY(geom, rotRadiansY, pointOrigin) AS geom
      FROM rotatedX
    ),
-- Rotate around Z-axis
rotatedXYZ AS (
    SELECT ST_Rotate(geom, rotRadiansZ, pointOrigin) AS geom
      FROM rotatedXY
    )
-- Return rotated geometry
SELECT geom from rotatedXYZ
;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
