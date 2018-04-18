#!/usr/bin/python

'''Test CGI script.

Shows fields in query string or request body.
'''

__all__ = ["dump_form"]

import os
import urllib
import sys

def dump_form(banner=''):
    '''Dump all form data as HTTP text response'''

    write = sys.stdout.write
    environ = os.environ

    write("Content-Type: text/plain; charset=UTF-8\r\n")
    write("\r\n")

    # print banner
    if banner: 
        if environ['REQUEST_METHOD'] == 'GET':
            write("%s\nQUERY STRING\n%s\n" % (banner, banner))
        else:   # assume POST
            write("%s\nREQUEST BODY\n%s\n" % (banner, banner))

    # load urlencoded string
    if environ['REQUEST_METHOD'] == 'GET':
        encoded_string = environ['QUERY_STRING'] 
    else:   # POST
        nbytes = int(environ['CONTENT_LENGTH'])
        encoded_string = sys.stdin.read(nbytes)

    # decode fields (assume application/x-www-form-urlencoded MIME type)
    fields = encoded_string.split("&")
    fields = [(k, urllib.unquote_plus(v))
                for (k, v) in [field.split("=", 1)
                                for field in fields]]
    # dump fields
    for (k,v) in sorted(fields):
        write("%s = %s\n" % (k, v))

if __name__ == '__main__':
    dump_form('-' * 60)
    sys.exit(0)

# vim:sw=4:ts=4:ai:et
