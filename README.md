postgis_webviewer
=================

Quickie (PHP and ASP.NET) web viewer for viewing PostGIS geometry and rasters

This is a simple postgis query tool for rendering postgis raster and geometry outputs.  
It can only display one image at a time and is currently hard-coded to output PNG 
using postgis raster image functions.
Feel free to extend it for your needs.

##PREREQUISITES##
ASP.NET 2.0+ (this will work just fine with the light-weight web server 
packaged with VS or VS Web Express) or PHP 5+
It hasn't been tested on Mono, but should work fine.
We have a GetRasterVB.ashx for VB.NET lovers like us
and GetRasterCS.ashx for C# (those other people :) ) and also GetRaster.php.
The application is defaulted to use the GetRaster.php handler, 
but if you prefer ASP.NET just change the line in postgis_viewer.htm:
```javascript
var postgis_handler = "GetRaster.php";
```
to:
```javascript
var postgis_handler = "GetRasterCS.ashx";
```
or
```javascript
var postgis_handler = "GetRasterVB.ashx";
```

## INSTALLATION ## 
1. You need PostGIS 2.0 or later built with raster support.
2. Change the web.config to the credentials of your database. If you are using PHP then change the config.inc.php to 
credentials of your databse
Please note that this tool since it allows
some ad-hoc queries, if your app is easily accessible on the web, 
you'll want to use 
an account with low level permissions.  It just needs access to the function 
postgis_viewer_image.  And that function needs to be created under an account
that has access to the tables and all the postgis and raster functions you want the user to have access to.

3. run the toraster.sql function in your database to install the 
helper stored function.  Not the owner of the function needs to have access to tables, functions etc you want the user
to have access to.
4. Make sure the account you specified in web.config has rights 
to execute the function
To verify it works, try this function in psql or 
PgAdmin logged in as the account you have in your web.config
(making sure the account you specified in web.config has rights to execute the function
SELECT postgis_viewer_image('ST_Point(10,20)', 'geometry', ARRAY[100,0,0]);
5. Copy the files to your web server.
Open up:
http://yourserver/postgis_webviewer/postgis_viewer.htm

in a brower.

## LIMITATIONS ##
1. The viewer can currently only render one geometry or raster tile at a time,
though you can get around this using ST_Union
functions to union your rasters together into a single raster/
2. The viewer can't render the new geometry types like TIN or POLYHEDRAL
or Curved geometries.
This is a limitation of GDAL (which PostGIS raster relies on for rendering).
GDAL will hopefully be enhanced in the future to support these 
more advanced types, if people find it useful enough to 
fund the GDAL work needed to make this happen: http://gdal.org/.  
Then PostGIS will just be able to render these with just SQL.
3. The viewer is hard-coded to output PNG for geometry .
You can change the plpgsql function to take these 
or hardcode a larger or smaller.
4. The viewer is hardcoded to output in PNG even for rasters. 
To use other formats, choose raw and explicitly use the ST_AsPNG, ST_ASJPEG etc.

## HOW TO USE ##
The viewer currently only shows one geometry or raster at a time, 
so you need to type an SQL expression that resolves to 
one geometry or one raster.  So for example if you are outputing from a table,
you need to have just one column and wrap the query around
for example: (SELECT geom FROM sometable WHERE town='Boston')

Some more examples:
For geometry:
Toggle the spatial type drop down to "Geometry":
Choose a color you want to output the query (the color picker is only relevant for Geometry)
Type in an sql expression that resolves to a geometry.

```sql 
ST_Buffer(ST_Point(1,1), 10);
```

-- a more complex geometry example --
```sql
 ST_Polygon(
    (SELECT ST_SetBandNoDataValue(ST_Band(rast,1),255) FROM ch13.pele_chunked WHERE rid = 1)
    )
```

For raster:
```sql
 ST_AsRaster(
		ST_Buffer(
			ST_GeomFromText('LINESTRING(50 50,150 150,150 50)'), 10,'join=bevel'), 
			200,200,ARRAY['8BUI', '8BUI', '8BUI'], ARRAY[118,154,118], ARRAY[0,0,0])
```

```sql
(SELECT rast FROM ch13.pele_chunked ORDER BY rid LIMIT 1 OFFSET 4)
```

For raw:  
--raw mode allows you to completely control the rendering process
-- assumed to output an image

```sql
SELECT ST_AsJPEG(rast, ARRAY[3,2,1]) FROM ch13.pele limit 1;
```

