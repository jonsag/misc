#!/usr/bin/python

from __future__ import unicode_literals  # python 2 only
from babelfish import Language
from datetime import timedelta
import subliminal

# configure the cache
subliminal.cache_region.configure('dogpile.cache.dbm', arguments={'filename': '/path/to/cachefile.dbm'})

# scan for videos in the folder and their subtitles
videos = subliminal.scan_videos(['/path/to/video/folder'], subtitles=True, embedded_subtitles=True, age=timedelta(weeks=1))

# download best subtitles
subtitles = subliminal.download_best_subtitles(videos, {Language('eng'), Language('fra')}, age=timedelta(weeks=1))

# save them to disk, next to the video
subliminal.save_subtitles(subtitles)
