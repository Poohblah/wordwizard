import webapp2
import json


class GetRound(webapp2.RequestHandler):

    def get(self):
        responseobj = {
            'status': 'fail',
            'payload': {
                'tiles': ['a', 'e', 'e', 'l', 'n', 'r', 'r'],
                'words': ['ear', 'earn', 'learn', 'eel', 'earl', 'lee', 'ran', 'reel', 'leer', 'err', 'rare', 'near', 'nearer', 'lane', 'lean', 'leaner', 'relearn']
                }
            }

        self.response.headers['Content-Type'] = 'application/json'
        self.response.write(json.dumps(responseobj))


application = webapp2.WSGIApplication([
    ('/api/getRound', GetRound),
], debug=True)
