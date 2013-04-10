require!{request, should, \./helper}
test = it

const DATA =
    statute:
        * name:
            * name: \中華民國憲法
              start_date: \1946-12-25
            ...
          history:
            * passed_date: \1946-12-25
              enactment_date: \1947-01-01
              enforcement_date: \1947.12.25
            ...
          lyID: \04101
          PCode: \A0000001
        ...
    article:
        * article: \1
          lyID: \04101
          content: \中華民國基於三民主義，為民有、民治、民享之民主共和國。\n
          passed_date: \1946-12-25
        ...

host = void

before (done) ->
    this.timeout 10000
    (err, str) <- helper.startServer DATA
    should.not.exist err
    host := str
    done!

describe 'Test /api/law', ->
    describe 'Good input', ->
        test '中華民國憲法', (done) ->
            (err, rsp, body) <- request { uri: host + \api/law/中華民國憲法 }
            should.not.exist err
            JSON.parse body .should.eql {
                isSuccess: true,
                law:
                    name:
                        * name: \中華民國憲法
                          start_date: \1946-12-25
                        ...
                    lyID: \04101
                    PCode: \A0000001
            }
            done!
    describe 'Bad input', ->
        test '中華民國', (done) ->
            (err, rsp, body) <- request { uri: host + \api/law/中華民國 }
            should.not.exist err
            JSON.parse body .isSuccess .should.be.false
            done!

describe 'Test /api/article/:query' , ->
    describe 'Good input', ->
        test '中華民國憲法_1', (done) ->
            (err, rsp, body) <- request { uri: host + \api/article/中華民國憲法_1 }
            should.not.exist err
            JSON.parse body .should.eql {
                isSuccess: true
                article:
                    content: DATA.article[0].content
            }
            done!

    describe 'Bad input', ->
        test '中華民國憲法_', (done) ->
            (err, rsp, body) <- request { uri: host + \api/article/中華民國憲法_ }
            should.not.exist err
            JSON.parse body .isSuccess .should.be.false
            done!

        test '憲法_1', (done) ->
            (err, rsp, body) <- request { uri: host + \api/article/憲法_1 }
            should.not.exist err
            JSON.parse body .isSuccess .should.be.false
            done!

describe 'Test /api/suggestion/', ->
    describe 'Good input', ->
        test '憲', (done) ->
            (err, rsp, body) <- request { uri: host + \api/suggestion/憲 }
            should.not.exist err
            JSON.parse body .should.eql {
                isSuccess: true
                suggestion:
                    * law: \中華民國憲法
                    ...
            }
            done!

describe "Test bad occation", ->
    describe "404 page", ->
        test "get the 404 page", (done) ->
            (err, rsp, body) <- request { uri: host + \api/bad-api-xxx }
            should.not.exist err
            body.indexOf('Sorry').should.not.be.below(0)
            done!

after (done) ->
    (err) <- helper.stopServer host
    done!
