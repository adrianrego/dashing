import urllib2
from bottle import route, run, static_file, debug, post, request, response


@route('/')
def index():
    return send_static('index.html')

@post('/export/')
def export():
    url = request.forms.get('gURL')
    name = request.forms.get('expName')
    data = urllib2.urlopen(url)

    response.add_header("Content-Disposition", "attachment;filename=%s.csv" % name);
    response.content_type = 'text/csv'

    return data

@route('<filename:path>')
def send_static(filename):
    return static_file(filename, root='./dashing/')

debug(True)
run(host='0.0.0.0', port=8000, reloader=True)
