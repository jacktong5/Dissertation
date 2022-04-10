/*Most common to least common tags*/
/*SELECT tag, COUNT(*) FROM tags
GROUP BY tag
ORDER BY COUNT (*) DESC;*/

/*Users who have used the tag castle*/
/*SELECT *
FROM flickr_edin f
JOIN tags t ON f.id = t.id
WHERE t.tag ILIKE '%castle%';*/

/*Unique users who use the castle tag*/
/*SELECT count(distinct(f.userid)) 
FROM flickr_edin f
JOIN tags t ON f.id = t.id
WHERE t.tag ILIKE '%castle%';*/

/*Tags which have the most unique users*/
/*SELECT *
FROM flcikr_edin_photo_uniqueusers
ORDER BY unique_users DESC;*/

/*Fishnet grid function*/
/*CREATE OR REPLACE FUNCTION ST_CreateFishnet(
        nrow integer, ncol integer,
        xsize float8, ysize float8,
        x0 float8 DEFAULT 0, y0 float8 DEFAULT 0,
        OUT "row" integer, OUT col integer,
        OUT geom geometry)
    RETURNS SETOF record AS
$$
SELECT i + 1 AS row, j + 1 AS col, ST_Translate(cell, j * $3 + $5, i * $4 + $6) AS geom
FROM generate_series(0, $1 - 1) AS i,
     generate_series(0, $2 - 1) AS j,
(
SELECT ('POLYGON((0 0, 0 '||$4||', '||$3||' '||$4||', '||$3||' 0,0 0))')::geometry AS cell
) AS foo;
$$ LANGUAGE sql IMMUTABLE STRICT;*/

/*Create fishnet grid (nrow, ncol, xsize, ysize, xorigin, yorigin)*/
/*SELECT *
FROM ST_CreateFishnet(61,61,250,250,320000,665000) AS cells;*/

/*Create fishnet grid as table*/
/*CREATE TABLE grid_300m AS 
SELECT *
FROM (SELECT * FROM ST_CreateFishnet(44,34,300,300,320000,665000)) as t;*/

/*Show geometry type and SRID*/
/*SELECT ST_GeometryType(geom), ST_SRID(geom)FROM grid_300m;*/

/*Change SRID*/
/*ALTER TABLE grid_300m
	ALTER COLUMN geom
	TYPE Geometry(Polygon, 27700)
USING ST_SetSRID(geom, 27700)*/

/*Spatially join flickr images and grid*/
/*CREATE TABLE flickrgrid_300m AS SELECT row, col, COUNT(*) AS count, b.geom FROM flickr_edin a
JOIN grid_300m b ON ST_WITHIN(a.geom, b.geom)
GROUP BY b.geom, row, col;*/

/*User in a certain grid*/
/*SELECT userid, usertags, b.geom FROM flickr_edin a
JOIN grid_250m_trimmed b ON ST_WITHIN(a.geom, b.geom)
WHERE b.row=13 AND b.col=1;*/

/*Create table showing which flickr tags are in which column*/
/*CREATE TABLE tags_per_grid_300m AS SELECT id, userid, UNNEST(string_to_array(usertags, '|')) as tag, row, col, b.geom FROM flickr_edin a
JOIN grid_300m b on ST_WITHIN(a.geom, b.geom);*/

/*Select tags with which column and row they are in*/
/*SELECT id, UNNEST(string_to_array(usertags, '|')) as tag, row, col FROM flickr_edin a
JOIN grid_250m_trimmed b ON ST_WITHIN(a.geom, b.geom) ORDER BY row, col;*/

/*Select false positives*/
/*SELECT userid, usertags, band, geom FROM flickr_castle_points
WHERE band = 0 AND (usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%')
ORDER BY userid;*/

/*Select false negatives*/
/*SELECT userid, usertags, band, geom FROM flickr_castle_points
WHERE band > 0 AND NOT(usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%')
ORDER BY userid;*/

/*Select castle positives*/
/*SELECT userid, usertags, band, geom FROM flickr_castle_points
WHERE band > 0 AND (usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%');*/

/*Create table of castle positives*/
/*CREATE TABLE castle_positives AS SELECT userid, usertags, band, geom FROM flickr_castle_points
WHERE band > 0 AND (usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%');*/

/*Create table of castle false positives*/
/*CREATE TABLE castle_false_positives AS SELECT id, userid, band, usertags, date_taken, geom FROM flickr_castle_points
WHERE band = 0 AND (usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%') ORDER BY userid;*/

/*Create table of castle false negatives*/
/*CREATE TABLE castle_false_negatives AS SELECT id, userid, band, usertags, date_taken, geom FROM flickr_castle_points
WHERE band > 0 AND NOT(usertags ILIKE '%edinburgh castle%' OR usertags ILIKE '%edinburghcastle%')
ORDER BY userid;*/

/*Change column type*/
/*ALTER TABLE highest_weight_grid_250m_v2
	ALTER COLUMN geom TYPE geometry;*/