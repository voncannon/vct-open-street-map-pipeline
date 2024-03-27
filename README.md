
# Open Street Map Pipeline

The goal with this project is to generate an open street map base map with planetiler.

1. Install Java 21: 
    * https://www.oracle.com/java/technologies/downloads/#jdk21-mac
    * Planetiler requires Java.
    * As of Planetiler release v0.7.0 the minimum supported Java version is Java 17, but soon will required Java 21. So we will install Java 21.

1. Download planetiler and verify checksum: `sh ./download-planetiler.sh`

1. Download planet.osm.pbf from an appropriate mirror: `sh ./download-osm.sh`
    1. This step can be skipped if using `--download` in the planetiler command
    1. https://registry.opendata.aws/osm/
    1. https://github.com/awslabs/open-data-docs/tree/main/docs/osm-pds

1. Run `sh run.sh`
1. Convert to pmtiles `time ./pmtiles convert planet.mbtiles planet.pmtiles`
1. Upload pmtiles to s3:

    1. Set the AWS CLI env variables:

	    ```
        export AWS_ACCESS_KEY_ID=foo
        export AWS_SECRET_ACCESS_KEY=bar
	    export AWS_DEFAULT_REGION=us-east-2
        time ./pmtiles upload planet.pmtiles planet.pmtiles --bucket=s3://foobar/planet.pmtiles
        ```
  

# History of Timings

## Converting mbtiles to pmtiles

**September 7, 2023**

```
bvc@gisbox osm-data % ./pmtiles convert planet.mbtiles planet.pmtiles 
2023/09/07 10:52:06 convert.go:262: Querying total tile count...
2023/09/07 11:01:59 convert.go:278: Pass 1: Assembling TileID set
 100% |███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| (268864442/268864442, 530635 it/s)           
2023/09/07 11:10:26 convert.go:308: Pass 2: writing tiles
 100% |██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| (268864442/268864442, 126127 it/s)            
2023/09/07 11:45:57 convert.go:362: # of addressed tiles:  268864442
2023/09/07 11:45:57 convert.go:363: # of tile entries (after RLE):  50295214
2023/09/07 11:45:57 convert.go:364: # of tile contents:  39329549
2023/09/07 11:48:10 convert.go:379: Root dir bytes:  14775
2023/09/07 11:48:10 convert.go:380: Leaves dir bytes:  85502290
2023/09/07 11:48:10 convert.go:381: Num leaf dirs:  3070
2023/09/07 11:48:10 convert.go:382: Total dir bytes:  85517065
2023/09/07 11:48:10 convert.go:383: Average leaf dir bytes:  27850
2023/09/07 11:48:10 convert.go:384: Average bytes per addressed tile: 0.32
2023/09/07 11:49:34 convert.go:357: Finished in  57m27.707182667s
```

**March 27, 2024**


```
(base) bvc@bvc binaries % time ./pmtiles convert planet.mbtiles planet.pmtiles
2024/03/27 08:49:25 convert.go:260: Pass 1: Assembling TileID set
2024/03/27 08:52:15 convert.go:291: Pass 2: writing tiles
 100% |███████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| (270231343/270231343, 107073 it/s)           
2024/03/27 09:34:18 convert.go:345: # of addressed tiles:  270231343
2024/03/27 09:34:18 convert.go:346: # of tile entries (after RLE):  50820310
2024/03/27 09:34:18 convert.go:347: # of tile contents:  40518194
2024/03/27 09:35:09 convert.go:362: Root dir bytes:  14142
2024/03/27 09:35:09 convert.go:363: Leaves dir bytes:  87525008
2024/03/27 09:35:09 convert.go:364: Num leaf dirs:  2917
2024/03/27 09:35:09 convert.go:365: Total dir bytes:  87539150
2024/03/27 09:35:09 convert.go:366: Average leaf dir bytes:  30005
2024/03/27 09:35:09 convert.go:367: Average bytes per addressed tile: 0.32
2024/03/27 09:35:39 convert.go:340: Finished in  46m14.253589959s
./pmtiles convert planet.mbtiles planet.pmtiles  1616.47s user 926.01s system 91% cpu 46:15.14 total
```

## History of making planet tiles 

September 7, 2024 planet log - [2023-09-27-planet.log](2023-09-27-planet.log)

**March 27, 2024**

