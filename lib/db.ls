require!{mongodb}

# mongodb collection name
const ARTICLE = \article
const STATUTE = \statute

mongoUri = void

exports.setMongoUri = ->
    console.log "Set mongoUri to #it"
    mongoUri := it

chainCloseDB = (db, cb) ->
    (err, res) ->
        db.close!
        cb err, res

exports.getStatute = (params, cb) ->
    m = /^([^_]+)_(\d+)$/ .exec params.query
    if not m
        cb new Error "query string format error", null
        return

    name = m.1
    article = m.2
    console.log "query statue `#name' article `#article'"

    err, db <- mongodb.Db.connect mongoUri
    if err
        cb err, null
        return
    cb := chainCloseDB db, cb

    err, collection <- db.collection STATUTE
    if err
        cb err, null
        return

    err, data <- collection.find { name: $elemMatch: { name: name } } .toArray
    if err
        cb err, null
        return

    if data.length == 0
        cb null, {}
        return

    lyID = data[0].lyID

    err, collection <- db.collection ARTICLE
    if err
        cb err, null
        return

    err, data <- collection.find { lyID: lyID, article: article } .toArray
    if err
        cb err, null
        return

    if data.length == 0
        cb null, {}
        return

    res =
        content: data[0].content

    cb null, res

exports.getSuggestion = (params, cb) ->
    keyword = params.query
    console.log "suggestion keyword is `#keyword'"

    err, db <- mongodb.Db.connect mongoUri
    if err
        cb err, null
        return
    cb := chainCloseDB db, cb

    err, collection <- db.collection STATUTE
    if err
        cb err, null
        return

    err, data <- collection.find { name: $elemMatch: { name: { $regex: keyword } } } .toArray!
    if err
        cb err, null
        return

    if data.length == 0
        cb null, []
        return

    suggestion = []
    for statute in data
        if statute.name != void
            for name in statute.name
                if typeof name.name == \string and name.name != ""
                    json = {"law": name.name }
                    json |> suggestion.push

    cb null, suggestion