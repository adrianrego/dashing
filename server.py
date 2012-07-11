from bottle import route, run, static_file, debug


@route('/')
def index():
    return send_static('index.html')

@route('<filename:path>')
def send_static(filename):
    return static_file(filename, root='./')

debug(True)
run(host='0.0.0.0', port=8000, reloader=True)
