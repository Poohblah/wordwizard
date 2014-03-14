# wordwizard datastore models

from google.appengine.ext import ndb

class TileRack(ndb.model):

    # metainformation - for querying against
    locale = ndb.StringProperty()
    dictionary = ndb.StringProperty()
    tileset = ndb.StringProperty()
    numberOfTiles = ndb.IntegerProperty()
    longestAnswer = ndb.IntegerProperty()

    # payload
    tiles = ndb.JsonProperty()
    answers = ndb.JsonProperty()
