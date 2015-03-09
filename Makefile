.SECONDARY:

data/gz/tiger/acs_2013_5yr_bg.zip:
	mkdir -p $(dir $@)
	curl -L --remote-time 'ftp://ftp.census.gov/geo/tiger/TIGER_DP/2013ACS/ACS_2013_5YR_BG.gdb.zip' -o $@.download
	mv $@.download $@

data/gdb/tiger/acs_2013_5yr_bg.gdb: data/gz/tiger/acs_2013_5yr_bg.zip
	mkdir -p $(dir $@)
	tar -xzm -C $(dir $@) -f $<
	mv data/gdb/tiger/ACS_2013_5YR_BG_NATION.gdb $@

data/gz/location_affordability_index.zip:
	mkdir -p $(dir $@)
	curl -L --remote-time 'http://lai.locationaffordability.info//lai_data_blkgrps.zip' -o $@.download
	mv $@.download $@

data/csv/location_affordability_index.csv: data/gz/location_affordability_index.zip
	mkdir -p $(dir $@)
	tar -xzm -C $(dir $@) -f $<
	mv data/csv/lai_data_blkgrps.csv $@

data/gz/tiger/congressional_districts_114.zip:
	mkdir -p $(dir $@)
	curl -L --remote-time 'http://www2.census.gov/geo/tiger/TIGER2014/CD/tl_2014_us_cd114.zip' -o $@.download
	mv $@.download $@

data/shp/congressional_districts_114.shp: data/gz/tiger/congressional_districts_114.zip
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	tar -xzm -C $(basename $@) -f $<

	for file in `find $(basename $@) -name '*.shp'`; do \
		ogr2ogr -dim 2 -f 'ESRI Shapefile' $(basename $@).$${file##*.} $$file; \
		chmod 644 $(basename $@).$${file##*.}; \
	done
	rm -rf $(basename $@)
