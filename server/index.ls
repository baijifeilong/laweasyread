require!{express, \./db}
STATIC_URI = \/

const API_URI = \/api
const API_TABLE =
    \statute/:query :
        func: db.getStatute
        default: {}
    \suggestion/:query :
        func: db.getSuggestion
        default: []

exports.start = (config) ->
    app = express!
    app.use express.compress!
    app.use express.logger \dev

    console.log "static dir is #{config.static_dir}"
    app.use STATIC_URI, express.static config.static_dir

    db.setMongoUri config.mongo_uri

    app.get STATIC_URI, (req, res) ->
        res.redirect \/index.html

    for api, data of API_TABLE
        app.get "#API_URI/#api", (req, res) ->
            console.log "call #API_URI/#api"
            (err, ret) <- data.func req.params
            if err
                console.error err
                ret = data.default
            res.jsonp ret

    console.log "start application"
    console.log "port: #{config.port}"
    app.listen config.port