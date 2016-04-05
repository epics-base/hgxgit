#!/usr/bin/env python

import logging
_L = logging.getLogger(__name__)

import sys, os, time, errno, re
from urllib2 import urlopen
from datetime import datetime
import json

def getBranches(project, since=None):
    _L.debug("Get branches of %s since %s", project, since)
    assert project is not None
    args = {
        'project':project,
    }
    # cf. https://launchpad.net/+apidoc/1.0.html#project
    url = 'https://api.launchpad.net/1.0/%(project)s?ws.op=getBranches'%args

    if since is not None:
        assert since.tzinfo is None, "Assume no zone, but actually UTC"
        url +=  "&modified_since=%s"%since.isoformat()

    while url is not None:
        _L.debug('Fetch "%s"', url)
        R = urlopen(url)
        try:
            reply = json.load(R)
        finally:
            R.close()

        for ent in reply[u'entries']:
            yield ent

        url = reply.get(u'next_collection_link')

def mfile(file):
    "Return mtime (datetime) or None"
    try:
        S = os.stat(file)
        TT = time.gmtime(S.st_mtime)
        TS = S.st_mtime%1.0
        return datetime(*TT[:6], microsecond=int(TS*1e6))
    except OSError as e:
        if e.errno!=errno.ENOENT:
            raise
        return None

def touchfile(file, mtime=None):
    if mtime is None:
        mtime = datetime.utcnow()

    from calendar import timegm
    TS = timegm(mtime.timetuple()) + 1e-6*mtime.microsecond

    if not os.path.exists(file):
        with open(file,'w'):
            pass
    os.utime(file, (TS, TS))

def getargs():
    import argparse
    P = argparse.ArgumentParser()
    P.add_argument('project')
    P.add_argument('-d','--debug',metavar='LEVEL')
    P.add_argument('--since', nargs=2)
    P.add_argument('pattern', nargs='*', default=['.*'])
    return P.parse_args()

def main(args):
    project, since, outfile = args.project, None, None
    if args.since:
        since = mfile(args.since[0])
        outfile = args.since[1]

    for B in getBranches(project, since):
        for P in args.pattern:
            name = B[u'unique_name']
            if re.match(P,name) is not None:
                print name
            else:
                _L.debug("Found mis-match %s", name)

    if outfile:
        touchfile(outfile, since)

if __name__=='__main__':
    args = getargs()
    if args.debug:
        logging.basicConfig(level=logging.getLevelName(args.debug.upper()))
    main(args)
