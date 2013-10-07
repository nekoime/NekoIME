request = require 'request'

Server.registerSpider
  interval:100
  name:'MoegirlWiki'
  displayName:'萌娘百科'
  type:'website'
  host:'zh.moegirl.org'
  needAuth:false
Server.on 'Spider.runMoegirlWiki',->
  wait.launchFiber ->
    apcontinue = ''
    try
      while true
        req = wait.for request,
          url:'http://zh.moegirl.org/api.php?action=query&list=allpages&apnamespace=0'
          qs:
            aplimit:500
            apfrom:'一'
            format:'json'
            apcontinue:apcontinue
          json:true
        for page in req.body.query.allpages
          Server.emit 'Spider.newItem','MoegirlWiki',page.title, 'title', 1
        break if not req.body['query-continue']?
        apcontinue = req.body['query-continue'].allpages.apcontinue
      Server.emit 'Spider.success','MoegirlWiki'
    catch e
      Server.emit 'Spider.error',e,'MoegirlWiki'
