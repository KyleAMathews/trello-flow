config = require './config'
Trello = require("node-trello")
t = new Trello(config.key, config.token)
_ = require 'underscore'
async = require 'async'
util = require 'util'
cronJob = require('cron').CronJob;
log = (obj) ->
  console.log util.inspect obj, false, null, true

# Setup Mongoose schema
mongoose = require('mongoose')
mongoose.connect('localhost', 'trello-flow')

schema = mongoose.Schema({ counts: 'mixed', timestamp: { type: 'date', default: Date.now } });
Count = mongoose.model('Count', schema);

counts = {}
fetchListCounts = ->
  t.get "/1/members/#{ config.username }/boards", { filter: 'open' }, (err, data) ->
    boardIds = _.pluck data, 'id'
    boardNames = _.pluck data, 'name'
    async.map boardIds, getAllCardsForBoard, (err, results) ->
      for board, i in results
        counts[boardIds[i]] =
          name: boardNames[i]
          lists: []
        for list in board
          counts[boardIds[i]].lists.push { id: list.id, name: list.name, count: list.cards.length }
          console.log boardNames[i], list.name, list.cards.length
      log counts
      count = new Count({ counts: counts })
      count.save (err) ->
        if err then console.log err
        console.log 'saved'

# Get all lists and cards for a board
getAllCardsForBoard = (boardId, callback) ->
  t.get "/1/boards/#{ boardId }/lists", { filter: 'open', cards: 'open' }, (err, data) ->
    callback null, data

#fetchListCounts()
job = new cronJob('0 0 */4 * * *', ->
  fetchListCounts()
, null, true, "America/Los_Angeles")
