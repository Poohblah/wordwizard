import webapp2
import json
import os

# dev_env = os.environ['SERVER_SOFTWARE'].startswith('Dev')

import scripts

class GetRound(webapp2.RequestHandler):

    def get(self):
        # responseobj = {
        #     'status': 'fail',
        #     'payload': {
        #         'tiles': ['a', 'e', 'e', 'l', 'n', 'r', 'r'],
        #         'words': ['ear', 'earn', 'learn', 'eel', 'earl', 'lee', 'ran', 'reel', 'leer', 'err', 'rare', 'near', 'nearer', 'lane', 'lean', 'leaner', 'relearn']
        #         }
        #     }

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
    ('/api/getRound', GetRound)
]

application = webapp2.WSGIApplication(routes, debug=True)
