cd binaries 

time java -Xmx80g \
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

