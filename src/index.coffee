_ = require 'lodash'
ObjectID = require('mongodb').ObjectID


module.exports = (app, db, options = {})->
  prefix = options.prefix or "/api"
  console.log 'simple-mongo-rest mounted : ', prefix


  if options.before_hook?
    app.all("#{prefix}/*", options.before_hook)

  getQuery = (req)->
    if req.query.query?
      query = JSON.parse(req.query.query)
    else
      query = {}

    if query._id?
      query._id = new ObjectID(query._id)
    query

 
  # helper 
  queryCursor = (req)->
    # console.log 'query : ', req.query
    # console.log 'params : ', req.params

    query = getQuery(req)

    coll = db.collection(req.params.collection)

    cursor = coll.find(query)
    
    if req.query.sort?
      cursor.sort(JSON.parse(req.query.sort))
    if req.query.limit?
      cursor.limit(parseInt(req.query.limit))
    if req.query.skip?
      cursor.skip(parseInt(req.query.skip))

    cursor
   

# Read 
  app.get "#{prefix}/:collection/count", (req, res, next)->


    cursor = queryCursor(req)

    cursor.count (e, result)->
      next(e) if e?
      res.send(count: result)

  app.get "#{prefix}/:collection/:id", (req, res, next)->
    query = {_id: new ObjectID(req.params.id)}
    coll = db.collection(req.params.collection)
    coll.findOne query, (e, doc)->
      next(e) if e?
      res.send(doc)

  app.get "#{prefix}/:collection", (req, res, next)->

    cursor = queryCursor(req)

    cursor.toArray (e, doc)->
      next(e) if e?
      res.send(doc)

# Save 
  app.post "#{prefix}/:collection", (req, res, next)->
    coll = db.collection(req.params.collection)

    coll.insert req.body, (e, docs)->
      next(e) if e?
      res.send(docs)
    # if (req.body._id)
      # req.body._id = objectId(req.body._id)

    # db.collection(req.params.collection).save(req.body, {safe:true}, fn(req, res))

# Delete
  app.delete "#{prefix}/:collection", (req, res, next)->
    query = getQuery(req)

    coll = db.collection(req.params.collection)
    coll.remove query, (e, doc)->
      next(e) if e?
      res.send({affected: doc})


# Command (count, distinct, find, aggregate)
  app.put "#{prefix}/:collection/:id",  (req, res, next)->
    # console.log '=== PUT ==='
    # console.log 'query : ', req.query
    # console.log 'params : ', req.params
    # console.log 'body : ', req.body
    coll = db.collection(req.params.collection)
    # if (req.params.cmd == 'distinct')
      # req.body = req.body.key



    coll.update {_id: new ObjectID(req.params.id)}, req.body, (e, affected, result)->
      next(e) if e?
      # console.log arguments
      res.send result


  # error handler
  # app.use (err, req, res, next)->
    # res.send(500, {error: err.toString()})

