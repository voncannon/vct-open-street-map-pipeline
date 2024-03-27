
# Open Street Map Pipeline

The goal with this project is to generate an open street map base map with planetiler.

1. Install Java 21: 
    * https://www.oracle.com/java/technologies/downloads/#jdk21-mac
    * Planetiler requires Java.
    * As of Planetiler release v0.7.0 the minimum supported Java version is Java 17, but soon will required Java 21. So we will install Java 21.

1. Download planetiler and verify checksum: `sh ./download-planetiler.sh`

1. Download planet.osm.pbf from an appropriate mirror: `sh ./download-osm.sh`
    1. https://registry.opendata.aws/osm/
    1. https://github.com/awslabs/open-data-docs/tree/main/docs/osm-pds
    
1. Run planetiler.jar with the appropriate config
1. Convert to pmtiles


java -Xmx1g -jar planetiler.jar --download --force --area=north-carolina

java -Xmx20g -jar planetiler.jar --download --force --area=north-carolina

java -Xmx70g \
  `# return unused heap memory to the OS` \
  -XX:MaxHeapFreeRatio=40 \
  -jar planetiler.jar \
  `# Download the latest planet.osm.pbf from s3://osm-pds bucket` \
  --area=north-america --download \
  `# Accelerate the download by fetching the 10 1GB chunks at a time in parallel` \
  --download-threads=10 --download-chunk-size-mb=1000 \
  `# Also download name translations from wikidata` \
  --fetch-wikidata \
  --output=north-america.mbtiles \
  `# Store temporary node locations in memory` \
  --nodemap-type=array --storage=ram


java -Xmx70g \
  -jar planetiler.jar \
  `# Download the latest planet.osm.pbf from s3://osm-pds bucket` \
  --area=planet --bounds=planet --download \
  `# Accelerate the download by fetching the 10 1GB chunks at a time in parallel` \
  --download-threads=10 --download-chunk-size-mb=1000 \
  `# Also download name translations from wikidata` \
  --fetch-wikidata \
  --output=planet.mbtiles \
  `# Store temporary node locations at fixed positions in a memory-mapped file` \
  --nodemap-type=array --storage=mmap


# Converting the planet mbtiles to pmtiles logs

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

