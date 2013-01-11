#! /usr/local/bin/coffee

Trello = require("node-trello")
t = new Trello("0605ffa4f8443226ea02a91e1c66b5be", "684a53ea53178c6665e6fad421d0d9da6784cffbf1236f4b7835d9815fc57492")
_ = require 'underscore'
moment = require 'moment'
async = require 'async'
util = require 'util'
log = (obj) ->
  console.log util.inspect obj, false, null, true

boardWhitelist = [
  '509c36a04d68787531001257' # Current Development
  '509c367c4d687875310011d3' # Bugs
  '509c36754d687875310011c6' # Engineering
  '509c365f4d687875310011a6' # Inbox
  '509c49a1f4f1298560002e77' # Planning
]

# Get all lists and cards for a board
getAllCardsForBoard = (boardId, callback) ->
  t.get "/1/boards/#{ boardId }/lists", { filter: 'all', cards: 'open' }, (err, data) ->
    callback null, data

async.map(boardWhitelist, getAllCardsForBoard, (err, results) ->
  counts = {}
  currentDevelopment = results[0]
  bugs = results[1]
  engineering = results[2]
  inbox = results[3]
  planning = results[4]

  counts =
    currentDevelopment__count: 0
    currentDevelopment__inProgress: 0
    currentDevelopment__backlog: 0
    bugs__count: 0
    bugs__inbox: 0
    bugs__needs_input: 0
    bugs__accepted: 0
    bugs__next_week: 0
    engineering__count: 0
    engineering__backend: 0
    engineering__frontend: 0
    engineering__headroom: 0
    engineering__marketing: 0
    engineering__customer_success: 0
    inbox__count: 0
    inbox__ideas_company: 0
    inbox__ideas_customers: 0
    planning__count: 0
    planning__story_inbox: 0
    planning__next_up: 0
    planning__spec: 0
    planning__design: 0
    planning__ready: 0
    backlog: 0
    wip: 0
    live: 0

  # Count live cards.
  for list in currentDevelopment
    if list.name.indexOf('Live') isnt -1
      counts.live += list.cards.length

  # Count cards for lists on Current Development.
  for list in currentDevelopment
    if list.name is "In Progress"
      counts.currentDevelopment__inProgress = list.cards.length
      counts.currentDevelopment__count += list.cards.length
      counts.wip += list.cards.length
    if list.name is "Backlog"
      counts.currentDevelopment__backlog = list.cards.length
      counts.currentDevelopment__count += list.cards.length
      counts.wip += list.cards.length

  # Count cards in four lists on Bugs.
  for list in bugs
    if list.name is "Inbox"
      counts.bugs__inbox = list.cards.length
      counts.bugs__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Needs Input"
      counts.bugs__needs_input = list.cards.length
      counts.bugs__count += list.cards.length
      counts.wip += list.cards.length
    if list.name is "Accepted"
      counts.bugs__accepted = list.cards.length
      counts.bugs__count += list.cards.length
      counts.wip += list.cards.length
    if list.name is "Next Week"
      counts.bugs__next_week = list.cards.length
      counts.bugs__count += list.cards.length
      counts.wip += list.cards.length

  # Count cards in lists in Engineering.
  for list in engineering
    if list.name is "Backend"
      counts.engineering__backend = list.cards.length
      counts.engineering__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Frontend"
      counts.engineering__frontend = list.cards.length
      counts.engineering__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Headroom"
      counts.engineering__headroom = list.cards.length
      counts.engineering__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Marketing"
      counts.engineering__marketing = list.cards.length
      counts.engineering__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Customer Success"
      counts.engineering__customer_success = list.cards.length
      counts.engineering__count += list.cards.length
      counts.backlog += list.cards.length

  # Count cards in Inbox.
  for list in inbox
    if list.name is "Ideas from Company"
      counts.inbox__ideas_company = list.cards.length
      counts.inbox__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Frontend"
      counts.inbox__ideas_customers = list.cards.length
      counts.inbox__count += list.cards.length
      counts.backlog += list.cards.length

  # Count cards in lists in Planning.
  for list in planning
    if list.name is "Story Inbox"
      counts.planning__story_inbox = list.cards.length
      counts.planning__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Next Up"
      counts.planning__next_up = list.cards.length
      counts.planning__count += list.cards.length
      counts.backlog += list.cards.length
    if list.name is "Spec"
      counts.planning__spec = list.cards.length
      counts.planning__count += list.cards.length
      counts.wip += list.cards.length
    if list.name is "Design"
      counts.planning__design = list.cards.length
      counts.planning__count += list.cards.length
      counts.wip += list.cards.length
    if list.name is "Ready"
      counts.planning__ready = list.cards.length
      counts.planning__count += list.cards.length
      counts.wip += list.cards.length

  now = moment().unix()
  for key, count of counts
    key = 'trello_flow.' + key.split('__').join('.')
    console.log key + "\t" + count + "\t" + now
)
