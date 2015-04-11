flickrchive
====

Description
-----------
flickrchive is a tool which scans a given directory and archives it to the flickr using the [flickraw](https://github.com/hanklords/flickraw) gem. It persists actions in a [daybreak](http://propublica.github.io/daybreak/) db file. flickrchive is definitely beta quality. Since we're all opionated here, I wrote this mainly to be used as a cli/cron tool, but if you really want to, feel free to take a look at the code and use it as you see fit!


Installation
------------
`gem install flickrchive`


Usage Documentation
-----------------
Before you get started, you'll need an API key with flickr. [Go get one.](https://www.flickr.com/services/apps/create/apply/). From here you'll need to prep a config file in YAML format for the tool.

```yaml
---
api_key: <api_key>
shared_secret: <shared_secret>
db_file: "/var/lib/flickrchive/pictures.db"
log_file: "/var/log/flickrchive.log"
log_level: debug
directory: "/var/lib/shares/pictures"
access_token: <user_token_optional>
access_secret: <user_secret_optional>
excludes:
  - ".recycle/"
```

A few notes:
  * flickrchive will look for this yaml file at ~/.flickrchive.yml unless specified.
  * Required fields:
    * api_key
    * shared_secret
    * db_file
    * directory
  * Optional fields:
    * log_file (defaults to STDOUT)
    * log_level (defaults to debug, I said this was beta software, right?)
  * If you leave out `access_token` and `access_secret` from the config file, you'll be prompted to log in on first run (and the tool will write these back to the config file once you've done so!).
  * setting `log_level` very high will result in a large log file. obvious, but important nonetheless.
  * `excludes` is a yaml list, each of these lines will be pased to `Regexp.new` and will be excluded from the search list!


Running Documentation
----------------------
Now that we're all set up, you can run flickrchive. really, give it a try!

  * `flickrchive prep` will scan the directory and build a db of photos that can be uploaded.
  * `flickrchive exec` will find un-uploaded photos in the db and upload them to flickr.
  * Additionally, you can pass `--config` to each command in order to specify your own, non-default (`~/.flickrchive.yml`) config file location. This enables two independent directory syncs.

If you intend to kill flickrchive while it's running, be aware that you may cause weird states in the db. I haven't had this issue while building, but it could happen.


Known Limitations
-----------------
###Sets and Tagging
flickrchive attempts to automagically give your photos some organization.  Each photo will be placed into a 'set' which is the current directory it is in (eg. one level up from the photo). Additionally, all sub directories inside of your base directory will end up as tags for the photo. 

Example: 
  * Base directory: /Volumes/pictures
  * file: /Volumes/pictures/2006/2006-02-02FunDayOut/IMG_001.jpg

IMG_001 will be added to a set called "2006-02-02FunDayOut" and have tags "2006-02-02FunDayOut" and "2006"

###Memory Usage

This is a total first implementation, so pardon the nitty-gritty. I'm currently using `Rake::FileList` to grab all of the files we plan to look at.  This can take quite some time to work, but reimplementing will require interaction with the db during this grab. 

Just to give some performance statistics. I ran `array = FileList['huge_recursive_dir_of_photos']` on a network drive (over wifi as well). The results weren't so bad (Rake::FileList is quite efficient, really):

  * array.count => 146659
  * array in memory appears to have bloated my irb process from ~13MB to ~60MB
  * array took ~20 seconds to be created
  * array takes ~6 seconds to be created when on the local system (same file count size).

###Approximate Scan Time & Size

A directory with ~146k files, photos, videos and sub directories took <3 hours to init into the db. The DB is 47MB (no-compacted) and the debug log file created was 19MB. Actual uploads of these photos to flickr will vary greatly in length depending on upload speeds.

V0.1.1 contains a fix which allows subsequent scans to occur in a far shorter time than the initial scan.

## Copyright
Copyright (c) 2015 Steve Nolen
See [LICENSE][] for details.

[license]: LICENSE