```
3:06:33 INF [archive] - Other tiles with large layers
14/3411/6216 (333k) https://onthegomap.github.io/planetiler-demo/#14.5/39.76632/-105.04028 (landcover:333k)
8/69/107 (125k) https://onthegomap.github.io/planetiler-demo/#8.5/27.68175/-82.26562 (landuse:125k)
13/1596/3157 (337k) https://onthegomap.github.io/planetiler-demo/#13.5/38.08269/-109.84131 (mountain_peak:337k)
5/5/11 (196k) https://onthegomap.github.io/planetiler-demo/#5.5/44.9512/-118.125 (park:196k)
2/2/1 (1.1M) https://onthegomap.github.io/planetiler-demo/#2.5/33.25663/45 (place:1.1M)
5/26/13 (410k) https://onthegomap.github.io/planetiler-demo/#5.5/26.9476/118.125 (transportation:410k)
14/9618/6751 (169k) https://onthegomap.github.io/planetiler-demo/#14.5/30.15463/31.34399 (transportation_name:169k)
12/3415/1774 (167k) https://onthegomap.github.io/planetiler-demo/#12.5/23.36242/120.19043 (water:167k)
3:06:33 DEB [archive] - Max tile sizes
                      z0    z1    z2    z3    z4    z5    z6    z7    z8    z9   z10   z11   z12   z13   z14   all
           boundary 5.4k   37k   43k   25k   19k   24k   18k   14k   14k   28k   23k   17k   31k   18k  9.4k   43k
          landcover 1.5k   982    8k  4.6k  3.2k   31k   17k  271k  333k  235k  153k  175k  166k  111k  333k  333k
              place  49k  132k  1.1M    1M  648k  319k  165k  110k   73k   98k  107k   88k   61k  122k  223k  1.1M
              water 8.4k  4.1k   10k    9k   14k   13k   89k  113k  126k  109k  132k   94k  167k  102k   91k  167k
         water_name  14k   31k   44k   23k   21k   12k  7.1k  5.3k  3.6k  9.1k  7.1k  5.7k  3.7k  3.5k   29k   44k
           waterway    0     0     0   546  3.7k  1.6k   18k   13k  9.8k   27k   20k   16k   59k   75k   88k   88k
            landuse    0     0     0     0  2.6k  1.5k   32k   66k  125k  113k   99k  111k   55k  114k   47k  125k
               park    0     0     0     0   55k  196k  124k   85k   98k   83k   90k   55k   47k   19k   50k  196k
     transportation    0     0     0     0  363k  410k  249k  234k  288k  289k  167k   95k  312k  188k  132k  410k
transportation_name    0     0     0     0     0     0   32k   19k   18k   14k   29k   18k   30k   26k  169k  169k
      mountain_peak    0     0     0     0     0     0     0   17k   18k   16k   14k   13k   11k  337k  234k  337k
    aerodrome_label    0     0     0     0     0     0     0     0  7.1k  4.6k  6.6k    4k  3.6k  2.8k  2.8k  7.1k
            aeroway    0     0     0     0     0     0     0     0     0     0   16k   25k   35k   31k   18k   35k
                poi    0     0     0     0     0     0     0     0     0     0     0     0   66k   29k  830k  830k
           building    0     0     0     0     0     0     0     0     0     0     0     0     0  141k  710k  710k
        housenumber    0     0     0     0     0     0     0     0     0     0     0     0     0     0  347k  347k
          full tile  79k  204k  1.2M    1M  739k  646k  446k  479k  433k  494k  327k  213k  390k  341k  1.2M  1.2M
            gzipped  45k  116k  568k  517k  382k  347k  266k  331k  292k  308k  218k  148k  207k  227k  685k  685k
3:06:33 DEB [archive] -    Max tile: 1.2M (gzipped: 685k)
3:06:33 DEB [archive] -    Avg tile: 138k (gzipped: 83k) using weighted average based on OSM traffic
3:06:33 DEB [archive] -     # tiles: 270,231,343
3:06:33 DEB [archive] -  # features: 3,387,016,278
3:06:33 INF [archive] - Finished in 1h10m34s cpu:10h46m8s gc:4m49s avg:9.2
3:06:33 INF [archive] -   read    1x(7% 4m42s wait:55m49s done:3s)
3:06:33 INF [archive] -   encode 11x(76% 53m42s wait:17s done:3s)
3:06:33 INF [archive] -   write   1x(7% 4m44s wait:1h3m16s done:2s)
3:06:34 INF - Finished in 3h6m35s cpu:22h54m57s gc:7m15s avg:7.4
3:06:34 INF - FINISHED!
3:06:34 INF - 
3:06:34 INF - ----------------------------------------
3:06:34 INF - data errors:
3:06:34 INF -   render_snap_fix_input   21,801,020
3:06:34 INF -   merge_snap_fix_input    21,469
3:06:34 INF -   feature_polygon_osm_invalid_multipolygon_empty_after_fix        247
3:06:34 INF -   omt_park_area_osm_invalid_multipolygon_empty_after_fix  11
3:06:34 INF -   feature_centroid_if_convex_osm_invalid_multipolygon_empty_after_fix     10
3:06:34 INF -   feature_centroid_osm_invalid_multipolygon_empty_after_fix       1
3:06:34 INF -   omt_water_polygon_osm_invalid_multipolygon_empty_after_fix      1
3:06:34 INF -   merge_snap_fix_input2   1
3:06:34 INF -   feature_point_on_surface_osm_invalid_multipolygon_empty_after_fix       1
3:06:34 INF -   merge_snap_fix_input3   1
3:06:34 INF -   omt_place_island_poly_osm_invalid_multipolygon_empty_after_fix  1
3:06:34 INF - ----------------------------------------
3:06:34 INF -   overall          3h6m35s cpu:22h54m57s gc:7m15s avg:7.4
3:06:34 INF -   download         19m26s cpu:3m26s avg:0.2
3:06:34 INF -     download-lake_centerlines_chunk-downloader  1x(0% 0.4s done:19m16s)
3:06:34 INF -     download-natural_earth_chunk-downloader     1x(0% 2s done:18m58s)
3:06:34 INF -     download-water_polygons_chunk-downloader    1x(0% 3s done:16m5s)
3:06:34 INF -     download-osm_chunk-downloader              10x(2% 20s done:26s)
3:06:34 INF -   wikidata         11m20s cpu:30m35s gc:3s avg:2.7
3:06:34 INF -     pbf     1x(0% 2s wait:7m18s done:3m52s)
3:06:34 INF -     filter 11x(23% 2m38s wait:3m59s done:3m51s)
3:06:34 INF -     fetch   1x(5% 35s wait:10m37s)
3:06:34 INF -   lake_centerlines 2s cpu:4s avg:2.3
3:06:34 INF -     read     1x(47% 0.8s)
3:06:34 INF -     process 11x(2% 0s)
3:06:34 INF -     write    1x(0% 0s)
3:06:34 INF -   water_polygons   1m16s cpu:12m23s gc:2s avg:9.8
3:06:34 INF -     read     1x(11% 8s wait:1m4s done:2s)
3:06:34 INF -     process 11x(83% 1m3s wait:4s)
3:06:34 INF -     write    1x(18% 14s wait:1m)
3:06:34 INF -   natural_earth    10s cpu:17s avg:1.7
3:06:34 INF -     read     1x(66% 7s done:3s)
3:06:34 INF -     process 11x(4% 0.4s wait:7s done:3s)
3:06:34 INF -     write    1x(0% 0s wait:7s done:3s)
3:06:34 INF -   osm_pass1        5m38s cpu:52m5s gc:2s avg:9.2
3:06:34 INF -     read     1x(1% 3s wait:5m19s)
3:06:34 INF -     process 11x(73% 4m7s block:7s)
3:06:34 INF -   osm_pass2        1h10m20s cpu:9h44m55s gc:30s avg:8.3
3:06:34 INF -     read     1x(0% 3s wait:1h9m20s done:48s)
3:06:34 INF -     process 11x(74% 51m53s block:6s wait:10s)
3:06:34 INF -     write    1x(13% 9m21s wait:59m27s)
3:06:34 INF -   boundaries       8s cpu:11s avg:1.4
3:06:34 INF -   sort             7m34s cpu:44m48s gc:1m49s avg:5.9
3:06:34 INF -     worker 12x(8% 36s wait:3m17s done:5s)
3:06:34 INF -   archive          1h10m34s cpu:10h46m8s gc:4m49s avg:9.2
3:06:34 INF -     read    1x(7% 4m42s wait:55m49s done:3s)
3:06:34 INF -     encode 11x(76% 53m42s wait:17s done:3s)
3:06:34 INF -     write   1x(7% 4m44s wait:1h3m16s done:2s)
3:06:34 INF - ----------------------------------------
3:06:34 INF -   archive 87GB
3:06:34 INF -   features        237GB

real    186m45.515s
user    1271m28.497s
sys     103m38.395s
```