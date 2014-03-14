import webapp2
import json
import os

# dev_env = os.environ['SERVER_SOFTWARE'].startswith('Dev')

import scripts

class GetTileBag(webapp2.RequestHandler):
    def get(self):
        tilebag = scripts.getrack.gettilebag()
        responseobj = { 
            'status': 'ok',
            'payload': {
                'tilebag': tilebag
                }
            }
        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps(responseobj))

class GetDict(webapp2.RequestHandler):
    def get(self):
        dictobj = scripts.getrack.getdict()
        responseobj = { 
            'status': 'ok',
            'payload': {
                'dict': dictobj
                }
            }
        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps(responseobj))

class GetRound(webapp2.RequestHandler):
    def get(self):
        rack = scripts.getrack.getrack()
        responseobj = { 
            'status': 'ok',
            'payload': {
                'tiles': rack.tiles,
                'words': rack.wordlist
                }
            }
        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps(responseobj))

routes = [
    ('/api/getRound', GetRound),
    ('/api/getTileBag', GetTileBag),
    ('/api/getDict', GetDict)
]

application = webapp2.WSGIApplication(routes, debug=True)
